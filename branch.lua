local args = {...}

-- x = 0
-- y = 0
-- z = 0

-- function up()
--     z = z + 1
-- end
-- function down()
--     z = z - 1
-- end
-- function forward()
--     z = z + 1
-- end

function line(n)
    turtle.up()
    for i = 1, n do 
        if turtle.detect() then
            turtle.dig()
        end
        if turtle.detectDown() then
            turtle.digDown()
        end
        turtle.forward()
    end
    turtle.down()
end

line(args[1])
