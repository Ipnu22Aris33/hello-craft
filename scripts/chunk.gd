extends Node2D

const CHUNK_SIZE := 16
const HEIGHT := 16
const TILE_H := 16.0

@export var registry: BlockRegistry

var layers: Array[TileMapLayer] = []
var noise := FastNoiseLite.new()
var world := {} 

func _ready():
	noise.seed = randi()
	noise.frequency = 0.01
	_create_layers()
	_fill()

func _create_layers():
	for z in range(HEIGHT):
		var layer := TileMapLayer.new()
		layer.name = "Layer_%d" % z
		layer.tile_set = $TileMapLayer.tile_set
		layer.y_sort_enabled = true
		layer.z_index = z
		layer.position.y = - (z - HEIGHT / 2.0) * TILE_H
		add_child(layer)
		layers.append(layer)


func _fill():
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var h := int((noise.get_noise_2d(x, y) + 1.0) * 0.5 * HEIGHT)

			var cell := Vector2i(x - (CHUNK_SIZE >> 1), y - (CHUNK_SIZE >> 1))

			for z in range(HEIGHT):
				var key := Vector3i(cell.x, cell.y, z)

				if z > h:
					continue

				if z == h:
					world[key] = "grass"
				else:
					world[key] = "dirt"

				_render_block(key)


func _render_block(key: Vector3i):
	var block_name = world[key]
	var block := registry.get_block(block_name)
	if block == null:
		return

	layers[key.z].set_cell(
		Vector2i(key.x, key.y),
		block.atlas_id,
		block.atlas_coord
	)