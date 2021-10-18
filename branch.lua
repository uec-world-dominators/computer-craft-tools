local args = {...}

-- 移動
FORWARD = 0
BACK = 1
UP = 2
DOWN = 3
TURN_RIGHT = 4
TURN_LEFT = 5

-- 方角
NORTH = 0 -- +x
EAST = 1 -- +z
SOUTH = 2 -- -x
WEST = 3 -- -z

SLOTS_MAX = 16

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

HOOK_LOCK = false

function is_slots_full()
    local slots_used = 0
    for i = 1, SLOTS_MAX do
        local n = turtle.getItemCount(i)
        if n > 0 then
            slots_used = slots_used + 1
        end
    end
    return slots_used >= SLOTS_MAX - 1
end

function drop_all()
    selected = turtle.getSelectedSlot()
    for i = 1, SLOTS_MAX do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(selected)
end

function free_slots(original_loc)
    local full = is_slots_full()
    print(HOOK_LOCK, full)
    if full then
        local loc = original_loc:clone()
        loc:go(vector.new(0, 0, 0))
        loc:face(WEST)
        -- free_slots
        drop_all()

        loc:go(original_loc.position)
        loc:face(original_loc.direction)
    end
end

-- function refuel_on_low_fuel_level(original_loc)
--     local level = turtle.getFuelLevel()
--     if level < 100 then
--         local loc = original_loc:clone()
--         loc:go(vector.new(0, 0, 0))
--         -- refuel
--         loc:go(original_loc.position)
--         loc:face(original_loc.direction)
--     end
-- end

-- 起動時の方角を北とする
-- 移動開始時を原点とする相対座標

Location = {}

function Location.new(position, direction)
    local obj = {
        position = position,
        direction = direction,
        movements = {},
        hooks = {
            dig = { free_slots },
            -- move = {},
        },
    }
    return setmetatable(obj, {__index = Location})
end

function Location.print(self)
    print("pos: (", self.position, ") , facing: ", DIRECTION_STRING[self.direction])
end

function Location.clone(self)
    return Location.new(vector.new(self.position.x, self.position.y, self.position.z), self.direction)
end

-- 強制的に移動する
function Location.move(self, m)
    self:dig(m)
    if self:move_nolog(m) then
        table.insert(self.movements, m)
    else
        print("failed to move "..tostring(m))
        exit()
    end
end

-- 砂の落下も考慮して掘る
function Location.dig(self, m)

    -- invoke hooks
    for i = 1, #self.hooks.dig do
        if not(HOOK_LOCK) then
            HOOK_LOCK = true
            self.hooks.dig[i](self)
            HOOK_LOCK = false
        end
    end

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

-- 巻き戻し
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

-- directionの方角を向く
function Location.face(self, direction)
    while self.direction ~= direction do
        self:move(TURN_RIGHT)
    end
end

-- 指定座標に行く（動作は直線的）
function Location.go(self, vec)
    -- x
    if self.position.x > vec.x then
        self:face(SOUTH)
    elseif self.position.x < vec.x then
        self:face(NORTH)
    end
    while self.position.x ~= vec.x do
        self:move(FORWARD)
    end

    -- z
    if self.position.z > vec.z then
        self:face(WEST)
    elseif self.position.z < vec.z then
        self:face(EAST)
    end
    while self.position.z ~= vec.z do
        self:move(FORWARD)
    end
    
    -- y
    if self.position.y > vec.y then
        while self.position.y ~= vec.y do
            self:move(DOWN)
        end
    elseif self.position.y < vec.y then
        while self.position.y ~= vec.y do
            self:move(UP)
        end
    end
end

-- 3マス分の高さで直線に掘る
function line(n, loc)
    loc:move(UP)
    loc:dig(UP)
    for i = 1, n - 1 do 
        loc:dig(FORWARD)
        loc:move(FORWARD)
        loc:dig(UP)
        loc:dig(DOWN)
    end
    loc:move(DOWN)
end

-- 高さ3マス x 奥行きm x 幅nで掘りぬく
function plane(m, n, loc)
    for i = 1, n do
        line(m, loc)
        if i ~= n then
            -- 180度回転
            if i % 2 == 1 then
                loc:move(TURN_RIGHT)
                loc:move(FORWARD)
                loc:move(TURN_RIGHT)
            else
                loc:move(TURN_LEFT)
                loc:move(FORWARD)
                loc:move(TURN_LEFT)
            end
        else
            -- 終了

        end
    end
end


local command = args[1]
if command == "plane" then
    loc = Location.new(vector.new(0, 0, 0), NORTH)
    loc:move(FORWARD)
    plane(args[2], args[3], loc)
    loc:go(vector.new(0, 0, 0))
    loc:face(NORTH)
elseif command == "line" then
    loc = Location.new(vector.new(0, 0, 0), NORTH)
    loc:move(FORWARD)
    line(args[2], loc)
    loc:go(vector.new(0, 0, 0))
    loc:face(NORTH)
    -- loc:rollback()
end



-- dl https://mc.shosato.jp/branch.lua branch
-- 燃料補給、チェスト開放
