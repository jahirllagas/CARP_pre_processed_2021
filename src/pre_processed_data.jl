
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
