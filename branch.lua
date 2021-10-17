local args = {...}

-- 移動
-- MOVEMENTS = {}
FORWARD = 0
BACK = 1
UP = 2
DOWN = 3
TURN_RIGHT = 4
TURN_LEFT = 5

-- 方角
NORTH = 0 -- +x
EAST = 1 -- +y
SOUTH = 2 -- -x
WEST = 3 -- -y

DIRECTION_STRING = {
    [NORTH] = "NORTH",
    [EAST] = "EAST",
    [SOUTH] = "SOUTH",
    [WEST] = "WEST",
}
FORWARD_OFFSETS = {
    [NORTH] = vector.new(1, 0, 0),
    [EAST] = vector.new(0, 0, 1),
    [SOUTH] = vector.new(-1, 0, 0),
    [WEST] = vector.new(0, 0, -1),
}
REVERSE_MOVEMENT = {
    [FORWARD] = BACK,
    [BACK] = FORWARD,
    [UP] = DOWN,
    [DOWN] = UP,
    [TURN_RIGHT] = TURN_LEFT,
    [TURN_LEFT] = TURN_RIGHT,
}

-- 起動時の方角を北とする
-- DIRECTION = NORTH

-- 移動開始時を原点とする相対座標
-- POS = vector.new(0, 0, 0)

Location = {}

function Location.new(position, direction)
    local obj = { position = position, direction = direction, movements = {} }
    return setmetatable(obj, {__index = Location})
end

function Location.print(self)
    print("pos: (", self.position, ") , facing: ", DIRECTION_STRING[self.direction])
end

-- forcely move
function Location.move(self, m)
    self:dig(m)
    if self:move_nolog(m) then
        table.insert(self.movements, m)
    else
        print("failed to move "..tostring(m))
        exit()
    end
end

-- function move_ntimes(m, ntimes)
--     for i = 1, ntimes do
--         move(m)
--     end
-- end

function Location.dig(self, m)
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

function Location.move_nolog(self, m)
    local result
    if m == FORWARD then
        result = turtle.forward()
        if result then
            self.position = self.position + FORWARD_OFFSETS[self.direction]
        end
    elseif m == BACK then
        result = turtle.back()
        if result then
            self.position = self.position + FORWARD_OFFSETS[self.direction] * -1
        end
    elseif m == UP then
        result = turtle.up()
        if result then
            self.position = self.position + vector.new(0, 1, 0)
        end
    elseif m == DOWN then
        result = turtle.down()
        if result then
            self.position = self.position + vector.new(0, -1, 0)
        end
    elseif m == TURN_RIGHT then
        result = turtle.turnRight()
        if result then
            self.direction = (self.direction + 1) % 4
        end
    elseif m == TURN_LEFT then
        result = turtle.turnLeft()
        if result then
            self.direction = (self.direction - 1) % 4
        end
    end
    self:print()
    return result
end

function Location.move_reverse_nolog(self, m)
    self:move_nolog(REVERSE_MOVEMENT[m])
end

function Location.rollback(self)
    while 1 do
        rev = table.remove(self.movements, 0)
        if rev == nil then
            break
        else
            self:move_reverse_nolog(rev)
        end

    end
end

-- function down_to_ground()
--     while 1 do
--         if not(turtle.detect()) then
--             turtle.down()
--         else
--             break
--         end
--     end
-- end

-- 3マス分の高さで直線に掘る
function line(n, loc)
    loc:move(UP)
    loc:dig(UP)
    for i = 1, n do 
        loc:dig(FORWARD)
        loc:move(FORWARD)
        loc:dig(UP)
        loc:dig(DOWN)
    end
    loc:move(DOWN)
end

function plane(m, n, loc)
    for i = 1, n do
        line(m, loc)
        if i ~= n then
            -- 180度回転
            if i % 2 == 1 then
                loc.move(TURN_RIGHT)
                loc.move(FORWARD)
                loc.move(TURN_RIGHT)
            else
                loc.move(TURN_LEFT)
                loc.move(FORWARD)
                loc.move(TURN_LEFT)
            end
        else
            -- 終了

        end
    end
end


local command = args[1]
if command == "plane" then
    loc = Location.new(vector.new(0, 0, 0), NORTH)
    plane(args[2], args[3], loc)
    loc:rollback()
elseif command == "line" then
    loc = Location.new(vector.new(0, 0, 0), NORTH)
    line(args[2], loc)
    loc:rollback()
end


-- dl https://mc.shosato.jp/branch.lua branch

-- 直方体がすべて空いているものとして帰還するプログラム
-- pos, direction, 関連操作をクラスにまとめる
