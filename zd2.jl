include("func.jl")
robot = Robot(animate = true);

function zd2(robot)

    x = movealong!(robot,West)
    y = movealong!(robot,Nord)
    perimetr(robot,Ost)
    gohome!(robot,West,Nord,x,y)

end