extends Node2D

var chunk_position := Vector2i.ZERO

func generate(world: Node2D):
	for x in range(world.CHUNK_SIZE):
		for y in range(world.CHUNK_SIZE):
			var world_x = x + chunk_position.x * world.CHUNK_SIZE
			var world_y = y + chunk_position.y * world.CHUNK_SIZE
			var blocks = world.world_generator.get_blocks(world_x, world_y)

			# ground layer
			var ground = blocks["ground"]
			if not ground.is_empty():
				world.set_ground_cell(Vector2i(world_x, world_y), ground["atlas_id"], ground["atlas_coord"])

			# decoration layer
			var deco = blocks["decoration"]
			if not deco.is_empty():
				world.set_decoration_cell(Vector2i(world_x, world_y), deco["atlas_id"], deco["atlas_coord"])

func clear(world: Node2D):
	for x in range(world.CHUNK_SIZE):
		for y in range(world.CHUNK_SIZE):
			var cell := Vector2i(
				x + chunk_position.x * world.CHUNK_SIZE,
				y + chunk_position.y * world.CHUNK_SIZE
			)
			world.ground.erase_cell(cell)
			world.decoration.erase_cell(cell)
