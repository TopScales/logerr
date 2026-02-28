##
## Class that allows to easily make benchmarks.
##
## The functionality is very basic. Benchmarks can be named to allow making
## several benchmarks at the same time. Whenever a benchmark is finished using
## the [method stop] function, a message showing the elapsed time is displayed.
##
@tool
extends Node


class BenchmarkData:
	var running: bool = false
	var current_time: int = 0
	var last_tick: int = -1

	func reset() -> void:
		running = false
		current_time = 0
		last_tick = -1


const _MODULE: StringName = &"Benchmark"
const _DEFAULT_BENCHMARK: StringName = &"Default"

var _benchmarks: Dictionary[StringName, BenchmarkData] = {}
var _def_benchmark: BenchmarkData = BenchmarkData.new()
var _cached_benchmark: BenchmarkData
var _cached: StringName

# =============================================================
# ========= Public Functions ==================================


## Start a benchmark tagged as [param benchmark]. If the benchmark was
## previously paused, it will resume.
func start(benchmark: StringName = &"") -> void:
	var b: BenchmarkData = __get_benchmark(benchmark)

	if b.running:
		Log.error("Trying to start %s benchmark, but is already running." % _cached, _MODULE)
		return

	b.running = true
	b.last_tick = Time.get_ticks_usec()


## Stop the benchmark tagged as [param benchmark] and display the elapsed time.
func stop(benchmark: StringName = &"") -> void:
	var b: BenchmarkData = __get_benchmark(benchmark)

	if not b.running:
		Log.error("Trying to stop %s benchmark, but it is not running." % _cached, _MODULE)
		return

	b.current_time += Time.get_ticks_usec() - b.last_tick
	var time_ms: float = float(b.current_time) / 1000.0

	if benchmark.is_empty():
		print("Benchmark: %d ms" % time_ms)
	else:
		print("Benchmark %s: %d ms" % [benchmark, time_ms])

	b.reset()


## Pause the benchmark tagged as [param benchmark].
func pause(benchmark: StringName = &"") -> void:
	var b: BenchmarkData = __get_benchmark(benchmark)

	if not b.running:
		Log.error("Trying to pause %s benchmark, but it is not running." % _cached, _MODULE)
		return

	b.running = false
	b.current_time += Time.get_ticks_usec() - b.last_tick
	b.last_tick = -1


# =============================================================
# ========= Built-in Functions ================================

# =============================================================
# ========= Virtual Methods ===================================

# =============================================================
# ========= Private Functions =================================


func __get_benchmark(benchmark: StringName) -> BenchmarkData:
	if benchmark.is_empty():
		benchmark = _DEFAULT_BENCHMARK

	if _cached == benchmark:
		return _cached_benchmark

	var b: BenchmarkData = null
	if benchmark == _DEFAULT_BENCHMARK:
		b = _def_benchmark
	else:
		b = _benchmarks.get(benchmark, null)
		if not b:
			b = BenchmarkData.new()
			_benchmarks[benchmark] = b
	_cached_benchmark = b
	_cached = benchmark
	return b

# =============================================================
# ========= Signal Callbacks ==================================
