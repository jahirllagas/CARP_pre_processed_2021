function swap_intra_p(data, solution, route_pos, pos1)
    solution_av = deepcopy(solution)    
    route_av = deepcopy(solution_av.routes[route_pos])
    list_route_pos = []

    order_services = shuffle(rng, 1:route_av.n_edges)
    
    for pos2 in order_services
        if pos2 != pos1
            list_route_pos = [route_pos]
            solution_av.routes[route_pos].edges[pos1], solution_av.routes[route_pos].edges[pos2] = solution_av.routes[route_pos].edges[pos2], solution_av.routes[route_pos].edges[pos1]
            
            return solution_av, list_route_pos
        end
    end

    return solution, list_route_pos
end

function relocate_intra_p(data, solution, route_pos, pos1)
    solution_av = deepcopy(solution)
    route_av = deepcopy(solution_av.routes[route_pos])
    list_route_pos = []
    order_services = shuffle(rng, 1:route_av.n_edges)

    for pos2 in order_services
        if pos2 != pos1
            list_route_pos=[route_pos]
            service = splice!(solution_av.routes[route_pos].edges, pos1) #remove
            insert!(solution_av.routes[route_pos].edges, pos2, service) #insert
            return solution_av, list_route_pos
        end
    end
    return solution, list_route_pos
end

function swap_inter_p(data, solution, route_pos_1, pos1)
    solution_av = deepcopy(solution)
    capacity = data.capacity
    list_route_pos = []
    order_routes = shuffle(rng, 1:solution_av.n_routes)

    for route_pos_2 in order_routes
        list_route_pos = [route_pos_1, route_pos_2]
        route_2 = deepcopy(solution_av.routes[route_pos_2])

        if route_pos_1 != route_pos_2
            order_services = shuffle(rng, 1:route_2.n_edges)

            for pos2 in order_services
                new_demand = []
                accept_demand, new_demand = update_demand(data, solution_av, list_route_pos, pos1, pos2, capacity, "swap_inter")

                if accept_demand == true
                    solution_av.routes[route_pos_1].edges[pos1], solution_av.routes[route_pos_2].edges[pos2] = solution_av.routes[route_pos_2].edges[pos2], solution_av.routes[route_pos_1].edges[pos1]
                    solution_av.routes[route_pos_1].demand = new_demand[1]
                    solution_av.routes[route_pos_2].demand = new_demand[2]

                    return solution_av, list_route_pos
                end
            end
        end
    end
    return solution, list_route_pos
end

function relocate_inter_p(data, solution, route_pos_1, pos1)
    solution_av = deepcopy(solution)
    capacity = data.capacity
    list_route_pos = []
    order_routes = shuffle(rng, 1:solution_av.n_routes)

    for route_pos_2 in order_routes
        list_route_pos = [route_pos_1, route_pos_2]
        route_2 = deepcopy(solution_av.routes[route_pos_2])

        if route_pos_1 != route_pos_2
            order_services = shuffle(rng, 1:route_2.n_edges + 1)

            for pos2 in order_services
                new_demand = []
                accept_demand, new_demand = update_demand(data, solution_av, list_route_pos, pos1, pos2, capacity, "relocate_inter")

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
    return solution, list_route_pos
end

function aceita_moves(σ_data_av, σ_data_opt, solution_av, opt_solution, Max, Min)
    cost_av = []
    cost_opt = []

    for i in 1:length(σ_data_av)
        append!(cost_av, [concat_depot(data, solution_av.routes[i], i, σ_data_av)[5]])
        append!(cost_opt, [concat_depot(data, opt_solution.routes[i], i, σ_data_opt)[5]])
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

