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



local DIRECTION_STRING = {
    [NORTH] = "NORTH",
    [EAST] = "EAST",
    [SOUTH] = "SOUTH",
    [WEST] = "WEST",
}
local FORWARD_OFFSETS = {
    [NORTH] = vector.new(1, 0, 0),
    [EAST] = vector.new(0, 0, 1),
    [SOUTH] = vector.new(-1, 0, 0),
    [WEST] = vector.new(0, 0, -1),
}
local REVERSE_MOVEMENT = {
    [FORWARD] = BACK,
    [BACK] = FORWARD,
    [UP] = DOWN,
    [DOWN] = UP,
    [TURN_RIGHT] = TURN_LEFT,
    [TURN_LEFT] = TURN_RIGHT,
}


local INSPECT_FUNCTIONS = {
    [FORWARD] = turtle.inspect,
    [UP] = turtle.inspectUp,
    [DOWN] = turtle.inspectDown,
}

local DIG_FUNCTIONS = {
    [FORWARD] = turtle.dig,
    [UP] = turtle.digUp,
    [DOWN] = turtle.digDown,
}

local DETECT_FUNCTIONS = {
    [FORWARD] = turtle.detect,
    [UP] = turtle.detectUp,
    [DOWN] = turtle.detectDown,
}

local HOOK_LOCK = false

-- 起動時の方角を北とする
-- 移動開始時を原点とする相対座標

Navigation = {}

function Navigation.new(position, direction, hooks)
    local obj = {
        position = position or vector.new(0, 0, 0),
        direction = direction or NORTH,
        movements = {},
        hooks = hooks or {
            dig = {},
            move = {},
        },
    }
    return setmetatable(obj, {__index = Navigation})
end

-- {["move"] = {handler1}, ["dig"] = {handler2}}
-- handler(navigation)
function Navigation.set_hooks(self, hooks)
    self.hooks = hooks
end

function Navigation.print(self)
    print("pos: (", self.position, ") , facing: ", DIRECTION_STRING[self.direction])
end

function Navigation.clone(self)
    return Navigation.new(vector.new(self.position.x, self.position.y, self.position.z), self.direction)
end

-- 強制的に移動する
function Navigation.move(self, m)
    -- assert fuel
    if turtle.getFuelLevel() == 0 then
        error("Out of fuel")
    end

    -- invoke hooks
    if self.hooks.move then
        for i = 1, #self.hooks.move do
            if not(HOOK_LOCK) then
                HOOK_LOCK = true
                local nav = self:clone()
                nav:with(function ()
                    self.hooks.move[i](nav)
                end)
                HOOK_LOCK = false
            end
        end
    end

    if m == FORWARD or m == BACK or m == UP or m == DOWN then
        self:dig_force(m)
    end
    if self:move_nolog(m) then
        table.insert(self.movements, m)
    else
        error("failed to move "..tostring(m))
    end
end

-- 松明は掘らない
function Navigation.dig(self, m)

    local ignores = {
        ["minecraft:torch"] = true,
    }


    if m == BACK then
        error("cannot dig back")
    else
        local result, info = INSPECT_FUNCTIONS[m]()
        if result and ignores[info.name] then
            return false
        else
            return self:dig_force(m)
        end
    end
end

-- 砂の落下も考慮して掘る
function Navigation.dig_force(self, m)
    -- invoke hooks
    if self.hooks.dig then
        for i = 1, #self.hooks.dig do
            if not(HOOK_LOCK) then
                HOOK_LOCK = true
                local nav = self:clone()
                nav:with(function ()
                    self.hooks.dig[i](nav)
                end)
                HOOK_LOCK = false
            end
        end
    end

    if m == BACK then
        error("cannot dig back")
    else
        while DETECT_FUNCTIONS[m]() do
            DIG_FUNCTIONS[m]()
        end
    end
end

-- 関数fnをntimes試行する
function Navigation.try(self, fn, ntimes)
    local ntimes = ntimes or 100000
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

function Navigation.move_nolog(self, m)
    local result
    if m == FORWARD then
        result = self:try(turtle.forward)
        if result then
            self.position = self.position + FORWARD_OFFSETS[self.direction]
        end
    elseif m == BACK then
        result = self:try(turtle.back)
        if result then
            self.position = self.position + FORWARD_OFFSETS[self.direction] * -1
        end
    elseif m == UP then
        result = self:try(turtle.up)
        if result then
            self.position = self.position + vector.new(0, 1, 0)
        end
    elseif m == DOWN then
        result = self:try(turtle.down)
        if result then
            self.position = self.position + vector.new(0, -1, 0)
        end
    elseif m == TURN_RIGHT then
        result = self:try(turtle.turnRight)
        if result then
            self.direction = (self.direction + 1) % 4
        end
    elseif m == TURN_LEFT then
        result = self:try(turtle.turnLeft)
        if result then
            self.direction = (self.direction - 1) % 4
        end
    end
    -- self:print()
    return result
end

function Navigation.move_reverse_nolog(self, m)
    self:move_nolog(REVERSE_MOVEMENT[m])
end

-- 巻き戻し
function Navigation.rollback(self)
    while 1 do
        local rev = table.remove(self.movements, 0)
        if rev == nil then
            break
        else
            self:move_reverse_nolog(rev)
        end

    end
end

-- directionの方角を向く
function Navigation.face(self, direction)
    while self.direction ~= direction do
        self:move(TURN_RIGHT)
    end
end

-- 指定座標に行く（動作は直線的）
function Navigation.go(self, vec)
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

function Navigation.goface(self, loc)
    self:go(loc.position)
    self:face(loc.direction)
end

function Navigation.with(self, fn)
    local init = self:clone()
    fn()
    self:goface(init)
end
