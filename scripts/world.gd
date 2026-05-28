extends Node2D

# Constants
const CHUNK_SIZE := 16

# Exports
@export var render_distance := 4
@export var chunk_scene: PackedScene
@export var player_scene: PackedScene
@export var world_seed := 0
@export var terrain_frequency := 0.005
@export var biome_frequency := 0.00005
@export_range(0.0, 1.0) var biome_detail_strength := 0.15

# Noise
var terrain_noise := FastNoiseLite.new()
var biome_noise := FastNoiseLite.new()

# Nodes
@onready var ground := $Ground
var player: Node2D

# Chunks
var loaded_chunks := {}
var current_chunk := Vector2i(999999, 999999)
var last_tile := Vector2i(999999, 999999)

func _ready():
	var active_seed := world_seed if world_seed != 0 else randi()
	seed(active_seed)
	
	terrain_noise.seed = active_seed
	terrain_noise.frequency = terrain_frequency
	
	biome_noise.seed = active_seed + 100
	biome_noise.frequency = biome_frequency
	
	player = player_scene.instantiate()
	player.world = self
	add_child(player)

func _process(_delta: float) -> void:
	_update_player_effect()
	_update_chunks()

func _update_player_effect():
	if player == null:
		return
	
	var cell: Vector2i = ground.local_to_map(player.global_position)
	var block := get_block(cell.x, cell.y)
	player.apply_block_effect(block)

# -------------------------------------------------
# GET BLOCK (sumber tunggal kebenaran)
# -------------------------------------------------
func get_block(world_x: int, world_y: int) -> Dictionary:
	var terrain := terrain_noise.get_noise_2d(world_x, world_y)
	var biome := get_biome(world_x, world_y)
	
	# Cold biome
	if biome == "cold":
		if terrain < 0.1:
			return AtlasRegistry.get_ground("snow")
		elif terrain < 0.2 and terrain > -0.2:
			return AtlasRegistry.get_liquid("ice")
		return AtlasRegistry.get_ground("dirt_snow")
	
	# Hot biome
	if biome == "hot":
		if terrain < 0.1:
			return AtlasRegistry.get_ground("sand")
		elif terrain < 0.2 and terrain > -0.2:
			return AtlasRegistry.get_liquid("lava")
		return AtlasRegistry.get_ground("grass")
	
	# Normal biome
	if terrain < -0.2:
		return AtlasRegistry.get_ground("grass")
	elif terrain < 0.2:
		return AtlasRegistry.get_liquid("water")
	return AtlasRegistry.get_ground("stone")

func get_biome(world_x: int, world_y: int) -> String:
	var biome := biome_noise.get_noise_2d(world_x, world_y)
	biome += terrain_noise.get_noise_2d(world_x, world_y) * biome_detail_strength
	
	if biome < -0.25:
		return "cold"
	elif biome > 0.25:
		return "hot"
	return "normal"

func set_cell(cell: Vector2i, atlas_id: int, atlas_coord: Vector2i) -> void:
	ground.set_cell(cell, atlas_id, atlas_coord)

# -------------------------------------------------
# CHUNK
# -------------------------------------------------
func _update_chunks():
	var tile_pos: Vector2i = ground.local_to_map(player.global_position)
	
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
			load_chunk(chunk_pos)
	
	var to_remove := []
	for chunk_pos in loaded_chunks.keys():
		var dx: int = abs(chunk_pos.x - player_chunk.x)
		var dy: int = abs(chunk_pos.y - player_chunk.y)
		
		if dx > render_distance or dy > render_distance:
			if loaded_chunks[chunk_pos].has_method("clear"):
				loaded_chunks[chunk_pos].clear(self )
			to_remove.append(chunk_pos)
	
	for chunk_pos in to_remove:
		loaded_chunks.erase(chunk_pos)

func load_chunk(chunk_pos: Vector2i) -> void:
	var chunk := chunk_scene.instantiate()
	chunk.chunk_position = chunk_pos
	chunk.generate(self )
	loaded_chunks[chunk_pos] = chunk