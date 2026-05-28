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

# --- Initialization ---
func _ready():
	var active_seed := world_seed if world_seed != 0 else randi()
	seed(active_seed)
	
	terrain_noise.seed = active_seed
	terrain_noise.frequency = terrain_frequency
	
	biome_noise.seed = active_seed + 100
	biome_noise.frequency = biome_frequency
	
	player = player_scene.instantiate()
	add_child(player)

# --- Chunk management ---
func _process(_delta: float) -> void:
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
	
	# Load chunks
	for x in range(player_chunk.x - render_distance, player_chunk.x + render_distance + 1):
		for y in range(player_chunk.y - render_distance, player_chunk.y + render_distance + 1):
			var chunk_pos := Vector2i(x, y)
			if loaded_chunks.has(chunk_pos):
				continue
			load_chunk(chunk_pos)
	
	# Unload chunks
	var to_remove := []
	for chunk_pos in loaded_chunks.keys():
		var dx: int = abs(chunk_pos.x - player_chunk.x)
		var dy: int = abs(chunk_pos.y - player_chunk.y)
		
		if dx > render_distance or dy > render_distance:
			loaded_chunks[chunk_pos].clear(self )
			to_remove.append(chunk_pos)
	
	for chunk_pos in to_remove:
		loaded_chunks.erase(chunk_pos)

# --- Chunk loading ---
func load_chunk(chunk_pos: Vector2i) -> void:
	var chunk := chunk_scene.instantiate()
	chunk.chunk_position = chunk_pos
	chunk.generate(self )
	loaded_chunks[chunk_pos] = chunk

# --- Biome detection ---
func get_biome(world_x: int, world_y: int) -> String:
	var biome := biome_noise.get_noise_2d(world_x, world_y)
	
	biome += terrain_noise.get_noise_2d(world_x, world_y) * biome_detail_strength
	
	if biome < -0.25:
		return "cold"
	elif biome > 0.25:
		return "hot"
	return "normal"

# --- Block type ---
func get_block(world_x: int, world_y: int) -> Dictionary:
	var terrain := terrain_noise.get_noise_2d(world_x, world_y)
	
	match get_biome(world_x, world_y):
		"cold":
			if terrain < 0.1:
				return AtlasRegistry.get_ground("snow")
			return AtlasRegistry.get_ground("dirt_snow")
		"hot":
			if terrain < 0.1:
				return AtlasRegistry.get_ground("sand")
			return AtlasRegistry.get_ground("grass")
		_:
			if terrain < -0.2:
				return AtlasRegistry.get_ground("grass")
			elif terrain < 0.2:
				return AtlasRegistry.get_liquid("water")
			return AtlasRegistry.get_ground("stone")

# --- Cell setter ---
func set_cell(cell: Vector2i, atlas_id: int, atlas_coord: Vector2i) -> void:
	ground.set_cell(cell, atlas_id, atlas_coord)
