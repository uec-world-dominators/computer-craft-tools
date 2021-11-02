local turtle = turtle
local vector = vector
local shell = shell

shell.run("util.lua")


-- 目の前のチェストに持っているものをすべて吐き出す
function Free_slots(original_nav, chest_station_nav, ignores)
    local nav = original_nav:clone()
    nav:goface(chest_station_nav)
    Drop_all(ignores)
    nav:goface(original_nav)
end

-- スロット開放ハンドラを作成
function Create_free_slots_handler(chest_station_nav, ignores)
    return function (nav)
        local full = Is_slots_full()
        if full then
            Free_slots(nav, chest_station_nav, ignores)
        end
    end
end

-- 目の前のチェストから燃料を補給する
-- チェストの中身はすべて燃料である必要あり
-- original_nav: Navigation = 現在位置
local function refuel(original_nav, chest_station_nav, target_fuel_level)
    local blank_slot = Find_blank_slot()
    if not(blank_slot) then
        Free_slots(original_nav, chest_station_nav)
        blank_slot = Find_blank_slot()
    end
    if not(blank_slot) then
        error("Insufficient blank slot to refuel")
    end

    Refuel2(target_fuel_level)
end

-- 燃料補給ハンドラを作成
function Create_refuel_handler(fuel_station_nav, chest_station_nav, target_fuel_level)

    local target_fuel_level = target_fuel_level or 1000

    return function (nav)
        local level = turtle.getFuelLevel()
        if level < Manhattan_distance(nav.position, fuel_station_nav.position) + 3 then
            local nav = nav:clone()
            nav:with(function ()
                nav:goface(fuel_station_nav)
                refuel(nav, chest_station_nav, target_fuel_level)
            end)
        end
    end
end
