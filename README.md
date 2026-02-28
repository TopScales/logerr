# LogErr

Lightweight Godot addon that provides a configurable `Log` logger, an `Err` helper
for compact error handling, and a small `Benchmark` helper for quick measurements.

## Features

- **Logger**: `Log` prints formatted messages to the normal output, stores logs to a
	file (optional), and can write to a `RichTextLabel` with colorized, module-aware
	formatting.
- **Error helper**: `Err` autoload provides compact helpers (`try`, `success`,
	`try_err`, `success_err`, etc.) to check and report common errors without
	cluttering call sites.
- **Benchmark tool**: `Benchmark` autoload offers `start`, `stop`, and `pause` to
	measure elapsed time for named or default benchmarks.

## Installation

1. Copy the content of this repository into your project under `res://addons/logerr`.
2. In the Godot editor enable the plugin from `Project -> Project Settings -> Plugins`.
3. The plugin add two autoload singletons automatically when enabled: `Err` and `Benchmark`.

**NOTE**: For practicality, the `Log` class is registered even with the addon disabled.

## Quick Start

Set a `RichTextLabel` to receive formatted messages (optional):

```gdscript
func _ready():
		Log.set_console($RichTextLabel) # pass a RichTextLabel node
		Log.info("LogErr ready", "Main")
```

Basic logging:

```gdscript
Log.verbose("Detailed message", "Module")
Log.debug("Debug info", "Module")
Log.info("General info", "Module")
Log.warning("A warning happened", "Module")
Log.error("An error happened", "Module")
Log.critical("Critical failure", "Module")

# Force any buffered file logging to flush to disk
Log.force_flush()
```

Use the `Err` helper for concise error checking:

```gdscript
# Prints an error if the boolean is false
Err.try(some_condition, "Could not execute order.", "Loader")

# Check engine return codes (OK / error codes)
if Err.fail_err(err_code, "This failed.", "Module"):
		return
```

Use `Benchmark` to measure small code sections:

```gdscript
Benchmark.start("load")
# ... work to measure ...
Benchmark.stop("load")

# Default unnamed benchmark
Benchmark.start()
Benchmark.stop()
```

## Settings

Project settings are registered under the `addons/logerr/` prefix. Notable
settings include:

- `addons/logerr/output_level` — logger output level (Verbose, Debug, Info, ...)
- `addons/logerr/print_backtrace` — whether to append GDScript backtraces to
	error/critical messages (default: true)
- `addons/logerr/enable_file_logging` — enable writing logs to disk (default: true for PC, false for others)
- `addons/logerr/colors/*` — color overrides for tags and text per level

File logging respects `debug/file_logging/log_path` for the log file location
and the plugin uses `debug/file_logging/max_log_files` to rotate old logs.

## Notes

- The plugin registers the `Log` instance with `OS.add_logger` so it receives
	engine/print messages too.
- When enabled the plugin will add autoloads named `Err` and `Benchmark` that map
	to `autoload/err.gd` and `autoload/benchmark.gd` respectively.
- To present colored messages inside the game, use a `RichTextLabel` and
	call `Log.set_console()` with the node reference.

## License

Distributed under the [MIT license](https://opensource.org/license/MIT).

## Contributing / Support

If you find issues or want features, open an issue or a PR in the repository.
Thanks for using LogErr!
