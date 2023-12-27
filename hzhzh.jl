# using HorizonSideRobots
# HSR = HorizonSideRobots

# include("librobot.jl")
# include("func.jl")

# struct PutmarkersRobot <: AbstractCoordsRobot
#     robot::Robot
#     x::Int
#     y::Int
# end

# get_base_robot(robot::PutmarkersRobot) = robot.robot
# get_coords(robot::PutmarkersRobot) = (robot.x, robot.y)
# set_coords(robot::PutmarkersRobot, x, y) =(robot.x=x; robot.y=y; nothing)

# function HSR.move!(robot::PutmarkersRobot, side)
#     invoke(move!, (AbstractCoordsRobot, HorizonSide),robot, side)
#     putmarker!(robot)
# end