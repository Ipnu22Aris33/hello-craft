extends Node2D

@export var chunk_scene: PackedScene
@export var noise: FastNoiseLite
@export var biome_noise: FastNoiseLite

@export var player_scene: PackedScene
@onready var player = $Player

@export var biome_scale: float = 0.005 # ukuran biome
@export var biome_count: int = 3 # berapa biome muncul (1-5)

@export var world_seed: int = 0

@onready var ground := $Ground
@onready var chunks := $Chunks

var active_biomes: Array = []

const WORLD_SIZE := 8

func _ready():
	
	var p = player_scene.instantiate()
	add_child(p)
	var active_seed := world_seed if world_seed != 0 else randi()
	print("world seed: ", active_seed)

	# set global seed supaya shuffle dan randi_range deterministik
	seed(active_seed)

	var all_biomes := ["normal", "cold", "hot"]
	all_biomes.shuffle()
	var count := randi_range(1, all_biomes.size())
	active_biomes = all_biomes.slice(0, count)
	print("active biomes: ", active_biomes)

	if noise == null:
		noise = FastNoiseLite.new()
		noise.seed = active_seed
		noise.frequency = 0.001

	if biome_noise == null:
		biome_noise = FastNoiseLite.new()
		biome_noise.seed = active_seed + 1
		biome_noise.frequency = biome_scale

	var half := WORLD_SIZE >> 2
	for x in range(-half, half):
		for y in range(-half, half):
			spawn_chunk(Vector2i(x, y))

func spawn_chunk(chunk_pos: Vector2i):
	var chunk = chunk_scene.instantiate()
	chunk.chunk_position = chunk_pos
	chunks.add_child(chunk)
	chunk.generate(self )

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
			else:
				return AtlasRegistry.get_ground("dirt_snow")
		"hot":
			if n < 0.1:
				return AtlasRegistry.get_ground("sand")
			else:
				return AtlasRegistry.get_ground("grass")
		_:
			if n < -0.2:
				return AtlasRegistry.get_ground("grass")
			elif n < 0.2:
				return AtlasRegistry.get_ground("grass")
			else:
				return AtlasRegistry.get_ground("stone")

func set_cell(cell: Vector2i, atlas_id: int, atlas_coord: Vector2i):
	ground.set_cell(cell, atlas_id, atlas_coord)
