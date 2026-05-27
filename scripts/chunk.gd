extends Node2D

# =====================================================
# CONFIG
# =====================================================
const TILE_SIZE := 32.0

# nanti gampang upgrade ke chunk 16x16
const CHUNK_WIDTH := 1
const CHUNK_HEIGHT := 1

# =====================================================
# NODE
# =====================================================
var mesh_instance: MeshInstance2D


# =====================================================
# INIT
# =====================================================
func _ready():
	create_mesh_node()
	build_chunk()


# =====================================================
# CREATE MESH NODE
# =====================================================
func create_mesh_node():
	mesh_instance = MeshInstance2D.new()
	add_child(mesh_instance)


# =====================================================
# MAIN BUILD CHUNK
# =====================================================
func build_chunk():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# sementara 1 tile dulu (nanti loop chunk)
	for x in range(CHUNK_WIDTH):
		for y in range(CHUNK_HEIGHT):
			add_tile(st, x, y)

	mesh_instance.mesh = st.commit()


# =====================================================
# TILE RENDER ENTRY
# =====================================================
func add_tile(st: SurfaceTool, x: int, y: int):
	var pos = iso_project(x, y)
	draw_iso_quad(st, pos)


# =====================================================
# ISOMETRIC PROJECTION
# =====================================================
func iso_project(x: float, y: float) -> Vector2:
	return Vector2(
		(x - y) * (TILE_SIZE * 0.5),
		(x + y) * (TILE_SIZE * 0.25)
	)


# =====================================================
# DRAW TILE QUAD (PURE RENDER LAYER)
# =====================================================
func draw_iso_quad(st: SurfaceTool, pos: Vector2):

	var top    = Vector3(pos.x, pos.y - TILE_SIZE * 0.25, 0)
	var right  = Vector3(pos.x + TILE_SIZE * 0.5, pos.y, 0)
	var bottom = Vector3(pos.x, pos.y + TILE_SIZE * 0.25, 0)
	var left   = Vector3(pos.x - TILE_SIZE * 0.5, pos.y, 0)

	# TRIANGLE 1
	st.set_uv(Vector2(0, 0)); st.add_vertex(top)
	st.set_uv(Vector2(1, 0)); st.add_vertex(right)
	st.set_uv(Vector2(1, 1)); st.add_vertex(bottom)

	# TRIANGLE 2
	st.set_uv(Vector2(0, 0)); st.add_vertex(top)
	st.set_uv(Vector2(1, 1)); st.add_vertex(bottom)
	st.set_uv(Vector2(0, 1)); st.add_vertex(left)