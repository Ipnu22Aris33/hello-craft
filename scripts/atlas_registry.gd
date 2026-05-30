extends Node

const GROUNDS := {
	0: {
		"grass": {"atlas_coord": Vector2i(0, 0), "replaceable": true},
		"dirt": {"atlas_coord": Vector2i(4, 1), "replaceable": true},
		"sand": {"atlas_coord": Vector2i(2, 0), "replaceable": true},
		"snow": {"atlas_coord": Vector2i(3, 0), "replaceable": true},
		"dirt_snow": {"atlas_coord": Vector2i(4, 0), "replaceable": true},
		"stone": {"atlas_coord": Vector2i(0, 1), "replaceable": false},
	},
	1: {
		"grass_block": {"atlas_coord": Vector2i(2, 2), "replaceable": true},
		"dirt_block": {"atlas_coord": Vector2i(3, 2), "replaceable": true},
		"sand_block": {"atlas_coord": Vector2i(4, 2), "replaceable": true},
	}
}

const LIQUIDS := {
	1: {
		"water": {
			"atlas_coord": Vector2i(10, 10),
			"replaceable": false,
			"effect": {
				"speed_mult": 0.5,
				"visual_offset": 10.0
			}
		},
		"lava": {
			"atlas_coord": Vector2i(1, 0),
			"replaceable": false,
			"effect": {
				"speed_mult": 0.3,
				"visual_offset": 5.0,
				"damage": 10.0
			}
		},
		"ice": {
			"atlas_coord": Vector2i(2, 1),
			"replaceable": false,
			"effect": {
				"speed_mult": 1.2,
				"visual_offset": 0.0
			}
		}
	}
}

const DECORATIONS := {
	0: {
		"tree": {"atlas_coord": Vector2i(0, 0), "destructible": true},
		"rock": {"atlas_coord": Vector2i(1, 0), "destructible": true},
		"bush": {"atlas_coord": Vector2i(7, 2), "destructible": true},
	}
}

# ── PUBLIC API ──────────────────────────────────────

func get_ground(block_name: String) -> Dictionary:
	return _find(GROUNDS, block_name)

func get_liquid(block_name: String) -> Dictionary:
	return _find(LIQUIDS, block_name)

func get_liquid_effect(liquid_name: String) -> Dictionary:
	var liquid := get_liquid(liquid_name)
	return liquid.get("effect", {})

func get_decoration(block_name: String) -> Dictionary:
	return _find(DECORATIONS, block_name)

func _find(const_data: Dictionary, block_name: String) -> Dictionary:
	for atlas_id in const_data:
		if const_data[atlas_id].has(block_name):
			var block: Dictionary = const_data[atlas_id][block_name].duplicate()
			block["atlas_id"] = atlas_id
			return block
	return {}