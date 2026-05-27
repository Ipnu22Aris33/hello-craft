extends Resource
class_name BlockRegistry

@export var blocks: Array[BlockData]

func get_block(block_name: String) -> BlockData:
	for block in blocks:
		if block.name == block_name:
			return block
	return null

func get_block_by_id(id: int) -> BlockData:
	if id >= 0 and id < blocks.size():
		return blocks[id]
	return null

func get_id(block_name: String) -> int:
	for i in blocks.size():
		if blocks[i].name == block_name:
			return i
	return -1