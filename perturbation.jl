function swap_intra_p(σ_data, solution, route_pos, Floyd_Warshall, pos1)
    accept = false
    solution_av = deepcopy(solution)    
    route_av = deepcopy(solution_av.routes[route_pos])
    list_route_pos = []

    if pos1 != route_av.n_edges # The deposit cannot move
        order_services = shuffle(rng, 2:route_av.n_edges - 1)
        
        for pos2 in order_services
            if pos2 != pos1
                list_route_pos=[route_pos]
                solution_av.routes[route_pos].edges[pos1], solution_av.routes[route_pos].edges[pos2] = solution_av.routes[route_pos].edges[pos2], solution_av.routes[route_pos].edges[pos1]
                
                return solution_av, list_route_pos
            end
        end
    end

    return solution, list_route_pos
end

function relocate_intra_p(σ_data, solution, route_pos, Floyd_Warshall, pos1)
    accept = false
    solution_av = deepcopy(solution)
    route_av = deepcopy(solution_av.routes[route_pos])
    list_route_pos = []
    if pos1 !=  route_av.n_edges # The deposit cannot move
        order_services = shuffle(rng, 2:route_av.n_edges - 1) # The deposit cannot move

        for pos2 in order_services

            if pos2 != pos1
                list_route_pos=[route_pos]
                service = splice!(solution_av.routes[route_pos].edges, pos1) #remove
                insert!(solution_av.routes[route_pos].edges, pos2, service) #insert

                return solution_av, list_route_pos
            end
        end
    end
    return solution, list_route_pos
end

function swap_inter_p(σ_data, solution, route_pos_1, Floyd_Warshall, capacity, pos1)
    accept = false
    solution_av = deepcopy(solution)
    route_1 = deepcopy(solution_av.routes[route_pos_1])
    list_route_pos = []
    if pos1 != route_1.n_edges # The deposit cannot move
        order_routes = shuffle(rng, 1:solution_av.n_routes)

        for route_pos_2 in order_routes
            list_route_pos = [route_pos_1, route_pos_2]
            route_2 = deepcopy(solution_av.routes[route_pos_2])

            if route_pos_1 != route_pos_2
                order_services = shuffle(rng, 2:route_2.n_edges - 1) # The deposit cannot move

                for pos2 in order_services
                    new_demand = []
                    accept_demand, new_demand = update_demand(solution_av, list_route_pos, pos1, pos2, capacity, "swap_inter")

                    if accept_demand == true
                        solution_av.routes[route_pos_1].edges[pos1], solution_av.routes[route_pos_2].edges[pos2] = solution_av.routes[route_pos_2].edges[pos2], solution_av.routes[route_pos_1].edges[pos1]
                        solution_av.routes[route_pos_1].demand = new_demand[1]
                        solution_av.routes[route_pos_2].demand = new_demand[2]

                        return solution_av, list_route_pos
                    end
                end
            end
        end
    end
    return solution, list_route_pos
end

function relocate_inter_p(σ_data, solution, route_pos_1, Floyd_Warshall, capacity, pos1)
    accept = false
    solution_av = deepcopy(solution)
    route_1 = deepcopy(solution_av.routes[route_pos_1])
    list_route_pos = []
    if pos1 != route_1.n_edges # The deposit cannot move
        order_routes = shuffle(rng, 1:solution_av.n_routes)

        for route_pos_2 in order_routes
            list_route_pos = [route_pos_1, route_pos_2]
            route_2 = deepcopy(solution_av.routes[route_pos_2])

            if route_pos_1 != route_pos_2
                order_services = shuffle(rng, 2:route_2.n_edges) # The deposit cannot move

                for pos2 in order_services
                    new_demand = []
                    accept_demand, new_demand = update_demand(solution_av, list_route_pos, pos1, pos2, capacity, "relocate_inter")

                    if accept_demand == true
                        service = splice!(solution_av.routes[route_pos_1].edges, pos1) #remove
                        insert!(solution_av.routes[route_pos_2].edges, pos2, service) #insert
                        solution_av.routes[route_pos_1].n_edges = solution_av.routes[route_pos_1].n_edges - 1 #reduce 1 service
                        solution_av.routes[route_pos_2].n_edges = solution_av.routes[route_pos_2].n_edges + 1 #add 1 service
                        solution_av.routes[route_pos_1].demand = new_demand[1] #new_demand
                        solution_av.routes[route_pos_2].demand = new_demand[2]

                        return solution_av, list_route_pos
                    end
                end
            end
        end
    end
    return solution, list_route_pos
end

function aceita_moves(σ_data_av, σ_data_opt, Max, Min)
    cost_av = []
    cost_opt = []

    for i in 1:length(σ_data_av)
        append!(cost_av, [σ_data_av[i][[-1, 0]][5]])
        append!(cost_opt, [σ_data_opt[i][[-1, 0]][5]])
    end

    compare = []
    for i in 1:length(cost_opt)
        append!(compare, abs((cost_av[i] - cost_opt[i]) / cost_opt[i]))
    end
    α_mean = mean(compare)
    if Min <= α_mean <= Max
        return true
    else
        return false
    end
end

