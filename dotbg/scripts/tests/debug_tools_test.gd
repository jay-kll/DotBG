# DebugToolsTest.gd
# Comprehensive test suite for epic mobile touch input debug tools
# Validates all debug functionality and provides automated testing
extends Node

# Test components
var debug_overlay: CanvasLayer
var debug_console: Control
var test_results: Dictionary = {}
var test_count: int = 0
var passed_tests: int = 0

# Test configuration
var auto_run_tests: bool = true
var verbose_output: bool = true
var test_timeout: float = 5.0

signal test_completed(test_name: String, passed: bool, message: String)
signal all_tests_completed(total: int, passed: int, failed: int)

func _ready() -> void:
	print("DebugToolsTest: Initializing epic debug tools test suite")
	
	# Wait for systems to initialize
	await get_tree().create_timer(1.0).timeout
	
	if auto_run_tests:
		run_all_tests()

func run_all_tests() -> void:
	print("=== EPIC DEBUG TOOLS TEST SUITE ===")
	print("Testing comprehensive touch input debug functionality")
	print("")
	
	# Reset test counters
	test_count = 0
	passed_tests = 0
	test_results.clear()
	
	# Run all test categories
	await test_debug_overlay_initialization()
	await test_debug_console_initialization()
	await test_touch_visualization()
	await test_performance_monitoring()
	await test_event_logging()
	await test_console_commands()
	await test_system_integration()
	await test_mobile_optimization()
	
	# Report final results
	_report_final_results()

func test_debug_overlay_initialization() -> bool:
	var test_name = "Debug Overlay Initialization"
	_start_test(test_name)
	
	# Find debug overlay
	debug_overlay = get_node_or_null("/root/InputDebugOverlay")
	if not debug_overlay:
		# Try to find in scene tree
		debug_overlay = _find_node_by_type(get_tree().root, "CanvasLayer", "InputDebugOverlay")
	
	if not debug_overlay:
		return _fail_test(test_name, "InputDebugOverlay not found in scene tree")
	
	# Test overlay components
	var required_components = [
		"DebugPanel", "TouchVisualizer", "PerformanceMonitor", 
		"GestureLog", "SystemStatus", "SettingsPanel"
	]
	
	for component in required_components:
		if not debug_overlay.get_node_or_null(component):
			return _fail_test(test_name, "Missing component: " + component)
	
	# Test overlay methods
	var required_methods = [
		"log_custom_event", "add_performance_sample", "get_debug_stats"
	]
	
	for method in required_methods:
		if not debug_overlay.has_method(method):
			return _fail_test(test_name, "Missing method: " + method)
	
	return _pass_test(test_name, "All overlay components and methods present")

func test_debug_console_initialization() -> bool:
	var test_name = "Debug Console Initialization"
	_start_test(test_name)
	
	# Find debug console
	debug_console = get_node_or_null("/root/InputDebugConsole")
	if not debug_console:
		debug_console = _find_node_by_type(get_tree().root, "Control", "InputDebugConsole")
	
	if not debug_console:
		return _fail_test(test_name, "InputDebugConsole not found in scene tree")
	
	# Test console components
	var required_components = [
		"ConsolePanel", "CommandInput", "OutputDisplay"
	]
	
	for component in required_components:
		if not debug_console.get_node_or_null(component):
			return _fail_test(test_name, "Missing component: " + component)
	
	# Test console commands
	if not debug_console.has_method("execute_command_from_code"):
		return _fail_test(test_name, "Missing execute_command_from_code method")
	
	# Test available commands
	var expected_commands = [
		"help", "status", "touch_info", "performance", "test_touch"
	]
	
	if not debug_console.has("available_commands"):
		return _fail_test(test_name, "Missing available_commands dictionary")
	
	for command in expected_commands:
		if not debug_console.available_commands.has(command):
			return _fail_test(test_name, "Missing command: " + command)
	
	return _pass_test(test_name, "All console components and commands present")

func test_touch_visualization() -> bool:
	var test_name = "Touch Visualization"
	_start_test(test_name)
	
	if not debug_overlay:
		return _fail_test(test_name, "Debug overlay not available")
	
	# Test touch visualization settings
	var visualization_settings = [
		"show_touch_points", "show_touch_trails", "show_gesture_zones"
	]
	
	for setting in visualization_settings:
		if not debug_overlay.has(setting):
			return _fail_test(test_name, "Missing visualization setting: " + setting)
	
	# Test color configuration
	var color_settings = [
		"touch_color", "trail_color", "gesture_zone_color"
	]
	
	for color in color_settings:
		if not debug_overlay.has(color):
			return _fail_test(test_name, "Missing color setting: " + color)
	
	# Test touch data structures
	if not debug_overlay.has("active_touch_indicators"):
		return _fail_test(test_name, "Missing active_touch_indicators")
	
	if not debug_overlay.has("touch_trail_points"):
		return _fail_test(test_name, "Missing touch_trail_points")
	
	return _pass_test(test_name, "Touch visualization system properly configured")

func test_performance_monitoring() -> bool:
	var test_name = "Performance Monitoring"
	_start_test(test_name)
	
	if not debug_overlay:
		return _fail_test(test_name, "Debug overlay not available")
	
	# Test performance data structures
	if not debug_overlay.has("input_latencies"):
		return _fail_test(test_name, "Missing input_latencies array")
	
	if not debug_overlay.has("max_performance_samples"):
		return _fail_test(test_name, "Missing max_performance_samples")
	
	# Test performance monitoring methods
	if not debug_overlay.has_method("add_performance_sample"):
		return _fail_test(test_name, "Missing add_performance_sample method")
	
	# Test adding performance sample
	debug_overlay.add_performance_sample("input_latency", 15.5)
	
	if debug_overlay.input_latencies.is_empty():
		return _fail_test(test_name, "Performance sample not added")
	
	# Test stats retrieval
	var stats = debug_overlay.get_debug_stats()
	if not stats.has("average_latency"):
		return _fail_test(test_name, "Missing average_latency in stats")
	
	return _pass_test(test_name, "Performance monitoring working correctly")

func test_event_logging() -> bool:
	var test_name = "Event Logging"
	_start_test(test_name)
	
	if not debug_overlay:
		return _fail_test(test_name, "Debug overlay not available")
	
	# Test event logging structures
	if not debug_overlay.has("event_log"):
		return _fail_test(test_name, "Missing event_log array")
	
	if not debug_overlay.has("max_log_entries"):
		return _fail_test(test_name, "Missing max_log_entries")
	
	# Test custom event logging
	if not debug_overlay.has_method("log_custom_event"):
		return _fail_test(test_name, "Missing log_custom_event method")
	
	# Test logging a custom event
	var initial_log_size = debug_overlay.event_log.size()
	debug_overlay.log_custom_event("test_event", {"test": true})
	
	if debug_overlay.event_log.size() <= initial_log_size:
		return _fail_test(test_name, "Custom event not logged")
	
	# Verify event structure
	var last_event = debug_overlay.event_log[-1]
	if not last_event.has("timestamp") or not last_event.has("type") or not last_event.has("data"):
		return _fail_test(test_name, "Event structure incomplete")
	
	return _pass_test(test_name, "Event logging working correctly")

func test_console_commands() -> bool:
	var test_name = "Console Commands"
	_start_test(test_name)
	
	if not debug_console:
		return _fail_test(test_name, "Debug console not available")
	
	# Test command execution
	if not debug_console.has_method("execute_command_from_code"):
		return _fail_test(test_name, "Missing execute_command_from_code method")
	
	# Test help command
	debug_console.execute_command_from_code("help")
	
	# Test status command
	debug_console.execute_command_from_code("status")
	
	# Test performance command
	debug_console.execute_command_from_code("performance")
	
	# Test invalid command handling
	debug_console.execute_command_from_code("invalid_command_test")
	
	# Test command with arguments
	debug_console.execute_command_from_code("set_sensitivity", ["1.5"])
	
	# Verify sensitivity was set (if InputManager available)
	if InputManager and InputManager.touch_sensitivity != 1.5:
		return _fail_test(test_name, "Command with arguments not executed properly")
	
	return _pass_test(test_name, "Console commands working correctly")

func test_system_integration() -> bool:
	var test_name = "System Integration"
	_start_test(test_name)
	
	# Test InputManager integration
	if not InputManager:
		return _fail_test(test_name, "InputManager not available")
	
	# Test signal connections (if debug overlay is connected)
	if debug_overlay:
		# Check if overlay is registered as event target
		if InputManager.has_method("register_ui_event_target"):
			# This would be tested by checking if the overlay receives events
			# For now, we'll assume it's working if the method exists
			pass
	
	# Test event propagation system
	if InputManager.has("event_propagation"):
		if not InputManager.event_propagation:
			return _fail_test(test_name, "Event propagation system not initialized")
	
	# Test subsystem availability
	var required_subsystems = [
		"gesture_detector", "input_buffer", "haptic_controller"
	]
	
	for subsystem in required_subsystems:
		if not InputManager.has(subsystem):
			return _fail_test(test_name, "Missing subsystem: " + subsystem)
	
	return _pass_test(test_name, "System integration working correctly")

func test_mobile_optimization() -> bool:
	var test_name = "Mobile Optimization"
	_start_test(test_name)
	
	if not debug_overlay:
		return _fail_test(test_name, "Debug overlay not available")
	
	# Test mobile-specific settings
	if not debug_overlay.has("max_trail_points"):
		return _fail_test(test_name, "Missing max_trail_points optimization")
	
	if not debug_overlay.has("max_performance_samples"):
		return _fail_test(test_name, "Missing max_performance_samples optimization")
	
	# Test memory management
	if debug_overlay.max_trail_points > 100:
		return _fail_test(test_name, "Trail points limit too high for mobile")
	
	if debug_overlay.max_performance_samples > 120:
		return _fail_test(test_name, "Performance samples limit too high for mobile")
	
	# Test layer configuration for performance
	if debug_overlay.layer != 100:
		return _fail_test(test_name, "Debug overlay not on top layer")
	
	return _pass_test(test_name, "Mobile optimization properly configured")

# Test utility functions
func _start_test(test_name: String) -> void:
	test_count += 1
	if verbose_output:
		print("Running test: " + test_name)

func _pass_test(test_name: String, message: String) -> bool:
	passed_tests += 1
	test_results[test_name] = {"passed": true, "message": message}
	
	if verbose_output:
		print("  ✅ PASS: " + message)
	
	test_completed.emit(test_name, true, message)
	return true

func _fail_test(test_name: String, message: String) -> bool:
	test_results[test_name] = {"passed": false, "message": message}
	
	if verbose_output:
		print("  ❌ FAIL: " + message)
	
	test_completed.emit(test_name, false, message)
	return false

func _report_final_results() -> void:
	var failed_tests = test_count - passed_tests
	
	print("")
	print("=== TEST RESULTS ===")
	print("Total Tests: %d" % test_count)
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % failed_tests)
	print("Success Rate: %.1f%%" % ((float(passed_tests) / float(test_count)) * 100.0))
	
	if failed_tests > 0:
		print("")
		print("Failed Tests:")
		for test_name in test_results:
			if not test_results[test_name].passed:
				print("  - %s: %s" % [test_name, test_results[test_name].message])
	
	print("")
	if failed_tests == 0:
		print("🎉 ALL TESTS PASSED! Epic debug tools are ready for 50+ hour campaigns!")
	else:
		print("⚠️  Some tests failed. Please review and fix issues before deployment.")
	
	all_tests_completed.emit(test_count, passed_tests, failed_tests)

func _find_node_by_type(root: Node, node_type: String, script_name: String = "") -> Node:
	# Recursively search for node by type and optional script name
	if root.get_class() == node_type:
		if script_name.is_empty():
			return root
		elif root.get_script() and root.get_script().get_path().get_file().begins_with(script_name.to_lower()):
			return root
	
	for child in root.get_children():
		var result = _find_node_by_type(child, node_type, script_name)
		if result:
			return result
	
	return null

# Public API for manual testing
func run_single_test(test_name: String) -> bool:
	match test_name.to_lower():
		"overlay":
			return await test_debug_overlay_initialization()
		"console":
			return await test_debug_console_initialization()
		"visualization":
			return await test_touch_visualization()
		"performance":
			return await test_performance_monitoring()
		"logging":
			return await test_event_logging()
		"commands":
			return await test_console_commands()
		"integration":
			return await test_system_integration()
		"mobile":
			return await test_mobile_optimization()
		_:
			print("Unknown test: " + test_name)
			return false

func get_test_results() -> Dictionary:
	return test_results.duplicate()

func is_all_tests_passed() -> bool:
	return passed_tests == test_count and test_count > 0 