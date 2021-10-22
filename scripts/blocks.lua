
BlockInfo = {}
function BlockInfo.new(name, metadata)
    local obj = {
        name = name,
        metadata = metadata,
    }
    return setmetatable(obj, {__index = BlockInfo})
end

function BlockInfo.equal(self, blockinfo)
    return self.name == blockinfo.name and self.metadata == blockinfo.metadata
end


BLOCK_WHITE_WOOL = BlockInfo.new("minecraft:wool", 0)
BLOCK_ORANGE_WOOL = BlockInfo.new("minecraft:wool", 1)
BLOCK_MAGENTA_WOOL = BlockInfo.new("minecraft:wool", 2)
BLOCK_LIGHT_BLUE_WOOL = BlockInfo.new("minecraft:wool", 3)
BLOCK_YELLOW_WOOL = BlockInfo.new("minecraft:wool", 4)
BLOCK_LIME_WOOL = BlockInfo.new("minecraft:wool", 5)
BLOCK_PINK_WOOL = BlockInfo.new("minecraft:wool", 6)
BLOCK_GRAY_WOOL = BlockInfo.new("minecraft:wool", 7)
BLOCK_LIGHT_GRAY_WOOL = BlockInfo.new("minecraft:wool", 8)
BLOCK_CYAN_WOOL = BlockInfo.new("minecraft:wool", 9)
BLOCK_PURPLE_WOOL = BlockInfo.new("minecraft:wool", 10)
BLOCK_BLUE_WOOL = BlockInfo.new("minecraft:wool", 11)
BLOCK_BROWN_WOOL = BlockInfo.new("minecraft:wool", 12)
BLOCK_GREEN_WOOL = BlockInfo.new("minecraft:wool", 13)
BLOCK_RED_WOOL = BlockInfo.new("minecraft:wool", 14)
BLOCK_BLACK_WOOL = BlockInfo.new("minecraft:wool", 15)
