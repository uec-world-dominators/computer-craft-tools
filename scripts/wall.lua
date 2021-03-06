local turtle = turtle
local vector = vector
local shell = shell

-- user modifiable
WALL_HIGHT = 3
LEFT_TURN_BLOCK = "minecraft:planks"
END_BLOCK = "minecraft:crafting_table"
--

-- init coordinate property
x = 0
y = 0
z = 0
angle = math.pi / 2
selecting_slot = turtle.getSelectedSlot()
-- 

-- constant
RIGHT = 123
LEFT = 124

STOP = 32
TURN_LEFT = 33
NORMAL = 34

MAX_SLOT = 16
--

-- function has_enough_fuel()
--     return turtle.getFuelLevel() > x + y + 1
-- end

function print_coordinate()
    print(string.format("x: %d, y: %d, z: %d", x, y, z))
end

function move_forward()
    -- if not has_enough_fuel() then
    --     emergency_process()
    -- end
    local succeeded = turtle.forward()
    if succeeded then
        x = x + math.cos(angle)
        y = y + math.sin(angle)
    end
    print_coordinate()
    return succeeded
end

function move_back()
    local succeeded = turtle.back()
    if succeeded then
        x = x - math.cos(angle)
        y = y - math.sin(angle)
    end
    print_coordinate()
    return succeeded
end

function turn(direction)
    if direction == RIGHT then
        angle = angle - math.pi / 2
        turtle.turnRight()
    elseif direction == LEFT then
        angle = angle + math.pi / 2
        turtle.turnLeft()
    end
end

function move_down()
    local succeeded = turtle.down()
    if succeeded then
        z = z - 1
    end
    print_coordinate()
end

function move_up()
    local succeeded = turtle.up()
    if succeeded then
        z = z + 1
    end
    print_coordinate()
end

function down_until_ground_without_editing_property()
    while true do
        local is_on_ground = turtle.detectDown()
        if is_on_ground then
            return
        end
        turtle.down()
    end
end

function down_until_ground()
    while true do
        local is_on_ground = turtle.detectDown()
        if not is_on_ground then
            move_down()
        else
            local _, block_below = turtle.inspectDown()
            if block_below["name"] == START_BLOCK then
                return STOP
            elseif block_below["name"] == LEFT_TURN_BLOCK then
                return TURN_LEFT
            else
                return NORMAL
            end
        end
    end
end

function normalize_selecting_slot()
    if (selecting_slot + 1) % (MAX_SLOT + 1) == 0 then
        selecting_slot = 1
    end
    selecting_slot = selecting_slot + 1
end

function place_down_block_with_all_slots()
    for i = 1, MAX_SLOT, 1 do
        turtle.select(selecting_slot)
        local is_succeeded = turtle.placeDown()
        if is_succeeded then
            return
        end
        normalize_selecting_slot()
    end
    error("not enough blocks!!")
end

function place_up_until_wall_hight()
    while z < WALL_HIGHT do
        move_up()
        place_down_block_with_all_slots()
    end
end

function main()
    down_until_ground_without_editing_property()
    while true do
        local mode = down_until_ground()
        if mode == STOP then
            place_up_until_wall_hight()
            break
        elseif mode == TURN_LEFT then
            turn(LEFT)
        end
        place_up_until_wall_hight()
        local is_succeeded =  move_forward()
        if not is_succeeded then
            error("obstacle error")
        end
    end
end

--??????test
function test_down_until_ground()
    local mode = down_until_ground()
    if mode == STOP then
        print("stop mode")
    elseif mode == TURN_LEFT then
        turn(LEFT)
    end
end

function test_place_up()
    place_up_until_wall_hight()
end
--

-- ??????
-- while
--     ??????
--     ret = ??????????????????????????????

--     if ret == ????????????????????????
--         ????????????
--     else if ret == ?????????????????????
--         turn_left
--     ????????????????????????????????????????????????????????????

-- test_down_until_ground()
-- test_place_up()

main()
