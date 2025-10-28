##
## Benchmark
##
## Can do benchmarks.
##
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

var _benchmarks: Dictionary[StringName, BenchmarkData] = {}
var _def_benchmark: BenchmarkData = BenchmarkData.new()
var _cached_benchmark: BenchmarkData
var _cached: StringName


# =============================================================
# ========= Public Functions ==================================

func start(benchmark: StringName = &"") -> void:
	var b: BenchmarkData = _cached_benchmark if _cached == benchmark else __get_benchmark(benchmark)
	if b.running:
		Log.error("Trying to start %s benchmark, but is already running." % "Default" if benchmark.is_empty() else benchmark, "Benchmark")
		return
	b.running = true
	b.last_tick = Time.get_ticks_usec()


func stop(benchmark: StringName = &"") -> void:
	var b: BenchmarkData = _cached_benchmark if _cached == benchmark else __get_benchmark(benchmark)
	if not b.running:
		Log.error("Trying to stop %s benchmark, but it is not running." % "Default" if benchmark.is_empty() else benchmark, "Benchmark")
		return
	b.current_time += Time.get_ticks_usec() - b.last_tick
	var time_ms: float = float(b.current_time) / 1000.0
	if benchmark.is_empty():
		print("Benchmark: %d ms" % time_ms)
	else:
		print("Benchmark %s: %d ms" % [benchmark, time_ms])
	b.reset()


func pause(benchmark: StringName = &"") -> void:
	var b: BenchmarkData = _cached_benchmark if _cached == benchmark else __get_benchmark(benchmark)
	if not b.running:
		Log.error("Trying to pause %s benchmark, but it is not running." % "Default" if benchmark.is_empty() else benchmark, "Benchmark")
		return
	b.running = false
	b.current_time += Time.get_ticks_usec() - b.last_tick
	b.last_tick = -1


# =============================================================
# ========= Callbacks =========================================


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================

func __get_benchmark(benchmark: StringName) -> BenchmarkData:
	var b: BenchmarkData = null
	if benchmark.is_empty():
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
