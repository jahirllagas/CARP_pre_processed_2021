using Base: init_depot_path
using LightGraphs
using CARPData
using Random, Statistics
using LightGraphs, SimpleWeightedGraphs
using CARPData

include("carpInstance.jl")
include("floyd_algorithm.jl")
include("constructive.jl")
include("pre_processed_data.jl")
include("local_search.jl")
include("lower_bound.jl")

ARGS = [:gdb1, 2, 123456789]

#---------------------DATA AND INFORMATION---------------------#

data = load(ARGS[1]) # instance_file receives the name of the instance file
moves = ARGS[2]
# 0: swap/relocate intra
# 1: swap/relocate inter
# 2: 0 + 1
seed = ARGS[3]
depot = data.vertices[1]
display(data)

n_vertex= length(data.vertices)

#------------------FLOYD WARSHALL ALGORITHM--------------------#

#Return Matrix floyd_warhsall
Floyd_Warshall = floyd_warshall(n_vertex, data.edges).dists

#---------------------OTHERS PARAMETERS------------------------#

cost_open_route = 10000

rng = MersenneTwister(seed) #random number generator initializer
startt = time() #starts the timer

moves_ILS = []
if moves == 0 || moves==2
    append!(moves_ILS, [1, 2])
end
if moves == 1 || moves==2
    append!(moves_ILS, [3, 4])
end

#----------------------CONSTRUCTIVE----------------------------#

start_solution = constructive(Floyd_Warshall, data, depot) #Struct mutable
opt_solution = deepcopy(start_solution) #Struct mutable

#----------------VIDAL PRE PROCESSED METHOD--------------------#

σ_data = preprocessing_total_data(opt_solution, Floyd_Warshall) #Dict
# σ_data : [edge1, edge2] => [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, Lower Bound]

#------------------------LOCAL SEARCH--------------------------#
for a in 1:1
    accept_move = true
    while accept_move == true
        

        accept_move = false
        solution_av = deepcopy(opt_solution)
        route_order = shuffle(rng, 1:solution_av.n_routes)

        for route_pos in route_order
            
            clients_order = shuffle(rng, 2:solution_av.routes[route_pos].n_edges)

            for pos1 in clients_order
                order_moves = shuffle(rng, moves_ILS) #random move order

                for i in order_moves
                    if i == 1
                        accept_move, solution_av, list_route_pos = swap_intra(σ_data, solution_av, route_pos, Floyd_Warshall, pos1)

                    elseif i == 2
                        accept_move, solution_av, list_route_pos = relocate_intra(σ_data, solution_av, route_pos, Floyd_Warshall, pos1)
                    
                    elseif i == 3
                        accept_move, solution_av, list_route_pos = swap_inter(σ_data, solution_av, route_pos, Floyd_Warshall, data.capacity, pos1)

                    elseif i == 4
                        accept_move, solution_av, list_route_pos = relocate_inter(σ_data, solution_av, route_pos, Floyd_Warshall, data.capacity, pos1)
                    else
                    end
                    #Got better?
                    if accept_move == true
                        global opt_solution = deepcopy(solution_av)
                        for route_pos in list_route_pos
                            global σ_data[route_pos] = deepcopy(preprocessing_data(opt_solution, route_pos, Floyd_Warshall))  
                            println("Total_cost_update_data = ", σ_data[route_pos][[-1, 0]]) #Check the change in cost      
                        end
                        opt_solution, σ_data = empty_route(opt_solution, σ_data)
                        println("***********")
                        @goto escape_label 
                    end
                end
            end
        end
        @label escape_label
    end
   
    TOTAL_COST=0
    for i in 1:opt_solution.n_routes
        cost_modes = σ_data[i][[-1,0]]
        TOTAL_COST = TOTAL_COST + cost_modes[5]
        println("Cost Route $i = ",cost_modes)
    end
    println("Total Cost = ",TOTAL_COST)
end

opt_solution.routes
########################################