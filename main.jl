using LightGraphs
using CARPData
using Random, Statistics
using SimpleWeightedGraphs

include("carpInstance.jl")
include("floyd_algorithm.jl")
include("constructive.jl")
include("pre_processed_data.jl")
include("local_search.jl")
include("lower_bound.jl")
include("perturbation.jl")
#push!(LOAD_PATH, ".")

ARGS = [:gdb2, "2", "534242063"]

#---------------------DATA AND INFORMATION---------------------#

data = load(ARGS[1]) # instance_file receives the name of the instance file
moves = parse(Int64, ARGS[2])
# 0: swap/relocate intra
# 1: swap/relocate inter
# 2: 0 + 1
seed = parse(Int64, ARGS[3])
depot = data.vertices[1]
println(data)
println(seed)
n_vertex= length(data.vertices)
startt = time() #Start time

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

a = 0

#----------------------CONSTRUCTIVE----------------------------#

start_solution = constructive(Floyd_Warshall, data, depot) #Struct mutable

#----------------VIDALT PRE PROCESSED METHOD--------------------#

σ_data_opt = preprocessing_total_data(start_solution, Floyd_Warshall) #Dict
σ_data = deepcopy(σ_data_opt)
# σ_data : [edge1, edge2] => [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, Lower Bound]

#-------------------------INITIAL COST--------------------------#

start_solution.total_cost = Total_Cost(start_solution, σ_data_opt)
println("Total Cost = ", start_solution.total_cost)

opt_solution = deepcopy(start_solution) #Struct mutable
solution = deepcopy(start_solution) #Struct mutable
solution

#-------------------PERTURBATION PARAMETERS --------------------#

MAX_VALUE = 0.25
MIN_VALUE = 0.05
Max = copy(MAX_VALUE)
Min = copy(MIN_VALUE)
reduc = 0.0005

#------------------------LOCAL SEARCH---------------------------#

while a < 100 #(time() - startt) < 60
    global a = a + 1
    accept_move = true
    
    while accept_move == true 
        accept_move = false
        solution_av = deepcopy(solution)
        σ_data_av = deepcopy(σ_data)
        route_order = shuffle(rng, 1:solution_av.n_routes)

        for route_pos in route_order
            
            clients_order = shuffle(rng, 2:solution_av.routes[route_pos].n_edges)

            for pos1 in clients_order
                order_moves = shuffle(rng, moves_ILS) #random move order

                for i in order_moves
                    if i == 1
                        accept_move, solution_av, list_route_pos = swap_intra(σ_data_av, solution_av, route_pos, Floyd_Warshall, pos1)

                    elseif i == 2
                        accept_move, solution_av, list_route_pos = relocate_intra(σ_data_av, solution_av, route_pos, Floyd_Warshall, pos1)
                    
                    elseif i == 3
                        accept_move, solution_av, list_route_pos = swap_inter(σ_data_av, solution_av, route_pos, Floyd_Warshall, data.capacity, pos1)

                    elseif i == 4
                        accept_move, solution_av, list_route_pos = relocate_inter(σ_data_av, solution_av, route_pos, Floyd_Warshall, data.capacity, pos1)
                    end
                    #Got better?
                    if accept_move == true
                        global solution = deepcopy(solution_av)
                        for route_pos in list_route_pos
                            σ_data_av[route_pos] = deepcopy(preprocessing_data(solution_av, route_pos, Floyd_Warshall))
                            #println("Total_cost_update_data = ", σ_data_av[route_pos][[-1, 0]]) #Check the change in cost   
                        end
                        global σ_data = deepcopy(σ_data_av)
                        global solution, σ_data = empty_route(solution, σ_data)
                        #println("***********")
                        @goto escape_label
                    end
                end
            end
        end
        @label escape_label
 
    end

    solution.total_cost = Total_Cost(solution, σ_data)
    println(a, ". Total Cost = ", solution.total_cost)

    if solution.total_cost < opt_solution.total_cost - 0.000001 || solution.n_routes < opt_solution.n_routes #Less vehicles
        global opt_solution = deepcopy(solution)
        global σ_data_opt = deepcopy(σ_data)
        global Max = copy(MAX_VALUE)
        global Min = copy(MIN_VALUE)
        #println(a)
    end

 
    M = 0
    add = 0

    solution_av = deepcopy(solution)
    σ_data_av = deepcopy(σ_data)

#--------------------------PERTURBATION-----------------------------#    
    while M < 4 
        M = M + 1
        add = add + 1 #Caso nao consiga valores dentro do rango
        route_pos = rand(rng, 1:solution_av.n_routes)
        pos1 = rand(rng, 2:solution_av.routes[route_pos].n_edges)

        i = rand(rng, moves_ILS)

        if i == 1
            solution_av, list_route_pos = swap_intra_p(σ_data_av, solution_av, route_pos, Floyd_Warshall, pos1)

        elseif i == 2
            solution_av, list_route_pos = relocate_intra_p(σ_data_av, solution_av, route_pos, Floyd_Warshall, pos1)
        
        elseif i == 3
            solution_av, list_route_pos = swap_inter_p(σ_data_av, solution_av, route_pos, Floyd_Warshall, data.capacity, pos1)

        elseif i == 4
            solution_av, list_route_pos = relocate_inter_p(σ_data_av, solution_av, route_pos, Floyd_Warshall, data.capacity, pos1)
        end

        for route_pos in list_route_pos
            σ_data_av[route_pos] = deepcopy(preprocessing_data(solution_av, route_pos, Floyd_Warshall))      
        end
        
        solution_av.total_cost = Total_Cost(solution_av, σ_data_av)

        if M == 4
            if aceita_moves(σ_data_av, σ_data_opt, Max, Min) == false
                M = 0
                solution_av = deepcopy(solution)
                σ_data_av = deepcopy(σ_data)
            else
                global solution, σ_data = deepcopy(solution_av), deepcopy(σ_data_av)
                global Max = Max - reduc
                global Min = Min - reduc
            end
        end
        if add > 200
            add = 0
            global Max = Max + 0.05
        end  
    end
end

totaltime = time() - startt
println("Time: ",  round(totaltime, digits = 3))
println("Optimal Route Cost = ", opt_solution.total_cost)
opt_solution.routes

#------------------------------------------------------------------#
#a = preprocessing_total_data(opt_solution, Floyd_Warshall) #Dict
#Total_Cost(opt_solution ,a) 