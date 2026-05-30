# world.gd
extends Node2D

# Constants
const CHUNK_SIZE := 16

# Exports
@export var render_distance := 4
@export var chunk_scene: PackedScene
@export var player_scene: PackedScene
@export var world_seed := 0

# Nodes
@onready var ground := $Ground
@onready var decoration := $Decoration
var player: Node2D

# Generator
var world_generator := WorldGenerator.new()

# Chunks
var loaded_chunks := {}
var current_chunk := Vector2i(999999, 999999)
var last_tile := Vector2i(999999, 999999)

# ── READY ─────────────────────────────────────────────────────────────────────

func _ready() -> void:
	var active_seed := world_seed if world_seed != 0 else randi()
	seed(active_seed)
	world_generator.setup(active_seed)

	

	player = player_scene.instantiate()
	player.world = self
	add_child(player)

# ── PROCESS ───────────────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	_update_player_effect()
	_update_chunks()

# ── PLAYER EFFECT ─────────────────────────────────────────────────────────────

func _update_player_effect() -> void:
	if player == null:
		return
	var cell = ground.local_to_map(player.global_position)
	var blocks := world_generator.get_blocks(cell.x, cell.y)
	player.apply_block_effect(blocks["ground"])

# ── TILEMAP ───────────────────────────────────────────────────────────────────

func set_ground_cell(cell: Vector2i, atlas_id: int, atlas_coord: Vector2i) -> void:
	ground.set_cell(cell, atlas_id, atlas_coord)

func set_decoration_cell(cell: Vector2i, atlas_id: int, atlas_coord: Vector2i) -> void:
	decoration.set_cell(cell, atlas_id, atlas_coord)

# ── CHUNKS ────────────────────────────────────────────────────────────────────

func _update_chunks() -> void:
	var tile_pos = ground.local_to_map(player.global_position)

	if tile_pos != last_tile:
		last_tile = tile_pos
		print(tile_pos)

	var player_chunk := Vector2i(
		floori(float(tile_pos.x) / CHUNK_SIZE),
		floori(float(tile_pos.y) / CHUNK_SIZE)
	)

	if player_chunk == current_chunk:
		return

	current_chunk = player_chunk

	for x in range(player_chunk.x - render_distance, player_chunk.x + render_distance + 1):
		for y in range(player_chunk.y - render_distance, player_chunk.y + render_distance + 1):
			var chunk_pos := Vector2i(x, y)
			if loaded_chunks.has(chunk_pos):
				continue
			_load_chunk(chunk_pos)

	var to_remove: Array[Vector2i] = []
	for chunk_pos in loaded_chunks.keys():
		var dx = abs(chunk_pos.x - player_chunk.x)
		var dy = abs(chunk_pos.y - player_chunk.y)
		if dx > render_distance or dy > render_distance:
			if loaded_chunks[chunk_pos].has_method("clear"):
				loaded_chunks[chunk_pos].clear(self )
			to_remove.append(chunk_pos)

	for chunk_pos in to_remove:
		loaded_chunks.erase(chunk_pos)

func _load_chunk(chunk_pos: Vector2i) -> void:
	var chunk := chunk_scene.instantiate()
	chunk.chunk_position = chunk_pos
	chunk.generate(self )
	loaded_chunks[chunk_pos] = chunk
