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
    return nil
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

function Drop_all(ignores)
    local selected = turtle.getSelectedSlot()
    for i = 1, SLOTS_MAX do
        turtle.select(i)
        local item_detail = turtle.getItemDetail()
        if not(item_detail and ignores and ignores[item_detail.name]) then
            turtle.drop()
        end
    end
    turtle.select(selected)
end

function Find_first_slot_of(item_id)
    local info = turtle.getItemDetail()
    if info and info.name == item_id then
        return turtle.getSelectedSlot()
    end

    for i = 1, SLOTS_MAX do
        local info = turtle.getItemDetail(i)
        if info and info.name == item_id then
            return i
        end
    end
    return nil
end

function Select_first_slot_of(item_id)
    local slot = Find_first_slot_of(item_id)
    if slot then
        turtle.select(slot)
        return slot
    else
        return nil
    end
end

function Try(fn, ntimes)
    for i = 1, ntimes do
        if i > 1 then
            print("retrying")
        end
        if fn() then
            return true
        end
    end
    return false
end

-- 目の前にあるチェストから燃料補給
-- マグマバケツ対応版
function Refuel2(target_fuel_level)
    local ITEM_LAVA_BUCKET = "minecraft:lava_bucket"
    local ITEM_BUCKET = "minecraft:bucket"

    local target_fuel_level = target_fuel_level or 1000

    while true do
        local working_slot = Find_blank_slot()

        if not(working_slot) then
            print("Insufficient blank slots")
            return false
        end

        if turtle.getFuelLevel() >= target_fuel_level then
            print("Target fuel level is already satisfied")
            return true
        end

        if turtle.getFuelLevel() == turtle.getFuelLimit() then
            print("Fuel limit reached")
            return true
        end

        turtle.select(working_slot)
        if turtle.suck() then
            local item = turtle.getItemDetail()
            if item.name == ITEM_LAVA_BUCKET then
                -- lava
                local empty_buckets_slot = Find_first_slot_of(ITEM_BUCKET) or Find_blank_slot()
                if empty_buckets_slot then
                    turtle.refuel()
                    turtle.transferTo(empty_buckets_slot)
                else
                    print("Insufficient blank slots for lava bucket refuel, skip.")
                end
            else
                -- not lava
                turtle.refuel()
            end
        else
            print("No more fuel to suck")
            return true
        end
    end
    return true
end
