local turtle = turtle
local shell = shell

shell.run("navigation.lua")
shell.run("blocks.lua")

Tracer = {}

function Tracer.new(nav, tracer_config)
    if not(nav) then
        error("nav is required")
    end
    if not(tracer_config) then
        error("tracer_config is required")
    end

    local obj = {
        nav = nav,
        tracer_config = tracer_config or {
            [FORWARD] = BlockInfo.new(),
            [BACK] = BlockInfo.new(),
            [UP] = BlockInfo.new(),
            [DOWN] = BlockInfo.new(),
            [TURN_RIGHT] = BlockInfo.new(),
            [TURN_LEFT] = BlockInfo.new(),
            stop = BlockInfo.new(),
        }
    }
    return setmetatable(obj, {__index = Tracer})
end

function Tracer.step(self)
    local result, info = turtle.inspectDown()
    if result then
        for movement, block in pairs(self.tracer_config) do
            if block:equal(info) then
                if movement == FORWARD or movement == BACK or
                    movement == UP or movement == DOWN then
                    self.nav:move(movement)
                elseif movement == TURN_RIGHT or movement == TURN_LEFT then
                    self.nav:move(movement)
                    self.nav:move(FORWARD)
                else
                    print(movement)
                end

                return movement
            end
        end

        error('no matching movement')
    else
        error('block not found')
    end
end

function Tracer.trace(self)
    while self:step() ~= "stop" do

    end
end
