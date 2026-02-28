##
## Error and warning manager.
##
## Helper to manage common errors. This is designed to make compact, clean code that manages
## errors coming from commonly used functions that can return errors. This functions are normally
## just considered to not cause any issues, and errors are not checked and just ignored. Following
## best practices, this module aids in always checking those errors without distracting the main
## flow of the code.
##
@tool
extends Node

const _DEFAULT_ERROR_MSG: String = "Unexpected error."
const _DEFAULT_WARNING_MSG: String = "Issue detected."

## Notifications that will trigger a log file flush.
const LOG_FLUSH_NOTIFICATIONS: PackedInt32Array = [
		NOTIFICATION_WM_CLOSE_REQUEST,
		NOTIFICATION_WM_GO_BACK_REQUEST,
		NOTIFICATION_APPLICATION_FOCUS_OUT
	]

# =============================================================
# ========= Public Functions ==================================
#region Public Functions


## If [param arg] is [code]false[/code], the Logger will print an error message if [param warning]
## is [code]false[/code], or a warning message if it is [code]true[/code]. If [param err_message] is
## empty, the displayed message will be a default one. Also, the name of the calling module can be
## passed in the [param module] parameter.
func try(arg: bool, err_message: String = "", module: StringName = "", warning: bool = false) -> void:
	if not arg:
		if warning:
			var msg: String = _DEFAULT_WARNING_MSG if err_message.is_empty() else err_message
			Log.warning(msg, module)
		else:
			var msg: String = _DEFAULT_ERROR_MSG if err_message.is_empty() else err_message
			Log.error(msg, module)


## If [param arg] is [code]false[/code], the Logger will print an error message if [param warning]
## is [code]false[/code], or a warning message if it is [code]true[/code]. If [param err_message] is
## empty, the displayed message will be a default one. Also, the name of the calling module can be
## passed in the [param module] parameter. It returns the same value as [param arg].
func success(arg: bool, err_message: String = "", module: StringName = "", warning: bool = false) -> bool:
	if not arg:
		if warning:
			var msg: String = _DEFAULT_WARNING_MSG if err_message.is_empty() else err_message
			Log.warning(msg, module)
		else:
			var msg: String = _DEFAULT_ERROR_MSG if err_message.is_empty() else err_message
			Log.error(msg, module)
		return false
	return true


## If [param arg] is [code]false[/code], the Logger will print an error message if [param warning]
## is [code]false[/code], or a warning message if it is [code]true[/code]. If [param err_message] is
## empty, the displayed message will be a default one. Also, the name of the calling module can be
## passed in the [param module] parameter. It returns the negated value of [param arg].
func fail(arg: bool, err_message: String = "", module: StringName = "", warning: bool = false) -> bool:
	if not arg:
		if warning:
			var msg: String = _DEFAULT_WARNING_MSG if err_message.is_empty() else err_message
			Log.warning(msg, module)
		else:
			var msg: String = _DEFAULT_ERROR_MSG if err_message.is_empty() else err_message
			Log.error(msg, module)
		return true
	return false


## If [param arg] is a different value than [code]OK[/code], the Logger will print an error message
## if [param warning] is [code]false[/code], or a warning message if it is [code]true[/code].
func try_err(err: int, err_message: String = "", module: StringName = "", warning: bool = false) -> void:
	if err != OK:
		if warning:
			var msg: String = __get_err_string(err) if err_message.is_empty() else err_message
			Log.warning(msg, module)
		elif err_message.is_empty():
			Log.error(__get_err_string(err), module)
		else:
			Log.error(err_message, module, err)


## If [param arg] is a different value than [code]OK[/code], the Logger will print an error message
## if [param warning] is [code]false[/code], or a warning message if it is [code]true[/code]. If
## [param err] is [code]OK[/code], it return [code]true[/code].
func success_err(err: int, err_message: String = "", module: StringName = "", warning: bool = false) -> bool:
	if err != OK:
		if warning:
			var msg: String = __get_err_string(err) if err_message.is_empty() else err_message
			Log.warning(msg, module)
		elif err_message.is_empty():
			Log.error(__get_err_string(err), module)
		else:
			Log.error(err_message, module, err)
		return false
	return true


## If [param arg] is a different value than [code]OK[/code], the Logger will print an error message
## if [param warning] is [code]false[/code], or a warning message if it is [code]true[/code]. If
## [param err] is [code]OK[/code], it return [code]false[/code].
func fail_err(err: int, err_message: String = "", module: StringName = "", warning: bool = false) -> bool:
	if err != OK:
		if warning:
			var msg: String = __get_err_string(err) if err_message.is_empty() else err_message
			Log.warning(msg, module)
		elif err_message.is_empty():
			Log.error(__get_err_string(err), module)
		else:
			Log.error(err_message, module, err)
		return true
	return false


## Use this function when resizing an [Array].
func try_resize(err: int, module: StringName = "") -> void:
	if err != OK:
		var msg: String = "Failed to resize array (%s)." % error_string(err)
		Log.error(msg, module)


## Use this function when pushing elements to packed arrays.
func try_append(arg: bool, module: StringName = "") -> void:
	if arg:
		var msg: String = "Failed to append element to array."
		Log.error(msg, module)


## Helper function to connect a [param signal_] to a [param callabale].
func conn(signal_: Signal, callable: Callable, flags: int = 0, module: StringName = "") -> void:
	var err: int = signal_.connect(callable, flags)

	if err != OK:
		var msg: String = "Failed to connect signal %s to method %s." % [signal_.get_name(), callable.get_method()]
		Log.error(msg, module)


## Use this function when erasing elements from [Dictionary] and packed arrays.
func try_erase(arg: bool, module: String = "") -> void:
	if not arg:
		var msg: String = "Element not found while trying to make an erase operation."
		Log.warning(msg, module)

#endregion

# =============================================================
# ========= Built-in Functions ================================


func _notification(what: int) -> void:
	if what in LOG_FLUSH_NOTIFICATIONS:
		Log.force_flush()

# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================

func __get_err_string(err: int) -> String:
	return "%s (%d)" % [error_string(err), err]


# =============================================================
# ========= Signal Callbacks ==================================
