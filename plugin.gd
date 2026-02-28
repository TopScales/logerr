@tool
extends EditorPlugin

const ERR_NAME: String = "Err"
const BENCHMARK_NAME: String = "Benchmark"
const SETTINGS_PREFIX: String = Log.SETTINGS_PREFIX


func _enter_tree() -> void:
	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "output_level"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "output_level", Log.Level.DEBUG)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "output_level",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "Verbose,Debug,Info,Warning,Error,Critical,Muted"
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "output_level", Log.Level.DEBUG)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "print_backtrace"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "print_backtrace", true)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "print_backtrace",
			type = TYPE_BOOL
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "print_backtrace", true)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "enable_file_logging"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "enable_file_logging", false)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "enable_file_logging",
			type = TYPE_BOOL
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "enable_file_logging", false)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "enable_file_logging.pc"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "enable_file_logging.pc", true)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "enable_file_logging.pc",
			type = TYPE_BOOL
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "enable_file_logging.pc", true)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/verbose_text_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/verbose_text_color", Log._DEF_VERBOSE_TXT_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/verbose_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/verbose_text_color", Log._DEF_VERBOSE_TXT_COLOR)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/debug_tag_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/debug_tag_color", Log._DEF_DEBUG_TAG_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/debug_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/debug_tag_color", Log._DEF_DEBUG_TAG_COLOR)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/debug_text_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/debug_text_color", Log._DEF_DEBUG_TXT_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/debug_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/debug_text_color", Log._DEF_DEBUG_TXT_COLOR)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/info_tag_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/info_tag_color", Log._DEF_INFO_TAG_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/info_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/info_tag_color", Log._DEF_INFO_TAG_COLOR)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/info_text_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/info_text_color", Log._DEF_INFO_TXT_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/info_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/info_text_color", Log._DEF_INFO_TXT_COLOR)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/warning_tag_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/warning_tag_color", Log._DEF_WARN_TAG_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/warning_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/warning_tag_color", Log._DEF_WARN_TAG_COLOR)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/warning_text_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/warning_text_color", Log._DEF_WARN_TXT_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/warning_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/warning_text_color", Log._DEF_WARN_TXT_COLOR)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/error_tag_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/error_tag_color", Log._DEF_ERROR_TAG_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/error_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/error_tag_color", Log._DEF_ERROR_TAG_COLOR)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/error_text_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/error_text_color", Log._DEF_ERROR_TXT_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/error_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/error_text_color", Log._DEF_ERROR_TXT_COLOR)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/critical_tag_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/critical_tag_color", Log._DEF_CRITICAL_TAG_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/critical_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/critical_tag_color", Log._DEF_CRITICAL_TAG_COLOR)

	if not ProjectSettings.has_setting(SETTINGS_PREFIX + "colors/critical_text_color"):
		ProjectSettings.set_setting(SETTINGS_PREFIX + "colors/critical_text_color", Log._DEF_CRITICAL_TXT_COLOR)
		ProjectSettings.add_property_info({
			name = SETTINGS_PREFIX + "colors/critical_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(SETTINGS_PREFIX + "colors/critical_text_color", Log._DEF_CRITICAL_TXT_COLOR)

	ProjectSettings.set_setting("debug/file_logging/enable_file_logging", false)
	ProjectSettings.set_setting("debug/file_logging/enable_file_logging.pc", false)
	add_autoload_singleton(ERR_NAME, "autoload/err.gd")
	add_autoload_singleton(BENCHMARK_NAME, "autoload/benchmark.gd")


func _exit_tree() -> void:
	ProjectSettings.clear(SETTINGS_PREFIX + "output_level")
	ProjectSettings.clear(SETTINGS_PREFIX + "print_backtrace")
	ProjectSettings.clear(SETTINGS_PREFIX + "enable_file_logging")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/verbose_text_color")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/debug_tag_color")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/debug_text_color")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/info_tag_color")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/info_text_color")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/warning_tag_color")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/warning_text_color")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/error_tag_color")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/error_text_color")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/critical_tag_color")
	ProjectSettings.clear(SETTINGS_PREFIX + "colors/critical_text_color")
	remove_autoload_singleton(BENCHMARK_NAME)
	remove_autoload_singleton(ERR_NAME)
