using Random
using Statistics
using LightGraphs, SimpleWeightedGraphs
import XLSX
push!(LOAD_PATH, ".")

include("carpInstance.jl") 
include("floyd_algorithm.jl")


println(ARGS)
if length(ARGS) < 2
    #print error message if the number of parameters is not correct
    println("Usage: julia main.jl <carp-instance-file> <moves> <seed>") 
    exit(1)
end

instance_file = "Instances-CARP\\CARP\\"*ARGS[1] # instance_file receives the name of the instance file
moves = parse(Int64, ARGS[2])
# 0: swap/relocate inter
# 1: swap/relocate 
# 2: 0 + 1
seed = parse(Int64,ARGS[3])
instance = cvrpInstance(instance_file) #instance receives the data read by the Instance constructor


####### FLOYD WARSHALL ALGORITHM #######
#Depot =1
floyd_warshall_matrix=floyd_warshall(instance.N_NODES, instance.EDGES, instance.COST)
println(floyd_warshall_matrix.dists) #Return Matrix floyd_warhsall

########################################