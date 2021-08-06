#update all routes
function preprocessing_total_data(solution, Floyd_Warshall)
    σ_data = []

    for pos_route in 1:solution.n_routes
        dict_ROUTE = Dict()
        dict_ROUTE = deepcopy(update(solution.routes, pos_route, Floyd_Warshall))
        append!(σ_data, [dict_ROUTE])

    end
    return σ_data
end

#update one route
function preprocessing_data(solution, pos_route, Floyd_Warshall)
    dict_ROUTE = update(solution.routes, pos_route, Floyd_Warshall)
    return dict_ROUTE
end

function update(routes, pos_route, Floyd_Warshall)

    route = routes[pos_route]
    dict_ROUTE = Dict() #create_dict_route(route)
    #Each service on the route is saved first
    for i in 1:route.n_edges
        if i == 1 #Start depot
            push!(dict_ROUTE, [-1, -1] => concat_FORW(dict_ROUTE, route, i, i, Floyd_Warshall))
        elseif i == route.n_edges #End depot
            push!(dict_ROUTE, [0, 0] => concat_FORW(dict_ROUTE, route, i, i, Floyd_Warshall))
        else
            push!(dict_ROUTE, [route.edges[i].id, route.edges[i].id] => concat_FORW(dict_ROUTE, route, i, i, Floyd_Warshall))
        end  
    end

    for i in 1:route.n_edges
        for j in (i + 1):route.n_edges
            if i == 1 && j == route.n_edges
                push!(dict_ROUTE, [-1, 0] => concat_FORW(dict_ROUTE, route, i, j, Floyd_Warshall))
            elseif j == route.n_edges #End depot
                push!(dict_ROUTE, [route.edges[i].id, 0] => concat_FORW(dict_ROUTE, route, i, j, Floyd_Warshall))
            elseif  i == 1 #Start depot
                push!(dict_ROUTE, [-1, route.edges[j].id] => concat_FORW(dict_ROUTE, route, i, j, Floyd_Warshall))
            else
                push!(dict_ROUTE, [route.edges[i].id, route.edges[j].id] => concat_FORW(dict_ROUTE, route, i, j, Floyd_Warshall))
            end
        end
    end
    return dict_ROUTE
end

function concat_FORW(dict_ROUTE, route, pos1, pos2, Floyd_Warshall) #concatenation one by one
    depot = route.edges[1]
    if (pos1 == pos2)
        if pos1 == 1 || pos1 == length(route.edges)
            return [0, 0, 0, 0, 0]
        end

        service_cost = route.edges[pos1].cost

        return [service_cost, service_cost, service_cost, service_cost, service_cost]

    else

        finish_0 = route.edges[pos1]
        finish_1 = route.edges[pos2 - 1]
        start = route.edges[pos2]
        if finish_0 == depot #Depot 
            if finish_1 == depot #Depot
                finish_nodes = [1, 1]
                Mode_finish = dict_ROUTE[[-1, -1]] #concact
            else
                finish_nodes = [finish_1.from.id, finish_1.to.id]
                Mode_finish = dict_ROUTE[[-1, finish_1.id]] #concact
            end
        else
            finish_nodes = [finish_1.from.id, finish_1.to.id]
            Mode_finish = dict_ROUTE[[finish_0.id, finish_1.id]] #concact            
        end

        if start == depot
            start_nodes = [1, 1]
            Mode_start = dict_ROUTE[[0, 0]] #new edge
        else
            start_nodes = [start.from.id, start.to.id]
            Mode_start = dict_ROUTE[[start.id, start.id]] #new edge
        end

        if start == depot #return to the deposit
            
            Link_1_D = Floyd_Warshall[finish_nodes[2], start_nodes[1]]
            Link_2_D = Floyd_Warshall[finish_nodes[1], start_nodes[2]]
            if pos2 == 3 && pos1 == 1 # if length route is 3
                Mode_1_1 = Mode_finish[1] + Link_1_D
                Mode_2_1 = Mode_finish[2] + Link_2_D
                Mode_1_2 = Mode_finish[3] + Link_1_D
                Mode_2_2 = Mode_finish[4] + Link_2_D
                return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2)]
            else
                Mode_1_1 = Mode_finish[1] + Link_1_D
                Mode_2_1 = Mode_finish[2] + Link_1_D
                Mode_1_2 = Mode_finish[3] + Link_2_D
                Mode_2_2 = Mode_finish[4] + Link_2_D
                return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2)]
            end

        elseif finish_1 == finish_0 

            if finish_1 == depot #depot to service
                Link_D_1 = Floyd_Warshall[finish_nodes[1], start_nodes[1]]
                Link_D_2 = Floyd_Warshall[finish_nodes[2], start_nodes[2]]

                Mode_1_1 = Link_D_1 + Mode_start[1] 
                Mode_2_1 = Link_D_2 + Mode_start[2]
                Mode_1_2 = Link_D_1 + Mode_start[3]
                Mode_2_2 = Link_D_2 + Mode_start[4]
                return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2)]

            else #service to service
                Link_1_1 = Floyd_Warshall[finish_nodes[2], start_nodes[1]]
                Link_2_1 = Floyd_Warshall[finish_nodes[1], start_nodes[1]]
                Link_1_2 = Floyd_Warshall[finish_nodes[2], start_nodes[2]]
                Link_2_2 = Floyd_Warshall[finish_nodes[1], start_nodes[2]]

                Mode_1_1 = Mode_finish[1] + Link_1_1 + Mode_start[1]
                Mode_2_1 = Mode_finish[2] + Link_2_1 + Mode_start[2]
                Mode_1_2 = Mode_finish[3] + Link_1_2 + Mode_start[3]
                Mode_2_2 = Mode_finish[4] + Link_2_2 + Mode_start[4]
                return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2)]
            end

        elseif pos1 == 1 && pos1 == pos2 - 2  #service to service
            Link_1_1 = Floyd_Warshall[finish_nodes[2], start_nodes[1]]
            Link_2_1 = Floyd_Warshall[finish_nodes[1], start_nodes[1]]
            Link_1_2 = Floyd_Warshall[finish_nodes[2], start_nodes[2]]
            Link_2_2 = Floyd_Warshall[finish_nodes[1], start_nodes[2]]

            Mode_1_1 = Mode_finish[1] + Link_1_1 + Mode_start[1]
            Mode_2_1 = Mode_finish[2] + Link_2_1 + Mode_start[2]
            Mode_1_2 = Mode_finish[3] + Link_1_2 + Mode_start[3]
            Mode_2_2 = Mode_finish[4] + Link_2_2 + Mode_start[4]
            return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2)]

        else
            #subsequence to service
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

function concat_links_know(Modes, σ_data, list_pos_route, sigma_1, sigma_2, links, end_service, origin, st_service)

    if isempty(Modes)
        if sigma_1[1] == sigma_1[2]
            ini = σ_data[list_pos_route[origin[1]]][[-1, -1]]
        else
            ini = σ_data[list_pos_route[origin[1]]][[-1, sigma_1[2].id]]
        end
    else
        ini = Modes
    end

    if sigma_1[1] == sigma_2[1]
        final = σ_data[list_pos_route[origin[2]]][[0, 0]]
    elseif sigma_1[1] == sigma_2[2]
        final = σ_data[list_pos_route[origin[2]]][[sigma_2[1].id, 0]]
    else

        final = σ_data[list_pos_route[origin[2]]][[sigma_2[1].id, sigma_2[2].id]]
    end
    
    if sigma_1[1] == sigma_1[2] #Depot
        if sigma_2[1] == sigma_1[1] #Empty route
            Modes = deepcopy([0, 0, 0, 0])

        elseif sigma_2[1] == end_service #service to service
            Mode_1_1 = links[1] + final[1]
            Mode_2_1 = links[2] + final[2]
            Mode_1_2 = links[3] + final[3]
            Mode_2_2 = links[4] + final[4]
            Modes = deepcopy([Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2])

        elseif sigma_2[1] == sigma_2[2] #concat depot to service
            Mode_1_1 = links[1] + final[1]
            Mode_2_1 = links[2] + final[4]
            Mode_1_2 = links[3] + final[1]
            Mode_2_2 = links[4] + final[4]
            Modes = deepcopy([Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2])      
              
        else #concat depot to subsequence
            Mode_1_1 = links[1] + final[1]
            Mode_2_1 = links[2] + final[2]
            Mode_1_2 = links[3] + final[3]
            Mode_2_2 = links[4] + final[4]
            Modes = deepcopy([Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2])
        end
    else
        if sigma_2[1] == sigma_1[1] #return to depot
            Mode_1_1 = ini[1] + links[1]
            Mode_2_1 = ini[2] + links[2]
            Mode_1_2 = ini[3] + links[3]
            Mode_2_2 = ini[4] + links[4]
            Modes = deepcopy([Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2])

        elseif sigma_1[2] == st_service #pos 2 equal a service
            if sigma_2[1] == sigma_2[2] || sigma_2[1] == end_service #service to service
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

        elseif sigma_2[1] == sigma_2[2] || sigma_2[1] == end_service #concat subsequence to service
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
    end

    return Modes
end

function empty_route(solution, σ_data)

    solution_av = deepcopy(solution)
    σ_data_av = deepcopy(σ_data)
    empty = true

    while empty == true
        for pos_route in 1:solution_av.n_routes
            if solution_av.routes[pos_route].n_edges == 2
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