@tool
extends EditorPlugin

const LOGGER_NAME: String = "Log"
const ERR_NAME: String = "Err"
const BENCHMARK_NAME: String = "Benchmark"
const ADDON_PREFIX: String = "addons/logerr/"
const LoggerScript: GDScript = preload("autoload/logger.gd")


func _enable_plugin() -> void:
	if not ProjectSettings.has_setting(ADDON_PREFIX + "output_level"):
		ProjectSettings.set_setting(ADDON_PREFIX + "output_level",
			LoggerScript.LogLevel.DEBUG)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "output_level",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "Verbose,Debug,Info,Warning,Error,Fatal,Muted"
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "output_level", LoggerScript.LogLevel.DEBUG)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "push_to_debugger"):
		ProjectSettings.set_setting(ADDON_PREFIX + "push_to_debugger", false)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "push_to_debugger",
			type = TYPE_BOOL
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "push_to_debugger", false)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "use_project_verbose"):
		ProjectSettings.set_setting(ADDON_PREFIX + "use_project_verbose", false)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "use_project_verbose",
			type = TYPE_BOOL
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "use_project_verbose", false)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "fatal_action"):
		ProjectSettings.set_setting(ADDON_PREFIX + "fatal_action", LoggerScript.FatalAction.EMIT_SIGNAL)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "fatal_action",
			type = TYPE_INT,
			hint = PROPERTY_HINT_FLAGS,
			hint_string = "Emit Signal,Alert,Crash"
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "fatal_action", LoggerScript.FatalAction.EMIT_SIGNAL)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/verbose_tag_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/verbose_tag_color", Color.POWDER_BLUE)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/verbose_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/verbose_tag_color", Color.POWDER_BLUE)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/debug_tag_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/debug_tag_color", Color.ORANGE_RED)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/debug_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/debug_tag_color", Color.ORANGE_RED)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/info_tag_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/info_tag_color", Color.TEAL)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/info_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/info_tag_color", Color.TEAL)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/warning_tag_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/warning_tag_color", Color.GOLDENROD)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/warning_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/warning_tag_color", Color.GOLDENROD)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/error_tag_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/error_tag_color", Color.FIREBRICK)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/error_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/error_tag_color", Color.FIREBRICK)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/fatal_tag_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/fatal_tag_color", Color.RED)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/fatal_tag_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/fatal_tag_color", Color.RED)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/verbose_text_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/verbose_text_color", Color.WHITE)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/verbose_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/verbose_text_color", Color.WHITE)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/debug_text_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/debug_text_color", Color.DARK_ORANGE)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/debug_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/debug_text_color", Color.DARK_ORANGE)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/info_text_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/info_text_color", Color.TURQUOISE)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/info_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/info_text_color", Color.TURQUOISE)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/warning_text_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/warning_text_color", Color.GOLD)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/warning_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/warning_text_color", Color.GOLD)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/error_text_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/error_text_color", Color.CRIMSON)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/error_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/error_text_color", Color.CRIMSON)

	if not ProjectSettings.has_setting(ADDON_PREFIX + "colors/fatal_text_color"):
		ProjectSettings.set_setting(ADDON_PREFIX + "colors/fatal_text_color", Color.CRIMSON)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "colors/fatal_text_color",
			type = TYPE_COLOR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "colors/fatal_text_color", Color.CRIMSON)

	add_autoload_singleton(LOGGER_NAME, "autoload/logger.gd")
	add_autoload_singleton(ERR_NAME, "autoload/err.gd")
	add_autoload_singleton(BENCHMARK_NAME, "autoload/benchmark.gd")


func _disable_plugin() -> void:
	ProjectSettings.clear(ADDON_PREFIX + "output_level")
	ProjectSettings.clear(ADDON_PREFIX + "push_to_debugger")
	ProjectSettings.clear(ADDON_PREFIX + "use_project_verbose")
	ProjectSettings.clear(ADDON_PREFIX + "fatal_action")
	ProjectSettings.clear(ADDON_PREFIX + "colors/verbose_tag_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/debug_tag_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/info_tag_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/warning_tag_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/error_tag_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/fatal_tag_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/verbose_text_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/debug_text_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/info_text_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/warning_text_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/error_text_color")
	ProjectSettings.clear(ADDON_PREFIX + "colors/fatal_text_color")
	remove_autoload_singleton(BENCHMARK_NAME)
	remove_autoload_singleton(ERR_NAME)
	remove_autoload_singleton(LOGGER_NAME)
