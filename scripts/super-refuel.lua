
function super_refuel()
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.refuel()
    end    
end

function main()
    super_refuel()    
end

main()
