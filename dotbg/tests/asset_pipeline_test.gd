extends SceneTree

# Proves the Blender-to-Godot art pipeline end to end.
#
# Phase 3 is the roadmap's stated bottleneck and everything after it depends on
# throughput proven here. The question this answers is narrow and load-bearing:
# does a parametrically generated kit piece survive export, import, and arrive
# in the engine with its dimensions, its triangles, its UVs and its material
# intact? Every one of those is something the corruption shader or the modular
# grid will need.
#
# The asset is produced by art/gen/probe_arch.py. Regenerate with:
#
#   tools\\blender.ps1 -Script art\\gen\\probe_arch.py
#
# The dimension assertions are tight on purpose. A modular kit lives or dies on
# exact sizes: pieces must tile on a grid and weld at the seams, and a
# millimetre of drift per piece compounds across a room. Godot's glTF import
# has historically applied scale conversions, so "it imported" is not the same
# claim as "it is the size we built".

const ASSET := "res://assets/probe/arch.glb"

# Matches art/gen/probe_arch.py.
const SPAN := 2.0
const DEPTH := 0.35
const RISE := 2.4
const TOLERANCE := 0.005

var checks := 0
var failures := 0


func check(label: String, condition: bool, detail: String = "") -> void:
	checks += 1
	if not condition:
		failures += 1
	print("  %s  %s" % ["PASS" if condition else "FAIL", label])
	if detail != "":
		print("    " + detail)


func _process(_delta: float) -> bool:
	print("=== asset_pipeline_test: start ===")

	check("the generated asset exists in the project", FileAccess.file_exists(ASSET), ASSET)
	if not FileAccess.file_exists(ASSET):
		print("    run: tools\\blender.ps1 -Script art\\gen\\probe_arch.py")
		_report()
		return true

	var packed: PackedScene = load(ASSET)
	check("Godot imported the glTF as a scene", packed != null)
	if packed == null:
		_report()
		return true

	var node := packed.instantiate()
	root.add_child(node)

	var mesh_instance := _find_mesh(node)
	check("the scene contains a MeshInstance3D", mesh_instance != null)
	if mesh_instance == null:
		_report()
		return true

	var mesh := mesh_instance.mesh
	check("it carries an actual mesh", mesh != null and mesh.get_surface_count() > 0,
		"%d surface(s)" % (mesh.get_surface_count() if mesh != null else 0))
	if mesh == null or mesh.get_surface_count() == 0:
		_report()
		return true

	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]

	check("geometry survived the round trip", vertices.size() > 0 and indices.size() > 0,
		"%d vertices, %d triangles" % [vertices.size(), indices.size() / 3])

	# Without UVs the corruption shader has nothing to sample and every surface
	# in the kit is flat colour for the rest of the project.
	check("UVs survived the round trip", uvs.size() == vertices.size(),
		"%d UV pairs for %d vertices" % [uvs.size(), vertices.size()])

	check("the material came through", mesh.surface_get_material(0) != null,
		str(mesh.surface_get_material(0)))

	# Axis convention, and it is not cosmetic. Blender is Z-up, Godot is Y-up,
	# and the glTF exporter converts on the way out: what the generator builds
	# along Z arrives along Y, and Blender's Y depth arrives as Godot's Z. Every
	# kit generator has to be written knowing this, because the failure mode is
	# an arch lying on its back that still passes a "did it import" check.
	var aabb: AABB = mesh.get_aabb()
	check("span survives as Godot X", absf(aabb.size.x - SPAN) < TOLERANCE,
		"%.4f m against a %.4f m nominal span" % [aabb.size.x, SPAN])
	check("Blender's Z rise arrives as Godot's Y height",
		absf(aabb.size.y - RISE) < TOLERANCE,
		"%.4f m against %.4f m" % [aabb.size.y, RISE])
	check("Blender's Y depth arrives as Godot's Z",
		absf(aabb.size.z - DEPTH) < TOLERANCE,
		"%.4f m against %.4f m" % [aabb.size.z, DEPTH])

	# Against a 2 m player capsule. If the importer applied a unit conversion
	# this is where it would show, as an arch a hundred times too big to walk
	# through, or one the player would step over.
	check("the piece is the right size for the player to walk under",
		aabb.size.y > 1.8 and aabb.size.y < 4.0,
		"%.2f m tall against a 2 m capsule" % aabb.size.y)
	check("the arch stands up rather than lying on its back",
		aabb.size.y > aabb.size.z,
		"%.2f m tall, %.2f m deep" % [aabb.size.y, aabb.size.z])

	_check_free_material()

	_report()
	return true


## The other half of the Phase 3 pipeline: surfaces we did not have to generate.
##
## The kit's geometry is parametric, but its stonework is texture, and paying a
## generation service for tileable PBR is unnecessary — CC0 libraries already
## have it. This asserts the sourced material is present, imports, and is the
## resolution it claims, so a truncated download or a silently failed import
## fails here rather than as flat grey geometry three weeks into Phase 3.
func _check_free_material() -> void:
	print("-- sourced CC0 material --")
	var maps := {
		"colour": "res://assets/materials/bricks089/bricks089_color.jpg",
		"roughness": "res://assets/materials/bricks089/bricks089_roughness.jpg",
		"normal": "res://assets/materials/bricks089/bricks089_normalgl.jpg",
	}
	for name in maps:
		var tex: Texture2D = load(maps[name])
		check("the %s map imports" % name, tex != null and tex.get_width() > 0,
			"%dx%d" % [tex.get_width(), tex.get_height()] if tex != null else "failed to load")
		if tex != null:
			check("the %s map is 1K as sourced" % name, tex.get_width() == 1024,
				"%d px" % tex.get_width())

	# Provenance is not optional, and a downloaded asset needs it more than a
	# generated one: without the recorded licence nobody can tell six months
	# later whether this is safe to ship.
	var sidecar := "res://assets/materials/bricks089/bricks089.json"
	check("the material carries its provenance and licence", FileAccess.file_exists(sidecar),
		sidecar)
	if FileAccess.file_exists(sidecar):
		var meta: Variant = JSON.parse_string(FileAccess.get_file_as_string(sidecar))
		check("the licence is recorded as CC0 and attribution-free",
			meta is Dictionary
				and str(meta.get("license", "")).begins_with("CC0")
				and meta.get("attribution_required", true) == false,
			str(meta.get("license", "missing")) if meta is Dictionary else "unparsable")


func _find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found := _find_mesh(child)
		if found != null:
			return found
	return null


func _report() -> void:
	print("=== asset_pipeline_test: %d checks, %d failures ===" % [checks, failures])
	print("RESULT: " + ("PASS" if failures == 0 else "FAIL"))
	quit(1 if failures > 0 else 0)
