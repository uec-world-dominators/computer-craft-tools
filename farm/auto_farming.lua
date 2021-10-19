-- init coordinate property
x = 0
y = 0
angle = math.pi / 2
-- 

-- constant
RIGHT = 123
LEFT = 124
SEED_SLOT = 1
FUEL_SLOT = 16
HARVEST_SLOT_START = 2
HARVEST_SLOT_END = 15
SUCCESS = true
FAILURE = false
--

function has_enough_fuel()
    return turtle.getFuelLevel() > x + y + 1
end

function emergency_process()
    go_home()
    store_harvest()
    print("===!!Lack of Fuel!!===")
    error() -- exit program
end

function move_forward()
    if not has_enough_fuel() then
        emergency_process()
    end
    local succeeded = turtle.forward()
    if succeeded then
        x = x + math.cos(angle)
        y = y + math.sin(angle)
    end
    print(string.format("x: %d, y: %d", x, y))
end

function move_back()
    local succeeded = turtle.back()
    if succeeded then
        x = x - math.cos(angle)
        y = y - math.sin(angle)
    end
    print(string.format("x: %d, y: %d", x, y))
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

function ready()
    turtle.select(FUEL_SLOT)
    turtle.refuel()
    turtle.select(SEED_SLOT)
    move_forward()
    move_forward()
end

function farm_forward()
    local has_wall_forward = turtle.detect()
    while not has_wall_forward do
        turtle.digDown()
        turtle.placeDown()
        has_wall_forward = turtle.detect()
        if not has_wall_forward then
            move_forward()
        end
    end
end

last_turn_direction = LEFT -- ここをRIGHTにしたら、タートルを右端からスタートさせることも可能
function decide_turn_direction()
    if last_turn_direction == LEFT then
        last_turn_direction = RIGHT
    else
        last_turn_direction = LEFT
    end
    return last_turn_direction
end

function u_turn()
    local direction = decide_turn_direction()
    turn(direction)
    local has_wall_forward = turtle.detect()
    if has_wall_forward then
        return FAILURE
    end
    move_forward()
    turn(direction)
    return SUCCESS
end

function is_facing_right()
    return math.cos(angle) == 1
end

function turn_until_facing_right()
    while not is_facing_right() do
        turn(RIGHT)
    end
end

function go_home()
    turn_until_facing_right()
    for i = 1, x, 1 do
        move_back()
    end
    turn(LEFT)
    for i = 1, y, 1 do
        move_back()
    end
end

function store_harvest()
    for i = HARVEST_SLOT_START, HARVEST_SLOT_END, 1 do
        turtle.select(i)
        turtle.dropDown()
    end
end

function main()
    ready()
    farm_forward()
    local was_turning_suceeded = true
    while was_turning_suceeded do
        farm_forward()
        was_turning_suceeded = u_turn()
    end
    go_home()
    store_harvest()
end

main()

-- you can run this program by entering 'shell.run("auto_farming.lua")'
