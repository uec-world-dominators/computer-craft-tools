SLOTS_MAX = 16
local turtle = turtle
local vector = vector

function Manhattan_distance(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y) + math.abs(a.z - b.z)
end

function Find_blank_slot()
    for i = 1, SLOTS_MAX do
        local amount = turtle.getItemCount(i)
        if amount == 0 then
            return i
        end
    end
    return 0
end

function Is_slots_full()
    local slots_used = 0
    for i = 1, SLOTS_MAX do
        local n = turtle.getItemCount(i)
        if n > 0 then
            slots_used = slots_used + 1
        end
    end
    -- 空きスロットが1個以下になったら
    return slots_used >= SLOTS_MAX - 1
end

function Drop_all()
    local selected = turtle.getSelectedSlot()
    for i = 1, SLOTS_MAX do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(selected)
end

function Select_first_slot_of(item_id)
    for i = 1, SLOTS_MAX do
        turtle.select(i)
        local info = turtle.getItemDetail()
        if info and info.name == item_id then
            return i
        end
    end
    return 0
end
