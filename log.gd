##
## Custom logger that provides different logging levels and shows the module that produced the
## message.
##
## The messages are colorized depending on the logging level. The different levels are:
## - VERBOSE. Normally used to display information in detail. Useful for development and
##   troubleshooting.
## - DEBUG. Shows information that is useful for debugging.
## - INFO. General information that is much less detailed than VERBOSE messages.
## - WARNING. Informs about something unexpected but that won't break any system.
## - ERROR. Used for things that can cause potential issues and most likely will make the game
##   not to work as intended.
## - CRITICAL. Used for errors that will definitively impede to continue the execution of the game.
##
## When modules are used, they will be shown as part of the message with a differentiated color for
## each module.
##
## It is possible to send the message to a [RichTextLabel], where messages will be printed using
## the colors specified in [ProjectSettings] [code]debug/file_logging/colors/*[/code] section.
##
@tool
class_name Log
extends Logger

class LevelParams:
	var tag: String
	var tag_color: String
	var text_color: String

	func _init(tag_: String, tag_color_: Color, text_color_: Color) -> void:
		tag = tag_
		tag_color = tag_color_.to_html(false)
		text_color = text_color_.to_html(false)

enum Level { VERBOSE, DEBUG, INFO, WARNING, ERROR, CRITICAL, MUTED, FORCE_FLUSH }

const SETTINGS_PREFIX: String = "addons/logerr/"

const _LOG_EXTENSION: String = "log"
const _MAX_BUFFER_SIZE: int = 10
const _FLUSH_LEVELS: PackedByteArray = [
	Level.ERROR,
	Level.CRITICAL,
	Level.FORCE_FLUSH,
]
const _DEF_VERBOSE_TXT_COLOR: Color = Color.DARK_GRAY
const _DEF_DEBUG_TAG_COLOR: Color = Color.TOMATO
const _DEF_DEBUG_TXT_COLOR: Color = Color.DARK_ORANGE
const _DEF_INFO_TAG_COLOR: Color = Color.SKY_BLUE
const _DEF_INFO_TXT_COLOR: Color = Color.TURQUOISE
const _DEF_WARN_TAG_COLOR: Color = Color.DARK_ORANGE
const _DEF_WARN_TXT_COLOR: Color = Color.GOLD
const _DEF_ERROR_TAG_COLOR: Color = Color.FIREBRICK
const _DEF_ERROR_TXT_COLOR: Color = Color.CRIMSON
const _DEF_CRITICAL_TAG_COLOR: Color = Color.RED
const _DEF_CRITICAL_TXT_COLOR: Color = Color.CRIMSON
const _MODULE: StringName = &"Log"
const _PLATFORMS: PackedStringArray = [
	"pc",
	"android",
	"ios",
	"web"
]

#region Private Variables
static var _level_strings: PackedStringArray = Level.keys()
static var _level_params: Array[LevelParams]
static var _log_dir: String
static var _log_file_template: String
static var _log_extension: String
static var _buffer_size: int
static var _log_file: FileAccess
static var _is_valid: bool
static var _mutex: Mutex = Mutex.new()
static var _modules: Dictionary[StringName, String]
static var _level: Level
static var _print_backtrace: bool
static var _console: RichTextLabel
static var _enable_file_logging: bool
#endregion

# =============================================================
# ========= Public Functions ==================================

## Sets the RichTextLabel control to be used as console output.
static func set_console(console: RichTextLabel) -> void:
	_console = console


## Logs a verbose level message. Only logs if current level is VERBOSE.
static func verbose(message: String, module: StringName = &"") -> void:
	if not _is_valid or _level > Level.VERBOSE:
		return

	var level: Level = Level.VERBOSE
	var messages: Array[String] = __format_log_message(message, _level_params[level], module, false)
	__add_message_to_file(messages[0], level)
	__print_message(messages[1])


## Logs a debug level message. Only logs if current level is DEBUG or lower.
static func debug(message: String, module: StringName = &"") -> void:
	if not _is_valid or _level > Level.DEBUG:
		return

	var level: Level = Level.DEBUG
	var messages: Array[String] = __format_log_message(message, _level_params[level], module)
	__add_message_to_file(messages[0], level)
	__print_message(messages[1])


## Logs an info level message. Only logs if current level is INFO or lower.
static func info(message: String, module: StringName = &"") -> void:
	if not _is_valid or _level > Level.INFO:
		return

	var level: Level = Level.INFO
	var messages: Array[String] = __format_log_message(message, _level_params[level], module)
	__add_message_to_file(messages[0], level)
	__print_message(messages[1])


## Logs a warning level message. Only logs if current level is WARNING or lower.
static func warning(message: String, module: StringName = &"") -> void:
	if not _is_valid or _level > Level.WARNING:
		return

	var level: Level = Level.WARNING
	var messages: Array[String] = __format_log_message(message, _level_params[level], module)
	__add_message_to_file(messages[0], level)
	__print_message(messages[1])


## Logs an error level message. Only logs if current level is ERROR or lower.
static func error(message: String, module: StringName = &"", err: int = -1) -> void:
	if not _is_valid or _level > Level.ERROR:
		return

	var level: Level = Level.ERROR
	message = message if err <= OK else "%s (%d: %s)" % [message, err, error_string(err)]
	var messages: Array[String] = __format_log_message(message, _level_params[level], module)
	var script_backtraces: Array[ScriptBacktrace] = Engine.capture_script_backtraces()
	var backtrace: String = __get_gdscript_backtrace(script_backtraces, true)
	__add_message_to_file(messages[0] + '\n' + backtrace, level)
	var pmessage: String = messages[1] + '\n' + backtrace if _print_backtrace else messages[1]
	__print_message(pmessage)


## Logs a critical level message. Only logs if current level is CRITICAL or lower.
static func critical(message: String, module: StringName = &"", err: int = -1) -> void:
	if not _is_valid or _level > Level.CRITICAL:
		return

	var level: Level = Level.CRITICAL
	message = message if err <= OK else "%s (%d: %s)" % [message, err, error_string(err)]
	var messages: Array[String] = __format_log_message(message, _level_params[level], module)
	var script_backtraces: Array[ScriptBacktrace] = Engine.capture_script_backtraces()
	var backtrace: String = __get_gdscript_backtrace(script_backtraces, true)
	__add_message_to_file(messages[0] + '\n' + backtrace, level)
	var pmessage: String = messages[1] + '\n' + backtrace if _print_backtrace else messages[1]
	__print_message(pmessage)


## Force file messages to flush the buffer to disk.
static func force_flush() -> void:
	__add_message_to_file("", Level.FORCE_FLUSH)


# =============================================================
# ========= Built-in Functions ================================


static func _static_init() -> void:
	__get_enable_file_logging()

	if _enable_file_logging:
		__get_logs_path()
		_log_file = __create_log_file()
		_is_valid = _log_file and _log_file.is_open()
	else:
		_is_valid = true

	if _is_valid:
		__get_settings()

		if not DirAccess.dir_exists_absolute(_log_dir) and DirAccess.make_dir_recursive_absolute(_log_dir) != OK:
			printerr("Log directory cannot be created.")

		OS.add_logger(Log.new())
		__remove_old_log_files()
	else:
		printerr("Failed to open the log file.")


func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
	if not _is_valid:
		return

	var level: Level = Level.WARNING if error_type == ERROR_TYPE_WARNING else Level.ERROR
	var message := "[{time}] {level}: {rationale}\n{code}\n{file}:{line} @ {function}()".format({
		"time": Time.get_time_string_from_system(),
		"level": _level_strings[level],
		"rationale": rationale,
		"code": code,
		"file": file,
		"line": line,
		"function": function,
 	})
	if level == Level.ERROR:
		message += '\n' + __get_gdscript_backtrace(script_backtraces)
	__add_message_to_file(message, level)


func _log_message(message: String, log_message_error: bool) -> void:
	if not _is_valid or message.begins_with("[lang=tlh]"):
		return

	var level: Level = Level.ERROR if log_message_error else Level.INFO
	message = "[{time}] {level}: {message}".format({
		"time": Time.get_time_string_from_system(),
		"level": _level_strings[level],
		"message": message
	})
	__add_message_to_file(message, level)


# =============================================================
# ========= Virtual Methods ===================================

# =============================================================
# ========= Private Functions =================================


static func __get_enable_file_logging() -> void:
	var found: bool = false

	for platform in _PLATFORMS:
		var setting_path: String = SETTINGS_PREFIX + "enable_file_logging." + platform
		if ProjectSettings.has_setting(setting_path):
			_enable_file_logging = ProjectSettings.get_setting(setting_path)
			found = true
			break

	if not found:
		if ProjectSettings.has_setting(SETTINGS_PREFIX + "enable_file_logging"):
			_enable_file_logging = ProjectSettings.get_setting(SETTINGS_PREFIX + "enable_file_logging")
		else:
			_enable_file_logging = false


static func __get_settings() -> void:
	_level = ProjectSettings.get_setting(SETTINGS_PREFIX + "output_level", Level.DEBUG)
	@warning_ignore("return_value_discarded")
	_level_params.resize(Level.CRITICAL + 1)
	var text_color: Color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/verbose_text_color", _DEF_VERBOSE_TXT_COLOR)
	var verbosep: LevelParams = LevelParams.new(_level_strings[Level.VERBOSE], Color.BLACK, text_color)
	_level_params[Level.VERBOSE] = verbosep
	var tag_color: Color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/debug_tag_color", _DEF_DEBUG_TAG_COLOR)
	text_color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/debug_text_color", _DEF_DEBUG_TXT_COLOR)
	var debugp: LevelParams = LevelParams.new(_level_strings[Level.DEBUG], tag_color, text_color)
	_level_params[Level.DEBUG] = debugp
	tag_color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/info_tag_color", _DEF_INFO_TAG_COLOR)
	text_color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/info_text_color", _DEF_INFO_TXT_COLOR)
	var infop: LevelParams = LevelParams.new(_level_strings[Level.INFO], tag_color, text_color)
	_level_params[Level.INFO] = infop
	tag_color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/info_tag_color", _DEF_WARN_TAG_COLOR)
	text_color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/info_text_color", _DEF_WARN_TXT_COLOR)
	var warnp: LevelParams = LevelParams.new(_level_strings[Level.WARNING], tag_color, text_color)
	_level_params[Level.WARNING] = warnp
	tag_color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/info_tag_color", _DEF_ERROR_TAG_COLOR)
	text_color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/info_text_color", _DEF_ERROR_TXT_COLOR)
	var errorp: LevelParams = LevelParams.new(_level_strings[Level.ERROR], tag_color, text_color)
	_level_params[Level.ERROR] = errorp
	tag_color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/info_tag_color", _DEF_CRITICAL_TAG_COLOR)
	text_color = ProjectSettings.get_setting(SETTINGS_PREFIX + "colors/info_text_color", _DEF_CRITICAL_TXT_COLOR)
	var criticalp: LevelParams = LevelParams.new(_level_strings[Level.CRITICAL], tag_color, text_color)
	_level_params[Level.CRITICAL] = criticalp
	_print_backtrace = ProjectSettings.get_setting(SETTINGS_PREFIX + "print_backtrace", true)


static func __get_logs_path() -> void:
	var log_path: String = ProjectSettings.get_setting("debug/file_logging/log_path", "user://logs/{time}.{ext}")
	if log_path.get_extension().is_empty():
		_log_dir = log_path
		_log_file_template = "{time}.%s" % _LOG_EXTENSION
		_log_extension = _LOG_EXTENSION
	else:
		_log_dir = log_path.get_base_dir()
		_log_file_template = log_path.get_file().format({"ext": _LOG_EXTENSION})
		_log_extension = log_path.get_extension()


static func __create_log_file() -> FileAccess:
	var file_path: String = _log_file_template.format({
		"time": Time.get_datetime_string_from_system().replace(":", "."),
		"ext": _LOG_EXTENSION
	})
	var file: FileAccess = FileAccess.open(_log_dir.path_join(file_path), FileAccess.WRITE)
	return file


static func __remove_old_log_files() -> void:
	if not _enable_file_logging:
		return

	var max_log_files: int = ProjectSettings.get_setting("debug/file_logging/max_log_files")
	var log_file_paths: Array[String]

	for file in DirAccess.get_files_at(_log_dir):
		if file == _log_file_template:
			var base: String = file.get_basename()
			var new_name: String = "%s%s.%s" % [_log_dir.path_join(base), Time.get_time_string_from_system(), file.get_extension()]
			var full_file_name: String = _log_dir.path_join(file)
			var err: int = DirAccess.rename_absolute(full_file_name, new_name)
			if err == OK:
				log_file_paths.push_back(new_name)
			else:
				log_file_paths.push_back(full_file_name)
				error("Can't rename previous log file.", _MODULE, err)
		elif file.get_extension() == _log_extension:
			log_file_paths.push_back(_log_dir.path_join(file))

	while log_file_paths.size() >= max_log_files:
		var path: String = log_file_paths.pop_front()
		var err: int = DirAccess.remove_absolute(path)

		if err != OK:
			error("Failed to clean up old log: " + path, _MODULE, err)


static func __get_gdscript_backtrace(script_backtraces: Array[ScriptBacktrace], remove_last_call: bool = false) -> String:
	var gdscript: int = script_backtraces.find_custom(func(backtrace: ScriptBacktrace) -> bool:
		return backtrace.get_language_name() == "GDScript")
	if gdscript == -1:
		return "Backtrace N/A"
	else:
		var string: String = str(script_backtraces[gdscript])

		if remove_last_call:
			var parts: PackedStringArray = string.split("\n")
			string = "%s\n%s" % [parts[0], "\n".join(parts.slice(2))]
		return string


static func __print_message(message: String) -> void:
	print_rich.call_deferred(message)

	if _console:
		_console.append_text(message)


static func __add_message_to_file(message: String, level: Level) -> void:
	if not _enable_file_logging:
		return

	_mutex.lock()
	if _is_valid:
		if not message.is_empty():
			_is_valid = _log_file.store_line(message)
			_buffer_size += 1
		if _buffer_size >= _MAX_BUFFER_SIZE or level in _FLUSH_LEVELS:
			_log_file.flush()
			_buffer_size = 0
	_mutex.unlock()


static func __format_log_message(message: String, level_params: LevelParams, module: StringName, show_tag: bool = true) -> Array[String]:
	var module_str: String = "" if module.is_empty() else " [color=#%s]%s:[/color]" % [__get_module_color(module), module]
	var module_str_raw: String = "" if module.is_empty() else " %s:" % module
	var level_str: String = " [color=#%s]%s:[/color]" % [level_params.tag_color, level_params.tag] if show_tag else ""
	var level_str_raw: String = "" if show_tag else " %s:" % level_params.tag
	var time: String = Time.get_time_string_from_system()
	var str_formatted: String = "[lang=tlh][lb]%s[rb][/lang]%s%s [color=#%s]%s[/color]" % [time, module_str, level_str, level_params.text_color, message]
	var str_raw = "[%s]%s%s %s" % [time, module_str_raw, level_str_raw, message]
	return [str_raw, str_formatted]


static func __get_module_color(module: StringName) -> String:
	var color: String = _modules.get(module, "")

	if color.is_empty():
		color = __module_to_color(module).to_html(false)
		_modules[module] = color

	return color


static func __module_to_color(module: StringName) -> Color:
	var module_hash: int = module.hash()
	var hue_index: int = module_hash & 0x000F
	var sat_index: int = (module_hash & 0x00F0) >> 4
	var val_index: int = (module_hash & 0x0F00) >> 8
	var hue: float = float(hue_index) / 16.0
	var sat: float = 0.6 + 0.4 * float(sat_index) / 15.0
	var val: float = 0.65 + 0.35 * float(val_index) / 15.0
	return Color.from_hsv(hue, sat, val)


# =============================================================
# ========= Signal Callbacks ==================================
