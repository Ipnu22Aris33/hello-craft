# world_generator.gd
class_name WorldGenerator
extends RefCounted

var terrain_noise := FastNoiseLite.new()
var biome_noise := FastNoiseLite.new()
var decoration_noise := FastNoiseLite.new()

var terrain_frequency := 0.005
var biome_frequency := 0.00005
var biome_detail_strength := 0.15

# ── SETUP ─────────────────────────────────────────────────────────────────────

func setup(active_seed: int) -> void:
	terrain_noise.seed = active_seed
	terrain_noise.frequency = terrain_frequency

	biome_noise.seed = active_seed + 100
	biome_noise.frequency = biome_frequency

	decoration_noise.seed = active_seed + 200
	decoration_noise.frequency = 0.1

# ── PUBLIC API ────────────────────────────────────────────────────────────────

func get_blocks(world_x: int, world_y: int) -> Dictionary:
	var terrain := terrain_noise.get_noise_2d(world_x, world_y)
	var biome_val := biome_noise.get_noise_2d(world_x, world_y)
	biome_val += terrain_noise.get_noise_2d(world_x, world_y) * biome_detail_strength

	var biome_name := BiomeRegistry.resolve_biome_name(biome_val)
	var biome := BiomeRegistry.get_biome(biome_name)

	var result := {"biome": biome_name, "ground": {}, "decoration": {}}

	# cek liquid dulu
	var liquid_tile := BiomeRegistry.resolve_tile(biome["liquid"], terrain)
	if liquid_tile != "":
		result["ground"] = AtlasRegistry.get_liquid(liquid_tile)
		return result # kalau liquid, tidak ada decoration

	# ground
	var ground_tile := BiomeRegistry.resolve_tile(biome["ground"], terrain)
	if ground_tile != "":
		result["ground"] = AtlasRegistry.get_ground(ground_tile)

	# decoration — hanya kalau ada ground
	if not result["ground"].is_empty():
		var deco_tile := BiomeRegistry.resolve_decoration(
			biome["decoration"], ground_tile, terrain, world_x, world_y, decoration_noise
		)
		if deco_tile != "":
			result["decoration"] = AtlasRegistry.get_decoration(deco_tile)

	return result
