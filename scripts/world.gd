extends Node2D

const CHUNK_SIZE := 16

@export var chunk_scene: PackedScene
@export var noise: FastNoiseLite
@export var biome_noise: FastNoiseLite
@export var player_scene: PackedScene
@export var biome_scale := 0.005
@export var world_seed := 0

@onready var ground := $Ground

var player: Node2D
var loaded_chunks := {}
var active_biomes: Array = []
var current_chunk := Vector2i(999999, 999999)
var last_tile := Vector2i(999999, 999999)

func _ready():
	var active_seed := world_seed if world_seed != 0 else randi()
	seed(active_seed)

	var all_biomes := ["normal", "cold", "hot"]
	all_biomes.shuffle()
	var count := randi_range(1, all_biomes.size())
	active_biomes = all_biomes.slice(0, count)

	if noise == null:
		noise = FastNoiseLite.new()
		noise.seed = active_seed
		noise.frequency = 0.01

	if biome_noise == null:
		biome_noise = FastNoiseLite.new()
		biome_noise.seed = active_seed + 1
		biome_noise.frequency = biome_scale

	player = player_scene.instantiate()
	add_child(player)

func _process(_delta: float) -> void:
	var tile_pos = ground.local_to_map(player.global_position)
	
	if tile_pos != last_tile:
		last_tile = tile_pos
		print("tile: ", tile_pos)
	
	var player_chunk := Vector2i(
		int(floor(float(tile_pos.x) / CHUNK_SIZE)),
		int(floor(float(tile_pos.y) / CHUNK_SIZE))
	)

	if player_chunk == current_chunk:
		return

	current_chunk = player_chunk

	if not loaded_chunks.has(player_chunk):
		load_chunk(player_chunk)


func load_chunk(chunk_pos: Vector2i) -> void:
	var chunk = chunk_scene.instantiate()
	chunk.chunk_position = chunk_pos
	chunk.generate(self )
	loaded_chunks[chunk_pos] = chunk

func get_biome(biome_val: float) -> String:
	var step := 2.0 / active_biomes.size()
	var index = clamp(int((biome_val + 1.0) / step), 0, active_biomes.size() - 1)
	return active_biomes[index]

func get_block(world_x: int, world_y: int) -> Dictionary:
	var n := noise.get_noise_2d(world_x, world_y)
	var biome := biome_noise.get_noise_2d(world_x, world_y)

	match get_biome(biome):
		"cold":
			if n < 0.1:
				return AtlasRegistry.get_ground("snow")
			return AtlasRegistry.get_ground("dirt_snow")
		"hot":
			if n < 0.1:
				return AtlasRegistry.get_ground("sand")
			return AtlasRegistry.get_ground("grass")
		_:
			if n < -0.2:
				return AtlasRegistry.get_ground("grass")
			elif n < 0.2:
				return AtlasRegistry.get_ground("dirt")
			return AtlasRegistry.get_ground("stone")

func set_cell(cell: Vector2i, atlas_id: int, atlas_coord: Vector2i) -> void:
	ground.set_cell(cell, atlas_id, atlas_coord)