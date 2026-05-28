extends Node2D

var chunk_position := Vector2i.ZERO

func generate(world: Node2D):
	for x in range(world.CHUNK_SIZE):
		for y in range(world.CHUNK_SIZE):
			var world_x = x + chunk_position.x * world.CHUNK_SIZE
			var world_y = y + chunk_position.y * world.CHUNK_SIZE
			var block = world.get_block(world_x, world_y)
			if block.is_empty():
				continue
			world.set_cell(
				Vector2i(world_x, world_y),
				block["atlas_id"],
				block["atlas_coord"]
			)

func clear(world: Node2D):
	for x in range(world.CHUNK_SIZE):
		for y in range(world.CHUNK_SIZE):
			var world_x = x + chunk_position.x * world.CHUNK_SIZE
			var world_y = y + chunk_position.y * world.CHUNK_SIZE
			world.ground.erase_cell(Vector2i(world_x, world_y))