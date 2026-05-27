extends Node2D

const CHUNK_SIZE := 16

var chunk_position := Vector2i.ZERO

func generate(world: Node2D):
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_x := x + chunk_position.x * CHUNK_SIZE
			var world_y := y + chunk_position.y * CHUNK_SIZE
			var block = world.get_block(world_x, world_y)
			if block.is_empty():
				continue
			world.set_cell(
				Vector2i(world_x, world_y),
				block["atlas_id"],
				block["atlas_coord"]
			)
