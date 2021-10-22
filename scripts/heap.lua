local vector = vector
local vector = vector
local shell = shell

Heap = {}

function Heap.new()
    local obj = {}
    obj.heap = {}
    return setmetatable(obj, {__index = Heap})
end

function Heap.push(self, x)
    table.insert(self.heap, x)
    local i = #self.heap
    while i > 1 do
        local p = i // 2
        if self.heap[p] <= x then
            break
        end
        self.heap[i] = self.heap[p]
        i = p
        self.heap[i] = x
    end
end

heap = Heap.new()
