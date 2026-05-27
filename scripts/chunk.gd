extends Node2D

const CHUNK_SIZE := 16
const HEIGHT := 16
const TILE_H := 16

var layers: Array[TileMapLayer] = []

var noise := FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.frequency = 0.01
	_create_layers()
	_fill()

func _fill():
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			# noise return -1..1, kita map ke 0..HEIGHT
			var height := int((noise.get_noise_2d(x, y) + 1.0) / 2.0 * HEIGHT)
			for z in range(HEIGHT):
				var cell := Vector2i(x - (CHUNK_SIZE >> 1), y - (CHUNK_SIZE >> 1))
				if z > height:
					continue # skip, udara
				elif z == height:
					layers[z].set_cell(cell, 0, Vector2i(0, 0)) # grass
				else:
					layers[z].set_cell(cell, 0, Vector2i(4, 0)) # dirt


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
