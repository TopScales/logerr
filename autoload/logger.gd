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
##   not work as intended.
## - FATAL. Used for errors that will definitively impede to continue the execution of the game.
##
## When modules are used, they will be shown as part of the message with a differentiated color for
## each module. Coloring is applied to most messages, except for errors and warnings, which will use
## default colors from the core engine.
##
## It is possible to send the message to a [RichTextLabel], where messages will be printed using
## the colors specified in [ProjectSettings] [code]addons/logerr/colors/*[/code] section.
##
@tool
extends Node

## Emitted when a fatal error is logged in.
signal fatal_error(message: String, module: String)

enum LogLevel {VERBOSE, DEBUG, INFO, WARNING, ERROR, FATAL, MUTED}
enum FatalAction {NONE = 0, EMIT_SIGNAL = 1, ALERT = 2, CRASH = 4}

const _ADDON_PREFIX: String = "addons/logerr/"
const _VERBOSE_TAG: String = "VERBOSE"
const _DEBUG_TAG: String = "DEBUG"
const _INFO_TAG: String = "INFO"
const _WARNING_TAG: String = "WARNING"
const _ERROR_TAG: String = "ERROR"
const _FATAL_TAG: String = "FATAL"
const _FATAL_ALERT_TITLE: String = "Fatal Error!"

#region Private Variables
var _level: LogLevel = LogLevel.DEBUG
var _push_to_debugger: bool = false
var _use_project_verbose: bool = false
var _fatal_action: int = 0
var _verbose_color: Color
var _debug_color: Color
var _info_color: Color
var _warning_color: Color
var _error_color: Color
var _fatal_color: Color
var _verbose_text_color: Color
var _debug_text_color: Color
var _info_text_color: Color
var _warning_text_color: Color
var _error_text_color: Color
var _fatal_text_color: Color
var _dirty_settings: bool = false
var _color_counter: int = 0
var _modules: Dictionary[StringName, Color] = {}
var _console: RichTextLabel = null
#endregion

# =============================================================
# ========= Public Functions ==================================
#region Public Functions

## Sets the RichTextLabel control to be used as console output.
func set_console(console: RichTextLabel) -> void:
	_console = console


## Registers a new module for logging with automatic color assignment.
## Throws an error if the module is already registered
func register_module(module: String) -> void:
	assert(not module.is_empty())
	var m: StringName = module
	if _modules.has(m):
		printerr("Logger module already exist.")
	else:
		_modules[m] = __module_to_color(module)


## Logs a verbose level message. Only logs if current level is VERBOSE. and respects project verbose settings
func verbose(message: String, module: String = "") -> void:
	if _level == LogLevel.VERBOSE:
		if _use_project_verbose:
			var msg: String = __cat_message_no_format(_VERBOSE_TAG, module, message)
			print_verbose(msg)

		if not _use_project_verbose or _console:
			var msg: String = __cat_message(_VERBOSE_TAG, _verbose_color, module, message, _verbose_text_color)

			if not _use_project_verbose:
				print_rich(msg)

			if _console:
				_console.append_text(msg)


## Logs a debug level message
## @param message: The message to log
## @param module: Optional module name for categorization
## Only logs if current level is DEBUG or lower
func debug(message: String, module: String = "") -> void:
	if _level <= LogLevel.DEBUG:
		var msg: String = __cat_message(_DEBUG_TAG, _debug_color, module, message, _debug_text_color)
		print_rich(msg)

		if _console:
			_console.append_text(msg)


## Logs an info level message
## @param message: The message to log
## @param module: Optional module name for categorization
## Only logs if current level is INFO or lower
func info(message: String, module: String = "") -> void:
	if _level <= LogLevel.INFO:
		var msg: String = __cat_message(_INFO_TAG, _info_color, module, message, _info_text_color)
		print_rich(msg)

		if _console:
			_console.append_text(msg)


## Logs a warning level message
## @param message: The message to log
## @param module: Optional module name for categorization
## Only logs if current level is WARNING or lower
func warning(message: String, module: String = "") -> void:
	if _level <= LogLevel.WARNING:
		if _push_to_debugger:
			var msg: String = __cat_message_no_format(_WARNING_TAG, module, message)
			push_warning(msg)

		if not _push_to_debugger or _console:
			var msg: String = __cat_message(_WARNING_TAG, _warning_color, module, message, _warning_text_color)

			if not _push_to_debugger:
				print_rich(msg)

			if _console:
				_console.append_text(msg)


## Logs an error level message
## @param message: The message to log
## @param module: Optional module name for categorization
## Only logs if current level is ERROR or lower
func error(message: String, module: String = "") -> void:
	if _level <= LogLevel.ERROR:
		var msg: String = __cat_message_no_format(_ERROR_TAG, module, message)

		if _push_to_debugger:
			push_error(msg)
		else:
			printerr(msg)

		if _console:
			msg = __cat_message(_ERROR_TAG, _error_color, module, message, _error_text_color)
			_console.append_text(msg)


## Logs a fatal error message and triggers configured fatal actions
## @param message: The message to log
## @param module: Optional module name for categorization
## Actions are configured via project settings and can include:
## - Emitting the fatal_error signal
## - Showing an alert dialog
## - Crashing the application
func fatal(message: String, module: String = "") -> void:
	if _level <= LogLevel.FATAL:
		var crash: bool = _fatal_action & FatalAction.CRASH

		if not crash:
			var msg: String = __cat_message_no_format(_FATAL_TAG, module, message)

			if _push_to_debugger:
				push_error(msg)
			else:
				printerr(msg)

		if _console:
			var msg: String = __cat_message(_FATAL_TAG, _fatal_color, module, message, _fatal_text_color)
			_console.append_text(msg)

		if _fatal_action & FatalAction.EMIT_SIGNAL:
			fatal_error.emit(message, module)

		if _fatal_action & FatalAction.ALERT or crash:
			var msg: String = message if module.is_empty() else "%s: %s" % [module, message]

			if _fatal_action & FatalAction.ALERT:
				OS.alert(msg, _FATAL_ALERT_TITLE)

			if crash:
				OS.crash(msg)

#endregion

# =============================================================
# ========= Callbacks =========================================
#region Callbacks

func _ready() -> void:
	__update_settings()
	var err: int = ProjectSettings.settings_changed.connect(__queue_update_settings)
	if err != OK:
		push_error("Failed to connect signal 'settings changed'.")

#endregion

# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================
#region Private Functions

func __queue_update_settings() -> void:
	if not _dirty_settings:
		_dirty_settings = true
		__update_settings.call_deferred()


func __update_settings() -> void:
	_level = ProjectSettings.get_setting(_ADDON_PREFIX + "output_level", LogLevel.DEBUG)
	_push_to_debugger = ProjectSettings.get_setting(_ADDON_PREFIX + "push_to_debugger", false)
	_use_project_verbose = ProjectSettings.get_setting(_ADDON_PREFIX + "use_project_verbose", false)
	_fatal_action = ProjectSettings.get_setting(_ADDON_PREFIX + "fatal_action", 0)
	_verbose_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/verbose_tag_color", Color.WHITE)
	_debug_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/debug_tag_color", Color.WHITE)
	_info_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/info_tag_color", Color.WHITE)
	_warning_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/warning_tag_color", Color.WHITE)
	_error_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/error_tag_color", Color.WHITE)
	_fatal_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/fatal_tag_color", Color.WHITE)
	_verbose_text_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/verbose_text_color", Color.WHITE)
	_debug_text_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/debug_text_color", Color.WHITE)
	_info_text_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/info_text_color", Color.WHITE)
	_warning_text_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/warning_text_color", Color.WHITE)
	_error_text_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/error_text_color", Color.WHITE)
	_fatal_text_color = ProjectSettings.get_setting(_ADDON_PREFIX + "colors/fatal_text_color", Color.WHITE)
	_dirty_settings = false


func __cat_message_no_format(level: String, module: String, messsage: String) -> String:
	if module.is_empty():
		return "[%s] %s" % [level, messsage]
	else:
		return "[%s] %s: %s" % [level, module, messsage]


func __cat_message(level: String, level_color: Color, module: String, message: String, message_color: Color) -> String:
	if module.is_empty():
		return "[color=#%s][lb]%s[rb][/color] [color=#%s]%s[/color]" % \
			[level_color.to_html(false), level, message_color.to_html(false), message]
	else:
		return "[color=#%s][lb]%s[rb][/color] [color=#%s]%s[/color]: [color=#%s]%s[/color]" % \
			[level_color.to_html(false), level, __get_module_color(module).to_html(false), module, message_color.to_html(false), message]


func __get_module_color(module: String) -> Color:
	var m: StringName = module
	if _modules.has(m):
		return _modules[m]
	else:
		var color: Color = __module_to_color(module)
		_modules[m] = color
		return color


func __module_to_color(module: String) -> Color:
	var module_hash: int = module.hash()
	var hue_index: int = module_hash & 0x000F
	var sat_index: int = (module_hash & 0x00F0) >> 4
	var val_index: int = (module_hash & 0x0F00) >> 8
	var hue: float = float(hue_index) / 16.0
	var sat: float = 0.6 + 0.4 * float(sat_index) / 15.0
	var val: float = 0.5 + 0.5 * float(sat_index) / 15.0
	return Color.from_hsv(hue, sat, val)

#endregion

# =============================================================
# ========= Signal Callbacks ==================================
