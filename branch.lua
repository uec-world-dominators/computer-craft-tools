local args = {...}

MOVEMENTS = {}
FORWARD = 0
BACK = 1
UP = 2
DOWN = 3
TURN_RIGHT = 4
TURN_LEFT = 5

-- forcely move
function move(m)
    print("move "..tostring(m))
    dig(m)
    if move_nolog(m) then
        table.insert(MOVEMENTS, m)
    else
        print("failed to move "..tostring(m))
    end
end

function dig(m)
    if m == FORWARD then
        while turtle.detect() do
            turtle.dig()
        end
    elseif m == BACK then
        print("cannot dig back")
        exit()
    elseif m == UP then
        while turtle.detectUp() do
            turtle.digUp()
        end
    elseif m == DOWN then
        while turtle.detectDown() do
            turtle.digDown()
        end
    end
end

function move_nolog(m)
    local result
    if m == FORWARD then
        result = turtle.forward()
    elseif m == BACK then
        result = turtle.back()
    elseif m == UP then
        result = turtle.up()
    elseif m == DOWN then
        result = turtle.down()
    elseif m == TURN_RIGHT then
        result = turtle.turnRight()
    elseif m == TURN_LEFT then
        result = turtle.turnLeft()
    end
    return result
end

REVERSE_MOVEMENT = {
    [FORWARD] = BACK,
    [BACK] = FORWARD,
    [UP] = DOWN,
    [DOWN] = UP,
    [TURN_RIGHT] = TURN_LEFT,
    [TURN_LEFT] = TURN_RIGHT,
}

function move_reverse_nolog(m)
    move_nolog(REVERSE_MOVEMENT[m])
end

function return_()
    while 1 do
        rev = table.remove(MOVEMENTS, 0)
        if rev == nil then
            break
        else
            move_reverse_nolog(rev)
        end

    end
end

function down_to_ground()
    while 1 do
        if not(turtle.detect()) then
            turtle.down()
        else
            break
        end
    end
end

function line(n)
    move(UP)
    for i = 1, n do 
        dig(FORWARD)
        move(FORWARD)
        dig(DOWN)
    end
    move(DOWN)
end


line(args[1])
return_()

-- dl https://mc.shosato.jp/branch.lua branch
