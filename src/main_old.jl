using LightGraphs
using CARPData
using SimpleWeightedGraphs

include("carpInstance.jl")
include("floyd_algorithm.jl")
include("constructive.jl")
include("pre_processed_data.jl")
include("local_search.jl")
include("lower_bound.jl")
include("perturbation.jl")
push!(LOAD_PATH, ".")

ARGS = ["kshs1", "42", "4", "0.005", "0.1", "kshs1-out.txt"]

#---------------------DATA AND INFORMATION---------------------#
instance = ARGS[1]
data = load(Symbol(instance)) # instance_file receives the name of the instance file
seed = parse(Int64, ARGS[2])
iter_p = parse(Int64, ARGS[3])
initial = parse(Float64, ARGS[4])
final = parse(Float64, ARGS[5])
depot = data.vertices[1]
println(data)
println(seed)
n_vertex= length(data.vertices)

#------------------FLOYD WARSHALL ALGORITHM--------------------#

#Return Matrix floyd_warhsall
Floyd_Warshall = floyd_warshall(n_vertex, data.edges).dists

#---------------------OTHERS PARAMETERS------------------------#

global rng = MersenneTwister(seed) #random number generator initializer
global startt = time() #starts the timer
moves_ILS = [i for i in 1:4]

a = 0

#----------------------CONSTRUCTIVE----------------------------#

start_solution = constructive(Floyd_Warshall, data, depot) #Struct mutable

#----------------VIDALT PRE PROCESSED METHOD--------------------#

σ_data_opt = preprocessing_total_data(data, start_solution, Floyd_Warshall) #Dict
σ_data = deepcopy(σ_data_opt)


#-------------------------INITIAL COST--------------------------#

start_solution.total_cost = Total_Cost(start_solution, σ_data_opt)#
println("Total Cost = ", start_solution.total_cost)

opt_solution = deepcopy(start_solution) #Struct mutable
solution = deepcopy(start_solution) #Struct mutable
solution

#-------------------PERTURBATION PARAMETERS --------------------#
Iter = 500
p_params = Perturb_params(iter_p, initial, final)
#------------------------LOCAL SEARCH---------------------------#

function main(data, a, Iter, p_params, opt_solution, σ_data_opt, solution, σ_data, moves_ILS)
    while a < Iter #(time() - startt) < 60
        a = a + 1
        accept_move = true
        #k = 1
        while accept_move
            #k = k + 1
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
                            accept_move, solution_av, list_route_pos = swap_intra(data, σ_data_av, solution_av, route_pos, Floyd_Warshall, pos1)
                           
                        elseif i == 2
                            accept_move, solution_av, list_route_pos = relocate_intra(data, σ_data_av, solution_av, route_pos, Floyd_Warshall, pos1)
                        
                        elseif i == 3
                            accept_move, solution_av, list_route_pos = swap_inter(data, σ_data_av, solution_av, route_pos, Floyd_Warshall, pos1)
                        
                        elseif i == 4
                            accept_move, solution_av, list_route_pos = relocate_inter(data, σ_data_av, solution_av, route_pos, Floyd_Warshall, pos1)
                        end
                        #Got better?
                        if accept_move
                            solution = deepcopy(solution_av)
                            for route_pos in list_route_pos
                                σ_data_av[route_pos] = deepcopy(preprocessing_data(data, solution_av, route_pos, Floyd_Warshall))
                                #cost_modes = FORW_D_Subsequence_D(data, solution.routes[route_pos], route_pos, σ_data_av)
                                #println("Total_cost_update_data = ", cost_modes) #Check the change in cost  
                            end
                            σ_data = deepcopy(σ_data_av)
                            solution, σ_data = empty_route(solution, σ_data)                       
                            #println("***********")
                            break
                        end
                    end
                    if accept_move
                        break
                    end
                end
                if accept_move
                    break
                end
            end
            #if k > 100
            #    break
            #end
        end

        solution.total_cost = Total_Cost(solution, σ_data)
        #println(a, ". Total Cost = ", solution.total_cost)

        if solution.total_cost < opt_solution.total_cost - 0.000001 || solution.n_routes < opt_solution.n_routes #Less vehicles
            opt_solution = deepcopy(solution)
            σ_data_opt = deepcopy(σ_data)
        end
        
#------------------------ PERTURBATION---------------------------#

        temp = (p_params.initial_accept * solution.total_cost) / -log(p_params.initial_accept)
        stop = (p_params.final_accept * solution.total_cost) / -log(p_params.final_accept)
        factor = (stop / temp) ^ (1 / p_params.num_iter)
        iter = 0
        current_solution = deepcopy(solution)
        while iter < p_params.num_iter
            solution_av = deepcopy(solution)
            σ_data_av = deepcopy(σ_data)

            route_pos = rand(rng, 1:solution_av.n_routes)
            pos1 = rand(rng, 2:solution_av.routes[route_pos].n_edges)

            i = rand(rng, moves_ILS)

            if i == 1
                solution_av, list_route_pos = swap_intra_p(solution_av, route_pos, pos1)

            elseif i == 2
                solution_av, list_route_pos = relocate_intra_p(solution_av, route_pos, pos1)
            
            elseif i == 3
                solution_av, list_route_pos = swap_inter_p(solution_av, route_pos, pos1)

            elseif i == 4
                solution_av, list_route_pos = relocate_inter_p(solution_av, route_pos, pos1)
            end

            for route_pos in list_route_pos
                σ_data_av[route_pos] = deepcopy(preprocessing_data(data, solution_av, route_pos, Floyd_Warshall))      
            end
            solution_av, σ_data_av  = empty_route(solution_av, σ_data_av)
            solution_av.total_cost = Total_Cost(solution_av, σ_data_av)

#-------------------- SIMULATING ANNEALING------------------------#

            dif = solution_av.total_cost - current_solution.total_cost
            temp = temp * factor
            prob = exp(- dif / temp)
            if dif < -1e-5 || rand(rng, Float64) < prob || (solution_av.n_routes < solution.n_routes) #Less vehicles
                solution = deepcopy(solution_av)
                σ_data = deepcopy(σ_data_av)
                iter = iter + 1
            else
                solution_av = deepcopy(solution)
                σ_data_av = deepcopy(σ_data)
            end

            if (solution_av.total_cost - opt_solution.total_cost) < -1e-5 || (solution_av.n_routes < opt_solution.n_routes) #Less vehicles
                opt_solution = deepcopy(solution_av)
                σ_data_opt = deepcopy(σ_data)
                break
            end
        end

    end
    

    totaltime = round(time() - startt, digits = 3)
    println("Time: ", totaltime)
    Optimal = opt_solution.total_cost
    println("Optimal Route Cost = ", Optimal)
    opt_solution.routes

    open(ARGS[6],"a") do file
        write(file, "$instance, $seed, $Iter, $iter_p, $initial, $final, $totaltime, $Optimal, $(data.lb), $(data.ub)\n")
        close(file)
    end
    

    return
end

main(data, a, Iter, p_params, opt_solution, σ_data_opt, solution, σ_data, moves_ILS)
#------------------------------------------------------------------#
