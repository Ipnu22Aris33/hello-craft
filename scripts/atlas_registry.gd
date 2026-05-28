# atlas_registry.gd (autoload)
extends Node

const GROUNDS := {
	0: { # atlas_id
		"grass": {"atlas_coord": Vector2i(0, 0), "replaceable": true},
		"dirt": {"atlas_coord": Vector2i(4, 1), "replaceable": true},
		"sand": {"atlas_coord": Vector2i(2, 0), "replaceable": true},
		"snow": {"atlas_coord": Vector2i(3, 0), "replaceable": true},
		"dirt_snow": {"atlas_coord": Vector2i(4, 0), "replaceable": true},
		"stone": {"atlas_coord": Vector2i(0, 1), "replaceable": false},
	}
}

const LIQUIDS := {
	0: { # atlas_id
		"water": {"atlas_coord": Vector2i(4, 1), "replaceable": false},
		"lava": {"atlas_coord": Vector2i(1, 0), "replaceable": false},
	}
}

const DECORATIONS := {
	2: { # atlas_id
		"tree": {"atlas_coord": Vector2i(0, 0), "destructible": true},
		"rock": {"atlas_coord": Vector2i(1, 0), "destructible": true},
		"bush": {"atlas_coord": Vector2i(2, 0), "destructible": true},
	}
}

# ── PUBLIC API ──────────────────────────────────────

func get_ground(block_name: String) -> Dictionary:
	return _find(GROUNDS, block_name)

func get_liquid(block_name: String) -> Dictionary:
	return _find(LIQUIDS, block_name)

func get_decoration(block_name: String) -> Dictionary:
	return _find(DECORATIONS, block_name)

func _find(const_data: Dictionary, block_name: String) -> Dictionary:
	for atlas_id in const_data:
		if const_data[atlas_id].has(block_name):
			var block: Dictionary = const_data[atlas_id][block_name].duplicate()
			block["atlas_id"] = atlas_id
			return block
	return {}