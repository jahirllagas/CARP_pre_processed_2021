#update all routes
function preprocessing_total_data(data, solution, Floyd_Warshall)
    σ_data = []

    for pos_route in 1:solution.n_routes
        ROUTE = deepcopy(update(data, solution.routes, pos_route, Floyd_Warshall))
        append!(σ_data, [ROUTE])

    end
    return σ_data
end

#update one route
function preprocessing_data(data, solution, pos_route, Floyd_Warshall)
    ROUTE = update(data, solution.routes, pos_route, Floyd_Warshall)
    return ROUTE
end

function update(data, routes, pos_route, Floyd_Warshall)

    route = routes[pos_route]
    matrix = [σ(0, 0, zeros(Float64, 2, 2), 0) for i = 1:route.n_edges - 2, j = 1:route.n_edges - 2] #Don't take into account depots
    #Each service on the route is saved first
    for i in 1:route.n_edges - 2
        matrix[i, i] = deepcopy(concat_FORW(data, matrix, route.edges, i + 1, i + 1, Floyd_Warshall)) #Position in route have depot
    end
    for i in 1:route.n_edges - 2
        for j in (i + 1):route.n_edges - 2
            matrix[i, j] =  deepcopy(concat_FORW(data, matrix, route.edges, i + 1, j + 1, Floyd_Warshall))
        end
    end

    return matrix
end

function concat_FORW(data, matrix, route, pos1, pos2, Floyd_Warshall) #concatenation one by one

    if (pos1 == pos2)
        service_cost = data.edges[route[pos1]].cost
        return σ(route[pos1], route[pos1], [service_cost Inf; Inf service_cost], service_cost)

    else
        finish_1 = data.edges[route[pos2 - 1]]
        start = data.edges[route[pos2]]

        finish_nodes = [finish_1.from.id, finish_1.to.id]
        start_nodes = [start.from.id, start.to.id]

        Mode_finish = matrix[pos1 - 1, pos2 - 2].Modes #concact     #Reduction in 1 due to depot       
        Mode_start = matrix[pos2 - 1, pos2 - 1].Modes #new edge     #Reduction in 1 due to depot  

        matrix_links = LINKS(Floyd_Warshall, finish_nodes, start_nodes)

        Mode_1_1 = FORW(Mode_finish, matrix_links, Mode_start, 1, 1)
        Mode_2_1 = FORW(Mode_finish, matrix_links, Mode_start, 2, 1)
        Mode_1_2 = FORW(Mode_finish, matrix_links, Mode_start, 1, 2)
        Mode_2_2 = FORW(Mode_finish, matrix_links, Mode_start, 2, 2)
            
        return σ(route[pos1], route[pos2], [Mode_1_1 Mode_1_2; Mode_2_1 Mode_2_2], min(Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2))
    end
end

function LINKS(Floyd_Warshall, finish_nodes, start_nodes)
    Link_1_1 = Floyd_Warshall[finish_nodes[2], start_nodes[1]]
    Link_2_1 = Floyd_Warshall[finish_nodes[1], start_nodes[1]]
    Link_1_2 = Floyd_Warshall[finish_nodes[2], start_nodes[2]]
    Link_2_2 = Floyd_Warshall[finish_nodes[1], start_nodes[2]]
    return [Link_1_1 Link_1_2; Link_2_1 Link_2_2]
end

function FORW(Mode_finish, matrix_links, Mode_start, k, l)
    Modes = []
    for x in 1:2
        for y in 1:2
            append!(Modes, [Mode_finish[k, x] + matrix_links[x, y] + Mode_start[y, l]])
        end
    end
    return minimum(Modes)
end

function concat_links_know(Modes, σ_data, list_pos_route, links, origin, position)

    if Modes == zeros(Float64, 2, 2)
        ini = σ_data[list_pos_route[origin[1]]][position[1][1] - 1, position[1][2] - 1].Modes
    else
        ini = Modes
    end

    final = σ_data[list_pos_route[origin[2]]][position[2][1] - 1, position[2][2] - 1].Modes

    Mode_1_1 = FORW(ini, links, final, 1, 1)
    Mode_2_1 = FORW(ini, links, final, 2, 1)
    Mode_1_2 = FORW(ini, links, final, 1, 2)
    Mode_2_2 = FORW(ini, links, final, 2, 2)
        
    return [Mode_1_1 Mode_1_2; Mode_2_1 Mode_2_2]
end

function empty_route(solution, σ_data)

    solution_av = deepcopy(solution)
    σ_data_av = deepcopy(σ_data)
    empty = true

    while empty == true
        for pos_route in 1:solution_av.n_routes
            if solution_av.routes[pos_route].n_edges == 2
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

function FORW_D_Subsequence_D(data, route, route_pos, σ_data)
    ini = route.edges[2]
    final = route.edges[end - 1]

    Link_D_1 = Floyd_Warshall[1, data.edges[ini].from.id]
    Link_D_2 = Floyd_Warshall[1, data.edges[ini].to.id]

    Link_1_D = Floyd_Warshall[data.edges[final].to.id, 1]
    Link_2_D = Floyd_Warshall[data.edges[final].from.id, 1]

    Mode = σ_data[route_pos][1, end].Modes

    if ini == final #route with only 1 service
        Mode_1_1 = Link_D_1 + Mode[1, 1] + Link_1_D
        Mode_2_1 = Inf
        Mode_1_2 = Inf
        Mode_2_2 = Link_D_2 + Mode[2, 2] + Link_2_D 
    else
        Mode_1_1 = Link_D_1 + Mode[1, 1] + Link_1_D
        Mode_2_1 = Link_D_2 + Mode[2, 1] + Link_1_D
        Mode_1_2 = Link_D_1 + Mode[1, 2] + Link_2_D
        Mode_2_2 = Link_D_2 + Mode[2, 2] + Link_2_D  
    end

    return [Mode_1_1  Mode_1_2; Mode_2_1 Mode_2_2]
end
