using HorizonSideRobots
dir = "/Users/nikolaiokhrimenko/Documents/vscode/Robots"

filter_my(c) =  !startswith(c, ".")
# Получаем список файлов в папке
files = readdir(dir)
files = filter(filter_my, files)
# Проходим по каждому файлу и включаем его
for file in files
    include("Robots/"*file)
end

HSR = HorizonSideRobots

sides = [Sud,West,Nord,Ost]

try_move!(robot, side) = 
    if isborder(robot, side)
        return false
    else
        move!(robot, side)
        return true
    end

left(side::HorizonSide) = HorizonSide(mod(Int(side)+1, 4))
right(side::HorizonSide) = HorizonSide(mod(Int(side)-1, 4))
inverse(side::HorizonSide) = HorizonSide(mod(Int(side)+2, 4))

along!(stop_condition::Function, robot, side) = 
    while stop_condition() == false && try_move!(robot, side) end

function fastmove!(robot,side,n)

    for i in 1:n
        move!(robot,side)
    end
    
end

function perimetr(robot,side)

    for i in 1:4
        while !isborder(robot,side)
            putmarker!(robot)
            move!(robot,side)
        end
        side = right(side)
    end

end
"""
Идёт до конца(пока не встретит стену) стороны света 
"""
function movealong!(robot,side)

    lenght = 0

    while !isborder(robot,side)
        lenght+=1
        try_move!(robot, side)
    end
    
    return lenght
end
"""
Идёт до пока нет стены определённое количество шагов(z)
"""
function movealong!(robot,side,z)
    for i in 1:z
        try_move!(robot,side)
    end

end

function along!(robot, side)
    while !isborder(robot, side)
        try_move!(robot, side)
    end
end
"""
Ведёт робота до гранцы в заданом направлние1, потом ведёт робота до границы в заданном направление2, делает одну проверку на остутсиве стены в направление1 и направление2
"""
function gocorner(robot,side1,side2)

    movealong!(robot,side1)
    movealong!(robot,side2)
    while !(isborder(robot,side1) && isborder(robot, side2))
        if !isborder(robot,side1)
            movealong!(robot,side1)
        else !isborder(robot,side2)
            movealong!(robot,side2)
        end
    end

end

function gohome!(robot,side1,side2,n1,n2)

    movealong!(robot,inverse(side1),n1)
    movealong!(robot,inverse(side2),n2)

end

# ------------------------------------ 3
"""
маркерует всю линию
"""
function markline(robot,side)

    while !isborder(robot,side)
        putmarker!(robot)
        move!(robot,side)
    end
    
end

function markall!(robot,side1,side2)
    a = side1
    while !(isborder(robot,a) && isborder(robot,side2))
        while !isborder(robot,side1)
            markline(robot,side1)
        end
        putmarker!(robot)
        if !isborder(robot,side2)
            move!(robot,side2)
            putmarker!(robot)
        end
        side1=inverse(side1)
    
    end
     
    
end

# ----------------------------- 4
"""
если не стена сторона1 или сторона2 идёт( 1 шаг) в сторону1 и сторону2, ставит маркер (пока идёт) и вызывает рекурсию, пок не встретит стену
"""
function diag(robot,side1,side2)

    if !(isborder(robot,side1) || isborder(robot,side2))
        move!(robot,side1)
        move!(robot,side2)
        putmarker!(robot)
        diag(robot,side1,side2)
        move!(robot,inverse(side1))
        move!(robot,inverse(side2))
    end

end
"""
делает цикл рисования сторон креста 
"""
function crest(robot)
    side1=Nord 
    side2=Ost
    for i in 1:4
        diag(robot,side1,side2)
        side1=right(side1)
        side2=right(side2)
    end
    putmarker!(robot)

    
end

# ------------------------------------ 8 

function spiral(stop_condition::Function, robot)

    step = 1
    side = Ost

    while stop_condition() == false

        for i in 1:step
            if !stop_condition()
                move!(robot,side)
            end
        end
        side = right(side)
        if side == Ost
            step+=1
        elseif side == West
            step+=1
        end

    end

end

# --------------------------------------- 9

function crossall(robot::AbstractRobot)

    side = Ost

    while !(isborder(robot,Sud) && isborder(robot,Ost))
        while !isborder(robot,side)
            movealong!(robot,side)
        end
        if !isborder(robot,Sud)
            move!(robot,Sud)
        end
        side=inverse(side)
    end
    
end

snake!(robot; start_side, ortogonal_side) = 
    snake!(() -> false, robot; start_side, ortogonal_side)

function shatl!(stop_condition::Function, robot; start_side)
    s = start_side
    n = 0
    while stop_condition() == false
        n += 1
        move!(robot, s, n)
        s = inverse(s)
    end
    return (n+1)÷2 # - число шагов от начального положения до конечного
end

function snake!(stop_condition::Function, robot; start_side, ortogonal_side)
    s = start_side
    along!(robot, s) do
        stop_condition() || isborder(robot, s)
    end
    while !stop_condition() && try_move!(robot, ortogonal_side)
        s = inverse(s)
        along!(robot, s) do
            stop_condition() || isborder(robot, s)
        end
    end
end

function snake!(robot; start_side, ortogonal_side)
    s = start_side
    along!(robot, s) do
        isborder(robot, s)
    end
    while try_move!(robot, ortogonal_side)
        s = inverse(s)
        along!(robot, s) do
            isborder(robot, s)
        end
    end
end

# --------------------------------------- 11
"""
проходит всё поле и считает количество перегородок снизу(Sud)
"""
function crossall_count(robot)
    side = Ost
    count = 0
    counter = true

    while !(isborder(robot,Sud) && isborder(robot,Ost))
        while !isborder(robot,side)
            if isborder(robot,Sud) && counter
                count+=1
                move!(robot,side)
                while isborder(robot,Sud) && counter
                    move!(robot,side)
                end
            else
                move!(robot,side)
            end
        end
        if !isborder(robot,Sud)
            move!(robot,Sud)
        end
        if isborder(robot,Sud) && isborder(robot,West)
            counter = false
        end
        side=inverse(side)
    end

    return count

end

# --------------------------------------- 12

function crossall_space_count(robot)
    side = Ost
    count = 0
    counter = true
    space = false

    while !(isborder(robot,Sud) && isborder(robot,Ost))
        while !isborder(robot,side)
            if isborder(robot,Sud) && counter
                count+=1
                move!(robot,side)
                while (isborder(robot,Sud) && counter)
                    move!(robot,side)
                end
                space = true
                if space
                    if !isborder(robot,side)
                        move!(robot,side)
                    else
                        space = false
                        break
                    end
                    if !isborder(robot,Sud)
                        space = false
                    else
                        count-=1
                        space = false
                    end
                end
            else
                move!(robot,side)
            end
        end
        if !isborder(robot,Sud)
            move!(robot,Sud)
        end
        if isborder(robot,Sud) && isborder(robot,West)
            counter = false
        end
        side=inverse(side)
    end

    return count

end

# --------------------------------------- 5

function gofind(robot,lenght)

    side = Ost
    lenght1 = 0
    finder = true
    line = 1

    while !(isborder(robot,Sud) && isborder(robot,Ost)) && finder
        while !isborder(robot,side) && finder
            lenght1+=1
            move!(robot,side)
        end
        if !isborder(robot,Sud) && (lenght1 == lenght)
            move!(robot,Sud)
            lenght1 = 0
            side=inverse(side)
            line+=1
        elseif lenght1 !== lenght
            finder = !finder
        end
    end
    return line
    
end

function markinnerperimetr(robot,line)

    if line%2 == 0
        side = West
    elseif line%2 == 1
        side = Ost
    end

    for i in 1:5
        while isborder(robot,side)
            putmarker!(robot)
            move!(robot,right(side))
        end
        putmarker!(robot)
        move!(robot,side)
        side = left(side)
    end
    
end

# --------------------------------------- 14

function move_to_angle!(robot, angle=(Sud, West))::Vector{NamedTuple{(:side, :num_steps),Tuple{HorizonSide,Int}}}
    back_path = NamedTuple{(:side, :num_steps),Tuple{HorizonSide,Int}}[]
    # - пустой вектор типа Vector{Tuple{HorizonSide,Int}}
    while !isborder(robot, angle[1]) || !isborder(robot, angle[2])
        push!(back_path, (side=inverse(angle[2]),
            num_steps=movealong!(robot, angle[2])))
        push!(back_path, (side=inverse(angle[1]),
            num_steps=movealong!(robot, angle[1])))
    end
    return reverse(back_path)
end

function HorizonSideRobots.move!(robot::AbstractRobot, back_path::Vector{NamedTuple{(:side, :num_steps),Tuple{HorizonSide,Int}}})
    for next in back_path
        move!(robot, next.side::Any, next.num_steps::Int)
    end
end

function snake_border!(robot; start_side, ortogonal_side)
    s = start_side
    along!(robot, s) do
        isborder(robot, s)
    end
    while try_move!(robot, ortogonal_side)
        s = inverse(s)
        along!(robot, s)
    end
end