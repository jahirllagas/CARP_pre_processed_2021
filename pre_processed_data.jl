#update all routes
function preprocessing_total_data(data, solution, Floyd_Warshall)
    σ_data = []

    for pos_route in 1:solution.n_routes
        dict_ROUTE = Dict()
        dict_ROUTE = deepcopy(update(data, solution.routes, pos_route, Floyd_Warshall))
        append!(σ_data, [dict_ROUTE])

    end
    return σ_data
end

#update one route
function preprocessing_data(data, solution, pos_route, Floyd_Warshall)
    dict_ROUTE = update(data, solution.routes, pos_route, Floyd_Warshall)
    return dict_ROUTE
end

function update(data, routes, pos_route, Floyd_Warshall)

    route = routes[pos_route].edges
    dict_ROUTE = Dict() #create_dict_route(route)
    #Each service on the route is saved first
    for i in 1:routes[pos_route].n_edges
        push!(dict_ROUTE, (route[i], route[i]) => concat_FORW(data, dict_ROUTE, route, i, i, Floyd_Warshall))
    end

    for i in 1:routes[pos_route].n_edges
        for j in (i + 1):routes[pos_route].n_edges
            push!(dict_ROUTE, (route[i], route[j]) => concat_FORW(data, dict_ROUTE, route, i, j, Floyd_Warshall))
        end
    end
    return dict_ROUTE
end

function concat_FORW(data, dict_ROUTE, route, pos1, pos2, Floyd_Warshall) #concatenation one by one

    if (pos1 == pos2)
        service_cost = data.edges[route[pos1]].cost
        return [service_cost, service_cost, service_cost, service_cost, service_cost]

    else

        finish_0 = data.edges[route[pos1]]
        finish_1 = data.edges[route[pos2 - 1]]
        start = data.edges[route[pos2]]

        finish_nodes = [finish_1.from.id, finish_1.to.id]
        Mode_finish = dict_ROUTE[route[pos1], route[pos2 - 1]] #concact            

        start_nodes = [start.from.id, start.to.id]
        Mode_start = dict_ROUTE[route[pos2], route[pos2]] #new edge

        if finish_1 == finish_0 #service to service

            Link_1_1 = Floyd_Warshall[finish_nodes[2], start_nodes[1]]
            Link_2_1 = Floyd_Warshall[finish_nodes[1], start_nodes[1]]
            Link_1_2 = Floyd_Warshall[finish_nodes[2], start_nodes[2]]
            Link_2_2 = Floyd_Warshall[finish_nodes[1], start_nodes[2]]

            Mode_1_1 = Mode_finish[1] + Link_1_1 + Mode_start[1]
            Mode_2_1 = Mode_finish[2] + Link_2_1 + Mode_start[2]
            Mode_1_2 = Mode_finish[3] + Link_1_2 + Mode_start[3]
            Mode_2_2 = Mode_finish[4] + Link_2_2 + Mode_start[4]
            
            return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2)]

        else #subsequence to service
            
            Link_1_1 = Floyd_Warshall[finish_nodes[2], start_nodes[1]]
            Link_2_1 = Floyd_Warshall[finish_nodes[1], start_nodes[1]]
            Link_1_2 = Floyd_Warshall[finish_nodes[2], start_nodes[2]]
            Link_2_2 = Floyd_Warshall[finish_nodes[1], start_nodes[2]]

            Mode_1_1 = minimum([Mode_finish[1] + Link_1_1 + Mode_start[1], Mode_finish[3] + Link_2_1 + Mode_start[1]])
            Mode_2_1 = minimum([Mode_finish[2] + Link_1_1 + Mode_start[1], Mode_finish[4] + Link_2_1 + Mode_start[1]])
            Mode_1_2 = minimum([Mode_finish[1] + Link_1_2 + Mode_start[4], Mode_finish[3] + Link_2_2 + Mode_start[4]])
            Mode_2_2 = minimum([Mode_finish[2] + Link_1_2 + Mode_start[4], Mode_finish[4] + Link_2_2 + Mode_start[4]])
            
            return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2)]
        end
    end
end

function concat_links_know(Modes, σ_data, list_pos_route, sigma_1, sigma_2, links, origin)

    if isempty(Modes)
        ini = σ_data[list_pos_route[origin[1]]][sigma_1[1], sigma_1[2]]
    else
        ini = Modes
    end

    final = σ_data[list_pos_route[origin[2]]][sigma_2[1], sigma_2[2]]

    
    if sigma_1[1] == sigma_1[2] #service
        if sigma_2[1] == sigma_2[2] #service to service
            Mode_1_1 = ini[1] + links[1] + final[1]
            Mode_2_1 = ini[2] + links[2] + final[2]
            Mode_1_2 = ini[3] + links[3] + final[3]
            Mode_2_2 = ini[4] + links[4] + final[4]
            Modes = deepcopy([Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2])

        else #service to subsequence
            Mode_1_1 = min(ini[1] + links[1] + final[1], ini[1] + links[3] + final[2])
            Mode_2_1 = min(ini[4] + links[2] + final[1], ini[4] + links[4] + final[2])
            Mode_1_2 = min(ini[1] + links[1] + final[3], ini[1] + links[3] + final[4])
            Mode_2_2 = min(ini[4] + links[2] + final[3], ini[4] + links[4] + final[4])
            Modes = deepcopy([Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2])
        end          

    elseif sigma_2[1] == sigma_2[2] #concat subsequence to service
        Mode_1_1 = min(ini[1] + links[1] + final[1], ini[3] + links[2] + final[1])
        Mode_2_1 = min(ini[2] + links[1] + final[1], ini[4] + links[2] + final[1])
        Mode_1_2 = min(ini[1] + links[3] + final[4], ini[3] + links[4] + final[4])
        Mode_2_2 = min(ini[2] + links[3] + final[4], ini[4] + links[4] + final[4])
        Modes = deepcopy([Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2])

    else #concat subsequence to subsequence
        Mode_1_1 = min(ini[1] + links[1] + final[1], ini[3] + links[2] + final[1], ini[1] + links[3] + final[2], ini[3] + links[4] + final[2])
        Mode_2_1 = min(ini[2] + links[1] + final[1], ini[4] + links[2] + final[1], ini[2] + links[3] + final[2], ini[4] + links[4] + final[2])
        Mode_1_2 = min(ini[1] + links[1] + final[3], ini[3] + links[2] + final[3], ini[1] + links[3] + final[4], ini[3] + links[4] + final[4])
        Mode_2_2 = min(ini[2] + links[1] + final[3], ini[4] + links[2] + final[3], ini[2] + links[3] + final[4], ini[4] + links[4] + final[4])
        Modes = deepcopy([Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2])
    end
    return Modes
end

function empty_route(solution, σ_data)

    solution_av = deepcopy(solution)
    σ_data_av = deepcopy(σ_data)
    empty = true

    while empty == true
        for pos_route in 1:solution_av.n_routes
            if solution_av.routes[pos_route].n_edges == 0
                println("OK")
                service = splice!(solution_av.routes, pos_route)
                sigma = splice!(σ_data_av, pos_route)
                solution_av.n_routes = solution_av.n_routes - 1
                break
            end
        end
        empty = false
    end
    
    return solution_av, σ_data_av
end

function concat_depot(data, route, route_pos, σ_data)
    ini = route.edges[1]
    final = route.edges[end]

    Link_D_1 = Floyd_Warshall[1, data.edges[ini].from.id]
    Link_D_2 = Floyd_Warshall[1, data.edges[ini].to.id]

    Link_1_D = Floyd_Warshall[data.edges[final].to.id, 1]
    Link_2_D = Floyd_Warshall[data.edges[final].from.id, 1]

    Mode = σ_data[route_pos][route.edges[1], route.edges[end]][1:4]

    if ini == final #route with only 1 service
        Mode_1_1 = Link_D_1 + Mode[1] + Link_1_D
        Mode_2_1 = Link_D_2 + Mode[2] + Link_2_D
        Mode_1_2 = Link_D_1 + Mode[3] + Link_1_D
        Mode_2_2 = Link_D_2 + Mode[4] + Link_2_D
        return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2)]
    else
        Mode_1_1 = Link_D_1 + Mode[1] + Link_1_D
        Mode_2_1 = Link_D_2 + Mode[2] + Link_1_D
        Mode_1_2 = Link_D_1 + Mode[3] + Link_2_D
        Mode_2_2 = Link_D_2 + Mode[4] + Link_2_D
        return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2)]
    end
    
end