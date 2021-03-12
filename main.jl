using Random
using Statistics
using LightGraphs, SimpleWeightedGraphs
import XLSX
push!(LOAD_PATH, ".")

include("carpInstance.jl") 
include("floyd_algorithm.jl")
include("constructive.jl")
include("pre_processed_data.jl")
include("local_search.jl")
include("lower_bound.jl")

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
#println(floyd_warshall_matrix.dists) #Return Matrix floyd_warhsall

########################################
cost_open_route=10000
rng = MersenneTwister(seed) #random number generator initializer
startt = time() #starts the timer

moves_ILS=[]
if moves==0 || moves==2
    append!(moves_ILS,[1,2])
end
if moves==1 || moves==2
    append!(moves_ILS,[3,4])
end

############# CONSTRUCTIVE #############

ROUTES, D_ROUTES = constructive(floyd_warshall_matrix.dists, instance,cost_open_route)
ROUTES_opt, D_ROUTES_opt=deepcopy(ROUTES),deepcopy(D_ROUTES)
#println(ROUTES)
#println(D_ROUTES)
sigma_data=preprocessing_total_data(ROUTES,floyd_warshall_matrix.dists,instance)

#println(ROUTES[1])
#println(sigma_data[1])
########################################

############# LOCAL SEARCH #############
println(instance.CAPACITY)
for a in 1:1
    accept_move=true
    while accept_move==true
        accept_move=false
        ROUTES_av, D_ROUTES_av=deepcopy(ROUTES), deepcopy(D_ROUTES)
        route_order=shuffle(rng,1:length(ROUTES_av))

        for route_pos in route_order
            clients_order=shuffle(rng,2:length(ROUTES_av[route_pos])) # 2:The deposit cannot move

            for pos1 in clients_order
                order_moves=shuffle(rng,moves_ILS) #random move order

                for i in order_moves
                    if i==1
                        accept_move, ROUTES_av,list_route_pos = swap_intra(sigma_data,route_pos,ROUTES_av,floyd_warshall_matrix.dists,pos1,instance)
                    elseif i==2
                        accept_move, ROUTES_av,list_route_pos = relocate_intra(sigma_data,route_pos,ROUTES_av,floyd_warshall_matrix.dists,pos1,instance)
                    elseif i==3
                        accept_move, ROUTES_av,new_demand,list_route_pos = swap_inter(sigma_data,route_pos,ROUTES_av,D_ROUTES_av,floyd_warshall_matrix.dists,pos1,instance)
                    end

                    #Got better?
                    if accept_move==true
                        for i in list_route_pos
                            @show ROUTES[i]
                        end
                        global ROUTES = deepcopy(ROUTES_av)
                        for i in list_route_pos
                            @show ROUTES[i] #Verify change of route
                        end
                        if length(list_route_pos) >1
                            for i in 1:length(list_route_pos)
                                global sigma_data[list_route_pos[i]]=deepcopy(preprocessing_data(ROUTES,list_route_pos[i],floyd_warshall_matrix.dists,instance))
                                global D_ROUTES[list_route_pos[i]]=new_demand[i]
                                println("Total_cost_update_data= ",sigma_data[list_route_pos[i]][[-1,0]]) #Check the change in cost 
                            end
                        else
                            global sigma_data[list_route_pos[1]]=deepcopy(preprocessing_data(ROUTES,list_route_pos[1],floyd_warshall_matrix.dists,instance))     
                        end
                        @show D_ROUTES                 
                        println("***********")
                        @goto escape_label            
                    end
                end
            end
        end
        @label escape_label
    end
    for i in 1:length(ROUTES)
        println("Cost Route $i = ",sigma_data[i][[-1,0]])
    end
end
########################################