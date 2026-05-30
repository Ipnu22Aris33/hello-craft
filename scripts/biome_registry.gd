# biome_registry.gd
extends Node

const BIOMES := {
	"normal": {
		"biome_threshold": {"min": -0.25, "max": 0.25},
		"ground": [
			{"threshold": INF, "tile": "grass_block"},
		],
		"liquid": [
			{"threshold": -0.5, "tile": "water"},
		],
		"decoration": [
			{"tile": "bush", "ground": "grass_block", "threshold": 0.5, "density": 0.50},
		],
	},
	"cold": {
		"biome_threshold": {"min": -INF, "max": -0.25},
		"ground": [
			{"threshold": -0.1, "tile": "snow"},
			{"threshold": INF,  "tile": "dirt_snow"},
		],
		"liquid": [
			{"threshold": 0.3, "tile": "ice"},
		],
		"decoration": [],
	},
	"hot": {
		"biome_threshold": {"min": 0.25, "max": INF},
		"ground": [
			{"threshold": -0.3, "tile": "sand"},
			{"threshold": INF,  "tile": "grass_block"},
		],
		"liquid": [
			{"threshold": 0.1, "tile": "lava"},
		],
		"decoration": [],
	}
}

func get_biome(biome_name: String) -> Dictionary:
	return BIOMES.get(biome_name, {})

func resolve_biome_name(biome_value: float) -> String:
	for biome_name in BIOMES:
		var t: Dictionary = BIOMES[biome_name]["biome_threshold"]
		if biome_value >= t["min"] and biome_value < t["max"]:
			return biome_name
	return "normal"

func resolve_tile(entries: Array, terrain: float) -> String:
	for entry in entries:
		if terrain < entry["threshold"]:
			return entry["tile"]
	return ""

func resolve_decoration(entries: Array, ground_tile: String, terrain: float, world_x: int, world_y: int, noise: FastNoiseLite) -> String:
	for deco in entries:
		if deco["ground"] != ground_tile:
			continue
		if terrain >= deco["threshold"]:
			continue
		var val := (noise.get_noise_2d(world_x, world_y) + 1.0) / 2.0
		if val < deco["density"]:
			return deco["tile"]
	return ""