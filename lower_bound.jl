function lower_bound(σ_data, solution, list_route_pos, Floyd_Warshall, pos1, pos2, type)
    Min_cost = []
    Links = []
    Min_links = []

    if type == "swap_intra"
        route_pos = list_route_pos[1]
        route = deepcopy(solution.routes[route_pos])

        if pos1 > pos2
            pos1, pos2 = pos2, pos1
        end

        sequence = deepcopy(route.edges)

        if pos1 + 1 == pos2
            Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]] ,[sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
        else
            Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]], [sequence[pos1 + 1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
        end
        n_Parts = length(Parts)

        for i in 1:n_Parts - 1
            Link, min_link = get_links(Parts[i], Parts[i + 1], Floyd_Warshall, sequence[1], route.n_edges)
            append!(Links, [Link])
            append!(Min_links, min_link)
        end

        for i in 1:n_Parts
            ini = Parts[i][1]
            final = Parts[i][2]
            if i == 1
                if ini == final
                    append!(Min_cost, σ_data[route_pos][[-1, -1]][5]) #min_cost of modes
                else
                    append!(Min_cost, σ_data[route_pos][[-1, final.id]][5]) #min_cost of modes
                end
            elseif i == n_Parts
                if ini == final
                    append!(Min_cost, σ_data[route_pos][[0, 0]][5]) #min_cost of modes
                else
                    append!(Min_cost, σ_data[route_pos][[ini.id, 0]][5]) #min_cost of modes
                end
            else
                append!(Min_cost, σ_data[route_pos][[ini.id, final.id]][5])
            end
        end 

        # Change
        if sum(Min_cost) + sum(Min_links) - minimum(σ_data[route_pos][[-1, 0]][5]) < 0
            return true, Links
        else
            return false, Links
        end

    elseif type == "relocate_intra"
        route_pos = list_route_pos[1]
        route = deepcopy(solution.routes[route_pos])

        sequence = deepcopy(route.edges)

        if pos2 > pos1
            if pos1 + 1 == pos2
                Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
            else
                Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos1 + 1], sequence[pos2]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
            end   
        else
            if pos2 + 1 == pos1
                Parts = [[sequence[1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos2]], [sequence[pos1 + 1], sequence[end]]]
            else
                Parts = [[sequence[1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos1 - 1]], [sequence[pos1 + 1], sequence[end]]]
            end
        end

        n_Parts = length(Parts)

        for i in 1:n_Parts - 1
            Link, min_link = get_links(Parts[i], Parts[i + 1], Floyd_Warshall, sequence[1], route.n_edges)
            append!(Links, [Link])
            append!(Min_links, min_link)
        end

        for i in 1:n_Parts
            ini = Parts[i][1]
            final = Parts[i][2]
            if i == 1
                if ini == final
                    append!(Min_cost, σ_data[route_pos][[-1, -1]][5]) #min_cost of modes
                else
                    append!(Min_cost, σ_data[route_pos][[-1, final.id]][5]) #min_cost of modes
                end
            elseif i == n_Parts
                if ini == final
                    append!(Min_cost, σ_data[route_pos][[0, 0]][5]) #min_cost of modes
                else
                    append!(Min_cost, σ_data[route_pos][[ini.id, 0]][5]) #min_cost of modes
                end
            else
                append!(Min_cost, σ_data[route_pos][[ini.id, final.id]][5])
            end
        end 

        # Change
        if sum(Min_cost) + sum(Min_links) - minimum(σ_data[route_pos][[-1, 0]][5]) < 0
            return true,Links
        else
            return false,Links
        end

    elseif type == "swap_inter"

        route_pos_1 = list_route_pos[1]
        route_pos_2 = list_route_pos[2]

        route_1 = deepcopy(solution.routes[route_pos_1])
        route_2 = deepcopy(solution.routes[route_pos_2])

        sequence_1 = deepcopy(route_1.edges)
        sequence_2 = deepcopy(route_2.edges)

        Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_2[pos2], sequence_2[pos2]], [sequence_1[pos1 + 1], sequence_1[end]]]
        Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2 + 1], sequence_2[end]]]
        route_1_links = []
        route_2_links = []

        for i in 1:length(Part_route_1) - 1
            Link, min_link = get_links(Part_route_1[i], Part_route_1[i + 1], Floyd_Warshall, sequence_1[1], route_1.n_edges)
            append!(route_1_links, [Link])
            append!(Min_links, min_link)
        end
        for i in 1:length(Part_route_2) - 1
            Link, min_link = get_links(Part_route_2[i], Part_route_2[i + 1], Floyd_Warshall, sequence_2[1], route_2.n_edges)
            append!(route_2_links, [Link])
            append!(Min_links, min_link)
        end

        append!(Links,[route_1_links])
        append!(Links,[route_2_links])

        if pos1 - 1 == 1
            if pos1 + 1 == route_1.n_edges
                Part_route_1 = [[-1, -1], [sequence_2[pos2].id, sequence_2[pos2].id], [0, 0]]
            else
                Part_route_1 = [[-1, -1], [sequence_2[pos2].id, sequence_2[pos2].id], [sequence_1[pos1 + 1].id, 0]]
            end
        else
            if pos1 + 1 == route_1.n_edges
                Part_route_1 = [[-1, sequence_1[pos1 - 1].id], [sequence_2[pos2].id, sequence_2[pos2].id], [0, 0]]
            else
                Part_route_1 = [[-1, sequence_1[pos1 - 1].id], [sequence_2[pos2].id, sequence_2[pos2].id], [sequence_1[pos1 + 1].id, 0]]
            end
        end

        if pos2 - 1 == 1
            if pos2 + 1 == route_2.n_edges
                Part_route_2 = [[-1, -1], [sequence_1[pos1].id, sequence_1[pos1].id], [0, 0]]
            else
                Part_route_2 = [[-1, -1], [sequence_1[pos1].id, sequence_1[pos1].id], [sequence_2[pos2 + 1].id, 0]]
            end
        else
            if pos2 + 1 == route_2.n_edges
                Part_route_2 = [[-1, sequence_2[pos2 - 1].id], [sequence_1[pos1].id, sequence_1[pos1].id], [0, 0]]
            else
                Part_route_2 = [[-1, sequence_2[pos2 - 1].id], [sequence_1[pos1].id, sequence_1[pos1].id], [sequence_2[pos2 + 1].id, 0]]
            end
        end
        append!(Min_cost, σ_data[route_pos_1][Part_route_1[1]][5]) #min_cost of modes
        append!(Min_cost, σ_data[route_pos_2][Part_route_1[2]][5]) #min_cost of modes
        append!(Min_cost, σ_data[route_pos_1][Part_route_1[3]][5]) #min_cost of modes
        append!(Min_cost, σ_data[route_pos_2][Part_route_2[1]][5]) #min_cost of modes
        append!(Min_cost, σ_data[route_pos_1][Part_route_2[2]][5]) #min_cost of modes
        append!(Min_cost, σ_data[route_pos_2][Part_route_2[3]][5]) #min_cost of modes

        if sum(Min_cost) + sum(Min_links) - minimum(σ_data[route_pos_1][[-1, 0]][5]) - minimum(σ_data[route_pos_2][[-1, 0]][5]) < 0
            return true, Links
        else
            return false, Links
        end

    elseif type == "relocate_inter"

        route_pos_1 = list_route_pos[1]
        route_pos_2 = list_route_pos[2]

        route_1 = deepcopy(solution.routes[route_pos_1])
        route_2 = deepcopy(solution.routes[route_pos_2])

        sequence_1 = deepcopy(route_1.edges)
        sequence_2 = deepcopy(route_2.edges)
        if route_1.n_edges - 1 == 3 && pos1 - 1 == 1 #after concat, we have 1 service
            Part_route_1 = [[sequence_1[1], sequence_1[1]], [sequence_1[pos1 + 1], sequence_1[pos1 + 1]], [sequence_1[end], sequence_1[end]]] # Depot + Service + Depot
        else
            Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_1[pos1 + 1], sequence_1[end]]]
        end
        Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[end]]]
        route_1_links = []
        route_2_links = []

        for i in 1:length(Part_route_1) - 1
            Link, min_link = get_links(Part_route_1[i], Part_route_1[i + 1], Floyd_Warshall, sequence_1[1], route_1.n_edges - 1)
            append!(route_1_links, [Link])
            append!(Min_links, min_link)
        end
        for i in 1:length(Part_route_2) - 1
            Link, min_link = get_links(Part_route_2[i], Part_route_2[i + 1], Floyd_Warshall, sequence_2[1], route_2.n_edges + 1)
            append!(route_2_links, [Link])
            append!(Min_links, min_link)
        end

        append!(Links,[route_1_links])
        append!(Links,[route_2_links])

        if pos1 - 1 == 1
            if pos1 + 1 == route_1.n_edges
                Part_route_1 = [[-1, -1], [0, 0]]
            else
                Part_route_1 = [[-1, -1], [sequence_1[pos1 + 1].id, 0]]
            end
        else
            if pos1 + 1 == route_1.n_edges
                Part_route_1 = [[-1, sequence_1[pos1 - 1].id], [0, 0]]
            else
                Part_route_1 = [[-1, sequence_1[pos1 - 1].id], [sequence_1[pos1 + 1].id, 0]]
            end
        end

        if pos2 - 1 == 1
            if pos2 == route_2.n_edges
                Part_route_2 = [[-1, -1], [sequence_1[pos1].id, sequence_1[pos1].id], [0, 0]]
            else
                Part_route_2 = [[-1, -1], [sequence_1[pos1].id, sequence_1[pos1].id], [sequence_2[pos2].id, 0]]
            end
        else
            if pos2 == route_2.n_edges
                Part_route_2 = [[-1, sequence_2[pos2 - 1].id], [sequence_1[pos1].id, sequence_1[pos1].id], [0, 0]]
            else
                Part_route_2 = [[-1, sequence_2[pos2 - 1].id], [sequence_1[pos1].id, sequence_1[pos1].id], [sequence_2[pos2].id, 0]]
            end
        end        

        append!(Min_cost, σ_data[route_pos_1][Part_route_1[1]][5]) #min_cost of modes
        append!(Min_cost, σ_data[route_pos_1][Part_route_1[2]][5]) #min_cost of modes
        append!(Min_cost, σ_data[route_pos_2][Part_route_2[1]][5]) #min_cost of modes
        append!(Min_cost, σ_data[route_pos_1][Part_route_2[2]][5]) #min_cost of modes
        append!(Min_cost, σ_data[route_pos_2][Part_route_2[3]][5]) #min_cost of modes

        if sum(Min_cost) + sum(Min_links) - minimum(σ_data[route_pos_1][[-1, 0]][5]) - minimum(σ_data[route_pos_2][[-1, 0]][5]) < 0
            return true, Links
        else
            return false, Links
        end
    else
        
    end 
end

function get_links(Part1, Part2, Floyd_Warshall, depot, n_edges)
    
    if Part1[2] == depot
        if Part2[1] == depot #empty route
            return [0, 0, 0, 0], 0
        end

        edge_ini = [Part2[1].from.id, Part2[1].to.id]

        Link_D_1 = Floyd_Warshall[depot.id, edge_ini[1]]
        Link_D_2 = Floyd_Warshall[depot.id, edge_ini[2]]

        return [Link_D_1, Link_D_2, Link_D_1, Link_D_2], min(Link_D_1, Link_D_2)
    
    elseif Part2[1] == depot
        edge_end = [Part1[2].from.id, Part1[2].to.id]

        Link_1_D=Floyd_Warshall[edge_end[2], depot.id]
        Link_2_D=Floyd_Warshall[edge_end[1], depot.id]

        if n_edges == 3
            return [Link_1_D, Link_2_D, Link_1_D, Link_2_D], min(Link_1_D, Link_2_D)
        else
            return [Link_1_D, Link_1_D, Link_2_D, Link_2_D], min(Link_1_D, Link_2_D)
        end
    else
        edge_end = [Part1[2].from.id, Part1[2].to.id]
        edge_ini = [Part2[1].from.id, Part2[1].to.id]

        Link_1_1 = Floyd_Warshall[edge_end[2], edge_ini[1]]
        Link_2_1 = Floyd_Warshall[edge_end[1], edge_ini[1]]
        Link_1_2 = Floyd_Warshall[edge_end[2], edge_ini[2]]
        Link_2_2 = Floyd_Warshall[edge_end[1], edge_ini[2]]

        return [Link_1_1, Link_2_1, Link_1_2, Link_2_2], min(Link_1_1, Link_2_1, Link_1_2, Link_2_2)
    end
end

function after(σ_data, solution, list_route_pos, Floyd_Warshall, pos1, pos2, type, links)

    if type == "swap_intra"
        route = solution.routes[list_route_pos[1]]

        Modes = []
        if pos1 > pos2
            pos1, pos2 = pos2, pos1
        end

        sequence = deepcopy(route.edges)

        if pos1 + 1 == pos2
            Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]] ,[sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
            origin = [1, 1, 1, 1]
        else
            Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]], [sequence[pos1 + 1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
            origin = [1, 1, 1, 1, 1]
        end

        end_service = -2 #Impossible

        if pos2 + 1 == route.n_edges - 1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
            end_service = sequence[pos2 + 1]
        end

        ini = Parts[1]
        final = Parts[2]

        st_service = -2
        if pos1 - 1 == 1
            st_service = sequence[pos2] #Start service or first service
        elseif pos1 - 1 == 2
            st_service = sequence[pos1 - 1] #Start service or first service
        end

        Modes = deepcopy(concat_links_know(Modes, σ_data, list_route_pos, ini, final, links[1], end_service, origin[1:2], st_service))
        for i in 2:length(Parts) - 1
            ini = [ini[1], final[2]]
            final = Parts[i + 1]
            Modes = deepcopy(concat_links_know(Modes, σ_data, list_route_pos, ini, final, links[i], end_service, origin[i:i + 1], st_service))
        end

        if minimum(Modes) - minimum(σ_data[list_route_pos[1]][[-1, 0]][5]) < 0
            #println("Total_cost_concat= ", Modes)
            return true
        else
            return false
        end

    elseif type == "relocate_intra"
        route = solution.routes[list_route_pos[1]]

        Modes = []
        sequence = deepcopy(route.edges)

        st_service = -2

        if pos2 > pos1
            if pos1 + 1 == pos2
                Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
                if pos1 - 1 == 1
                    st_service = sequence[pos2] #Start service or first service
                elseif pos1 - 1 == 2
                    st_service = sequence[pos1 - 1] #Start service or first service
                end
            else
                Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos1 + 1], sequence[pos2]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
                if pos1 - 1 == 2
                    st_service = sequence[pos1 - 1] #Start service or first service
                end
            end   
        else
            if pos2 + 1 == pos1
                Parts = [[sequence[1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos2]], [sequence[pos1 + 1], sequence[end]]]
                if pos2 - 1 == 1
                    st_service = sequence[pos1] #Start service or first service
                elseif pos2 - 1 == 2
                    st_service = sequence[pos2 - 1] #Start service or first service
                end
            else
                Parts = [[sequence[1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos1 - 1]], [sequence[pos1 + 1], sequence[end]]]
                if pos2 - 1 == 1
                    st_service = sequence[pos1] #Start service or first service
                elseif pos2 - 1 == 2
                    st_service = sequence[pos2 - 1] #Start service or first service
                end
            end
        end

        origin = [1, 1, 1, 1]

        end_service = -2 #Impossible
        if pos2 > pos1
            if pos2 + 1 == route.n_edges - 1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
                end_service = sequence[pos2 + 1]
            end
        else
            if pos1 + 1 == route.n_edges - 1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
                end_service = sequence[pos1 + 1]
            end
        end

        ini = Parts[1]
        final = Parts[2]
        Modes = deepcopy(concat_links_know(Modes, σ_data, list_route_pos, ini, final, links[1], end_service, origin[1:2], st_service))
        for i in 2:length(Parts) - 1
            ini = [ini[1], final[2]]
            final = Parts[i + 1]

            Modes = deepcopy(concat_links_know(Modes, σ_data, list_route_pos, ini, final, links[i], end_service, origin[i:i + 1], st_service))
        end

        if minimum(Modes) - minimum(σ_data[list_route_pos[1]][[-1, 0]][5]) < 0
            #println("Total_cost_concat = ", Modes)
            return true
        else
            return false
        end

    elseif type == "swap_inter"
        
        route_pos_1 = list_route_pos[1]
        route_pos_2 = list_route_pos[2]

        route_1 = deepcopy(solution.routes[route_pos_1])
        route_2 = deepcopy(solution.routes[route_pos_2])
        Modes_routes = []

        sequence_1 = deepcopy(route_1.edges)
        sequence_2 = deepcopy(route_2.edges)

        Part_routes = [[[sequence_1[1], sequence_1[pos1 - 1]], [sequence_2[pos2], sequence_2[pos2]], [sequence_1[pos1 + 1], sequence_1[end]]], 
                        [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2 + 1], sequence_2[end]]]]
        
        origin=[[1, 2, 1], [2, 1, 2]]

        for route in 1:2
            Modes = []
            end_service = -2 #Impossible
            st_service = -2 #Impossible
            if route == 1
                if pos1 + 1 == length(route_1.edges) - 1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
                    end_service = sequence_1[pos1 + 1]
                end

                if pos1 - 1 == 1
                    st_service = sequence_2[pos2] #Start service or first service
                elseif pos1 - 1 == 2
                    st_service = sequence_1[pos1 - 1] #Start service or first service
                end

            else
                if pos2 + 1 == length(route_2.edges) - 1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
                    end_service = sequence_2[pos2 + 1]
                end

                if pos2 - 1 == 1
                    st_service = sequence_1[pos1] #Start service or first service
                elseif pos2 - 1 == 2
                    st_service = sequence_2[pos2 - 1] #Start service or first service
                end
            end

            ini = Part_routes[route][1]
            final = Part_routes[route][2]
            Modes = deepcopy(concat_links_know(Modes, σ_data, list_route_pos, ini, final, links[route][1], end_service, origin[route][1:2], st_service))

            for i in 2:length(Part_routes[route]) - 1
                ini = [ini[1], final[2]]
                final = Part_routes[route][i + 1]   
                Modes = deepcopy(concat_links_know(Modes, σ_data, list_route_pos, ini, final, links[route][i], end_service, origin[route][i:i + 1], st_service))
            end
            append!(Modes_routes, [Modes])
        end


        if minimum(Modes_routes[1]) + minimum(Modes_routes[2]) - minimum(σ_data[list_route_pos[1]][[-1, 0]][5]) - minimum(σ_data[list_route_pos[2]][[-1, 0]][5]) < 0
            #=
            for i in 1:2
                println("Total_cost_concat= ", Modes_routes[i])
            end
            =#
            return true
        else
            return false
        end

    elseif type == "relocate_inter"
        
        route_pos_1 = list_route_pos[1]
        route_pos_2 = list_route_pos[2]

        route_1 = deepcopy(solution.routes[route_pos_1])
        route_2 = deepcopy(solution.routes[route_pos_2])
        Modes_routes = []

        sequence_1 = deepcopy(route_1.edges)
        sequence_2 = deepcopy(route_2.edges)

        st_service = [sequence_1[2], sequence_2[2]] #Start service or first service

        if route_1.n_edges - 1 == 3 && pos1 - 1 == 1 #after concat, we have 1 service
            Part_route_1 = [[sequence_1[1], sequence_1[1]], [sequence_1[pos1 + 1], sequence_1[pos1 + 1]], [sequence_1[end], sequence_1[end]]] # Depot + Service + Depot
            origin=[[1, 1, 1], [2, 1, 2]]
        else
            Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_1[pos1 + 1], sequence_1[end]]]
            origin=[[1, 1], [2, 1, 2]]
        end
        Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[end]]]
        
        Part_routes = [Part_route_1, Part_route_2]

        

        for route in 1:2
            Modes = []
            end_service = -2 #Impossible
            st_service = -2
            if route == 1
                if pos1 + 1 == length(route_1.edges) - 1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
                    end_service = sequence_1[pos1 + 1]
                end

                if pos1 - 1 == 2
                    st_service = sequence_1[pos1 - 1] #Start service or first service
                end
            else
                if pos2 == length(route_2.edges) - 1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
                    end_service = sequence_2[pos2]
                end

                if pos2 - 1 == 1
                    st_service = sequence_1[pos1] #Start service or first service
                elseif pos2 - 1 == 2
                    st_service = sequence_2[pos2 - 1] #Start service or first service
                end
            end

            ini = Part_routes[route][1]
            final = Part_routes[route][2]
            Modes = deepcopy(concat_links_know(Modes, σ_data, list_route_pos, ini, final, links[route][1], end_service, origin[route][1:2], st_service))

            for i in 2:length(Part_routes[route]) - 1
                ini = [ini[1], final[2]]
                final = Part_routes[route][i + 1]   
                Modes = deepcopy(concat_links_know(Modes, σ_data, list_route_pos, ini, final, links[route][i], end_service, origin[route][i:i + 1], st_service))
            end
            append!(Modes_routes, [Modes])
        end


        if minimum(Modes_routes[1]) + minimum(Modes_routes[2]) - minimum(σ_data[list_route_pos[1]][[-1, 0]][5]) - minimum(σ_data[list_route_pos[2]][[-1, 0]][5]) < 0
            #=
            for i in 1:2
                println("Total_cost_concat= ", Modes_routes[i])
            end
            =#
            return true
        else
            return false
        end

    else

    end    
end



function update_demand(solution, list_route_pos, pos1, pos2, capacity, type)

    depot_1 = solution.routes[list_route_pos[1]].edges[1]
    depot_2 = solution.routes[list_route_pos[2]].edges[1]

    old_demand_route_1 = solution.routes[list_route_pos[1]].demand
    old_demand_route_2 = solution.routes[list_route_pos[2]].demand

    service_1 = solution.routes[list_route_pos[1]].edges[pos1]
    service_2 = solution.routes[list_route_pos[2]].edges[pos2]

    if type == "swap_inter"
        demand_service_1 = service_1.demand
        demand_service_2 = service_2.demand
        new_demand_route_1 = old_demand_route_1 + demand_service_2 - demand_service_1
        new_demand_route_2 = old_demand_route_2 + demand_service_1 - demand_service_2

    elseif type == "relocate_inter"
        demand_service_1 = service_1.demand
        new_demand_route_1 = old_demand_route_1 - demand_service_1
        new_demand_route_2 = old_demand_route_2 + demand_service_1
    end

    if new_demand_route_1 <= capacity && new_demand_route_2 <= capacity
        return true, [new_demand_route_1, new_demand_route_2]
    else 
        return false, [new_demand_route_1, new_demand_route_2]
    end
end