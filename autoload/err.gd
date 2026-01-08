##
## Error and warning manager.
##
## Long description.
##
@tool
extends Node

const DEFAULT_ERROR_MSG: String = "Unexpected error."
const DEFAULT_WARNING_MSG: String = "Issue detected."


# =============================================================
# ========= Public Functions ==================================
#region Public Functions

func try(arg: bool, err_message: String = "", module: String = "", warning: bool = false) -> void:
	if not arg:
		if warning:
			var msg: String = DEFAULT_WARNING_MSG if err_message.is_empty() else err_message
			Log.warning(msg, module)
		else:
			var msg: String = DEFAULT_ERROR_MSG if err_message.is_empty() else err_message
			Log.error(msg, module)


func success(arg: bool, err_message: String = "", module: String = "", warning: bool = false) -> bool:
	if not arg:
		if warning:
			var msg: String = DEFAULT_WARNING_MSG if err_message.is_empty() else err_message
			Log.warning(msg, module)
		else:
			var msg: String = DEFAULT_ERROR_MSG if err_message.is_empty() else err_message
			Log.error(msg, module)
		return false
	return true


func fail(arg: bool, err_message: String = "", module: String = "", warning: bool = false) -> bool:
	if not arg:
		if warning:
			var msg: String = DEFAULT_WARNING_MSG if err_message.is_empty() else err_message
			Log.warning(msg, module)
		else:
			var msg: String = DEFAULT_ERROR_MSG if err_message.is_empty() else err_message
			Log.error(msg, module)
		return true
	return false


func try_err(err: int, err_message: String = "", module: String = "", warning: bool = false) -> void:
	if err != OK:
		var msg: String = __get_err_string(err) if err_message.is_empty() else err_message
		if warning:
			Log.warning(msg, module)
		else:
			Log.error(msg, module)


func success_err(err: int, err_message: String = "", module: String = "", warning: bool = false) -> bool:
	if err != OK:
		var msg: String = __get_err_string(err) if err_message.is_empty() else err_message
		if warning:
			Log.warning(msg, module)
		else:
			Log.error(msg, module)
		return false
	return true


func fail_err(err: int, err_message: String = "", module: String = "", warning: bool = false) -> bool:
	if err != OK:
		var msg: String = __get_err_string(err) if err_message.is_empty() else err_message
		if warning:
			Log.warning(msg, module)
		else:
			Log.error(msg, module)
		return true
	return false


func try_resize(err: int, module: String = "") -> void:
	if err != OK:
		var msg: String = "Impossible to resize array (%s)." % error_string(err)
		Log.error(msg, module)


func try_append(arg: bool, module: String = "") -> void:
	if arg:
		var msg: String = "Impossible to append element to array."
		Log.error(msg, module)


func conn(signal_: Signal, callable: Callable, flags: int = 0, module: String = "") -> void:
	var err: int = signal_.connect(callable, flags)

	if err != OK:
		var msg: String = "Impossible to connect signal %s to method %s." % [signal_.get_name(), callable.get_method()]
		Log.error(msg, module)


func try_erase(arg: bool, module: String = "") -> void:
	if not arg:
		var msg: String = "Element not found while trying to make an erase operation."
		Log.warning(msg, module)

#endregion

# =============================================================
# ========= Callbacks =========================================


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================

func __get_err_string(err: int) -> String:
	return error_string(err) + " (%d)" % err


# =============================================================
# ========= Signal Callbacks ==================================
