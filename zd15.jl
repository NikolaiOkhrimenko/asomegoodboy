using HorizonSideRobots
include("func.jl")
robot = Border_Coord_Robot(Robot("zd14.sit",animate = true))
function zd15(robot)
    back = move_to_angle!(robot)
    snake_border!(robot; start_side=Nord, ortogonal_side=Ost)
    move_to_angle!(robot)
    move!(robot, back)
end