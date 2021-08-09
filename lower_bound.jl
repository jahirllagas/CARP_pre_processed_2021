function lower_bound(data, σ_data, solution, list_route_pos, Floyd_Warshall, pos1, pos2, type)

    if type == "swap_intra"
        route_pos = list_route_pos[1]
        route = deepcopy(solution.routes[route_pos])

        if pos1 > pos2
            pos1, pos2 = pos2, pos1
        end

        sequence = deepcopy(route.edges)

        if pos1 == 1  
            if pos1 + 1 == pos2
                if solution.routes[route_pos].n_edges == 2 #route with only 2 services
                    Parts = [[sequence[pos2], sequence[pos2]] ,[sequence[pos1], sequence[pos1]]]
                    origin = [1, 1]
                else
                    Parts = [[sequence[pos2], sequence[pos2]] ,[sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
                    origin = [1, 1, 1]
                end
            else
                if pos2 == solution.routes[route_pos].n_edges #route with only 2 services
                    Parts = [[sequence[pos2], sequence[pos2]], [sequence[pos1 + 1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]]]
                    origin = [1, 1, 1]
                else
                    Parts = [[sequence[pos2], sequence[pos2]], [sequence[pos1 + 1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
                    origin = [1, 1, 1, 1]
                end                    
            end

        elseif pos1 != 1 
            if pos1 + 1 == pos2
                if pos2 == solution.routes[route_pos].n_edges
                    Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]], [sequence[pos1], sequence[pos1]]]
                    origin = [1, 1, 1]
                else
                    Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
                    origin = [1, 1, 1, 1]
                end 
            else
                if pos2 == solution.routes[route_pos].n_edges
                    Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]], [sequence[pos1 + 1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]]]
                    origin = [1, 1, 1, 1]
                else
                    Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]], [sequence[pos1 + 1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
                    origin = [1, 1, 1, 1, 1]
                end 
            end
        end

        Links, lb_cost = LB_cost(data, Parts, Floyd_Warshall, list_route_pos, route_pos, σ_data, solution, origin)

        # Change
        if lb_cost < 0
            return true, Links, Parts, origin
        else
            return false, Links, Parts, origin
        end

    elseif type == "relocate_intra"
        route_pos = list_route_pos[1]
        route = deepcopy(solution.routes[route_pos])

        sequence = deepcopy(route.edges)
        if pos2 > pos1
            if pos1 == 1  
                if pos1 + 1 == pos2
                    if solution.routes[route_pos].n_edges == 2 #route with only 2 services
                        Parts = [[sequence[pos2], sequence[pos2]], [sequence[pos1], sequence[pos1]]]
                        origin = [1, 1]
                    else
                        Parts = [[sequence[pos2], sequence[pos2]] ,[sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
                        origin = [1, 1, 1]
                    end
                else
                    if pos2 == solution.routes[route_pos].n_edges
                        Parts = [[sequence[pos1 + 1], sequence[pos2]], [sequence[pos1], sequence[pos1]]]
                        origin = [1, 1]
                    else
                        Parts = [[sequence[pos1 + 1], sequence[pos2]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
                        origin = [1, 1, 1]
                    end                    
                end
    
            elseif pos1 != 1 
                if pos1 + 1 == pos2
                    if pos2 == solution.routes[route_pos].n_edges
                        Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]], [sequence[pos1], sequence[pos1]]]
                        origin = [1, 1, 1]
                    else
                        Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos2], sequence[pos2]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
                        origin = [1, 1, 1, 1]
                    end 
                else
                    if pos2 == solution.routes[route_pos].n_edges
                        Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos1 + 1], sequence[pos2]], [sequence[pos1], sequence[pos1]]]
                        origin = [1, 1, 1]
                    else
                        Parts = [[sequence[1], sequence[pos1 - 1]], [sequence[pos1 + 1], sequence[pos2]], [sequence[pos1], sequence[pos1]], [sequence[pos2 + 1], sequence[end]]]
                        origin = [1, 1, 1, 1]
                    end 
                end
            end
        else
            if pos2 == 1  
                if pos2 + 1 == pos1
                    if solution.routes[route_pos].n_edges == 2 #route with only 2 services
                        Parts = [[sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos2]]]
                        origin = [1, 1]
                    else
                        Parts = [[sequence[pos1], sequence[pos1]] ,[sequence[pos2], sequence[pos2]], [sequence[pos1 + 1], sequence[end]]]
                        origin = [1, 1, 1]
                    end
                else
                    if pos1 == solution.routes[route_pos].n_edges #route with only 2 services
                        Parts = [[sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos1 - 1]]]
                        origin = [1, 1]
                    else
                        Parts = [[sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos1 - 1]], [sequence[pos1 + 1], sequence[end]]]
                        origin = [1, 1, 1]
                    end                    
                end
    
            elseif pos2 != 1 
                if pos2 + 1 == pos1
                    if pos1 == solution.routes[route_pos].n_edges
                        Parts = [[sequence[1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos1 - 1]]]
                        origin = [1, 1, 1]
                    else
                        Parts = [[sequence[1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos2]], [sequence[pos1 + 1], sequence[end]]]
                        origin = [1, 1, 1, 1]
                    end 
                else
                    if pos1 == solution.routes[route_pos].n_edges
                        Parts = [[sequence[1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos1 - 1]]]
                        origin = [1, 1, 1]
                    else
                        Parts = [[sequence[1], sequence[pos2 - 1]], [sequence[pos1], sequence[pos1]], [sequence[pos2], sequence[pos1 - 1]], [sequence[pos1 + 1], sequence[end]]]
                        origin = [1, 1, 1, 1]
                    end 
                end
            end
        end

        Links, lb_cost = LB_cost(data, Parts, Floyd_Warshall, list_route_pos, route_pos, σ_data, solution, origin)

        # Change
        if lb_cost < 0
            return true, Links, Parts, origin
        else
            return false, Links, Parts, origin
        end

    elseif type == "swap_inter"
        route_pos_1 = list_route_pos[1]
        route_pos_2 = list_route_pos[2]

        route_1 = deepcopy(solution.routes[route_pos_1])
        route_2 = deepcopy(solution.routes[route_pos_2])

        sequence_1 = deepcopy(route_1.edges)
        sequence_2 = deepcopy(route_2.edges)

        if solution.routes[route_pos_1].n_edges == 1
            if solution.routes[route_pos_2].n_edges == 1
                Part_route_1 = [[sequence_2[pos2], sequence_2[pos2]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]]]
                origin = [[2], [1]]
            elseif pos2 == 1
                Part_route_1 = [[sequence_2[pos2], sequence_2[pos2]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2 + 1], sequence_2[end]]]
                origin = [[2], [1, 2]]
            elseif pos2 == solution.routes[route_pos_2].n_edges
                Part_route_1 = [[sequence_2[pos2], sequence_2[pos2]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]
                origin = [[2], [2, 1]]
            else
                Part_route_1 = [[sequence_2[pos2], sequence_2[pos2]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2 + 1], sequence_2[end]]]
                origin = [[2], [2, 1, 2]] 
            end
        elseif solution.routes[route_pos_2].n_edges == 1
            if pos1 == 1
                Part_route_1 = [[sequence_2[pos2], sequence_2[pos2]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]]]
                origin = [[2, 1], [1]]
            elseif pos1 == solution.routes[route_pos_1].n_edges
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_2[pos2], sequence_2[pos2]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]]]        
                origin = [[1, 2], [1]]
            else
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_2[pos2], sequence_2[pos2]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]]]     
                origin = [[1, 2, 1], [1]]       
            end
        elseif pos1 == 1
            if pos2 == 1
                Part_route_1 = [[sequence_2[pos2], sequence_2[pos2]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2 + 1], sequence_2[end]]]
                origin = [[2, 1], [1, 2]]

            elseif pos2 == solution.routes[route_pos_2].n_edges
                Part_route_1 = [[sequence_2[pos2], sequence_2[pos2]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]
                origin = [[2, 1], [2, 1]]

            else
                Part_route_1 = [[sequence_2[pos2], sequence_2[pos2]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2 + 1], sequence_2[end]]]
                origin = [[2, 1], [2, 1, 2]]                
            end
        elseif pos1 == solution.routes[route_pos_1].n_edges
            if pos2 == 1
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_2[pos2], sequence_2[pos2]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2 + 1], sequence_2[end]]]        
                origin = [[1, 2], [1, 2]]

            elseif pos2 == solution.routes[route_pos_2].n_edges
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_2[pos2], sequence_2[pos2]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]
                origin = [[1, 2], [2, 1]]
            else
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_2[pos2], sequence_2[pos2]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2 + 1], sequence_2[end]]]        
                origin = [[1, 2], [2, 1, 2]]                
            end
        else
            if pos2 == 1
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_2[pos2], sequence_2[pos2]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2 + 1], sequence_2[end]]]     
                origin = [[1, 2, 1], [1, 2]]

            elseif pos2 == solution.routes[route_pos_2].n_edges
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_2[pos2], sequence_2[pos2]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]   
                origin = [[1, 2, 1], [2, 1]]
            else
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_2[pos2], sequence_2[pos2]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2 + 1], sequence_2[end]]]      
                origin = [[1, 2, 1], [2, 1, 2]]                
            end 
        end

        route_1_links, lb_cost_1 = LB_cost(data, Part_route_1, Floyd_Warshall, list_route_pos, route_pos_1, σ_data, solution, origin[1])
        route_2_links, lb_cost_2 = LB_cost(data, Part_route_2, Floyd_Warshall, list_route_pos, route_pos_2, σ_data, solution, origin[2])

        if lb_cost_1 + lb_cost_2 < 0
            return true, [route_1_links, route_2_links], [Part_route_1, Part_route_2], origin
        else
            return false, [route_1_links, route_2_links], [Part_route_1, Part_route_2], origin
        end
        
    elseif type == "relocate_inter"
        route_pos_1 = list_route_pos[1]
        route_pos_2 = list_route_pos[2]

        route_1 = deepcopy(solution.routes[route_pos_1])
        route_2 = deepcopy(solution.routes[route_pos_2])

        sequence_1 = deepcopy(route_1.edges)
        sequence_2 = deepcopy(route_2.edges)

        if solution.routes[route_pos_1].n_edges == 1
            if solution.routes[route_pos_2].n_edges == 1
                if pos2 == 1
                    Part_route_1 = []
                    Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[pos2]]]
                    origin = [[], [1, 2]]
                elseif pos2 == 2
                    Part_route_1 = []
                    Part_route_2 = [[sequence_2[pos2 - 1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]
                    origin = [[], [2, 1]]
                end
            elseif pos2 == 1
                Part_route_1 = []
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[end]]]
                origin = [[], [1, 2]]
            elseif pos2 == solution.routes[route_pos_2].n_edges + 1
                Part_route_1 = []
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]
                origin = [[], [2, 1]]
            else
                Part_route_1 = []
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[end]]]
                origin = [[], [2, 1, 2]] 
            end
        elseif solution.routes[route_pos_2].n_edges == 1
            if pos2 == 1
                if pos1 == 1
                    Part_route_1 = [[sequence_1[pos1 + 1], sequence_1[end]]]
                    Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[pos2]]]
                    origin = [[1], [1, 2]]
                elseif pos1 == solution.routes[route_pos_1].n_edges
                    Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]]]
                    Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[pos2]]]        
                    origin = [[1], [1, 2]]
                else
                    Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_1[pos1 + 1], sequence_1[end]]]
                    Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[pos2]]]     
                    origin = [[1, 1], [1, 2]]       
                end
            elseif pos2 == 2
                if pos1 == 1
                    Part_route_1 = [[sequence_1[pos1 + 1], sequence_1[end]]]
                    Part_route_2 = [[sequence_2[pos2 - 1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]
                    origin = [[1], [2, 1]]
                elseif pos1 == solution.routes[route_pos_1].n_edges
                    Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]]]
                    Part_route_2 = [[sequence_2[pos2 - 1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]        
                    origin = [[1], [2, 1]]
                else
                    Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_1[pos1 + 1], sequence_1[end]]]
                    Part_route_2 = [[sequence_2[pos2 - 1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]     
                    origin = [[1, 1], [2, 1]]       
                end
            end
        elseif pos1 == 1
            if pos2 == 1
                Part_route_1 = [[sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[end]]]
                origin = [[1], [1, 2]]

            elseif pos2 == solution.routes[route_pos_2].n_edges + 1
                Part_route_1 = [[sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]
                origin = [[1], [2, 1]]

            else
                Part_route_1 = [[sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[end]]]
                origin = [[1], [2, 1, 2]]                
            end
        elseif pos1 == solution.routes[route_pos_1].n_edges
            if pos2 == 1
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[end]]]        
                origin = [[1], [1, 2]]

            elseif pos2 == solution.routes[route_pos_2].n_edges + 1
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]
                origin = [[1], [2, 1]]
            else
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[end]]]        
                origin = [[1], [2, 1, 2]]                
            end
        else
            if pos2 == 1
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[end]]]     
                origin = [[1, 1], [1, 2]]

            elseif pos2 == solution.routes[route_pos_2].n_edges + 1
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]]]   
                origin = [[1, 1], [2, 1]]
            else
                Part_route_1 = [[sequence_1[1], sequence_1[pos1 - 1]], [sequence_1[pos1 + 1], sequence_1[end]]]
                Part_route_2 = [[sequence_2[1], sequence_2[pos2 - 1]], [sequence_1[pos1], sequence_1[pos1]], [sequence_2[pos2], sequence_2[end]]]      
                origin = [[1, 1], [2, 1, 2]]                
            end 
        end
        if isempty(Part_route_1)
            route_1_links = []
            lb_cost_1 = 0
        else 
            route_1_links, lb_cost_1 = LB_cost(data, Part_route_1, Floyd_Warshall, list_route_pos, route_pos_1, σ_data, solution, origin[1])
        end
        route_2_links, lb_cost_2 = LB_cost(data, Part_route_2, Floyd_Warshall, list_route_pos, route_pos_2, σ_data, solution, origin[2])

        if lb_cost_1 + lb_cost_2 < 0
            return true, [route_1_links, route_2_links], [Part_route_1, Part_route_2], origin
        else
            return false, [route_1_links, route_2_links], [Part_route_1, Part_route_2], origin
        end
    end
end

function get_links(data, Part1, Part2, Floyd_Warshall)
    
    edge_end = [data.edges[Part1[2]].from.id, data.edges[Part1[2]].to.id]
    edge_ini = [data.edges[Part2[1]].from.id, data.edges[Part2[1]].to.id]

    Link_1_1 = Floyd_Warshall[edge_end[2], edge_ini[1]]
    Link_2_1 = Floyd_Warshall[edge_end[1], edge_ini[1]]
    Link_1_2 = Floyd_Warshall[edge_end[2], edge_ini[2]]
    Link_2_2 = Floyd_Warshall[edge_end[1], edge_ini[2]]

    return [Link_1_1, Link_2_1, Link_1_2, Link_2_2], min(Link_1_1, Link_2_1, Link_1_2, Link_2_2)
end



function after(data, σ_data, solution, list_route_pos, type, links, Parts, origin)
    if type == "swap_intra"
        ft_cost, Modes = after_cost(data, σ_data, list_route_pos, list_route_pos[1], Parts, links, origin, solution, Floyd_Warshall)
        
        if ft_cost < 0

            #println("Total_cost_concat = ", Modes)
            return true
        else
            return false
        end

    elseif type == "relocate_intra"
        ft_cost, Modes = after_cost(data, σ_data, list_route_pos, list_route_pos[1], Parts, links, origin, solution, Floyd_Warshall)
        if ft_cost < 0

            #println("Total_cost_concat = ", Modes)
            return true
        else
            return false
        end
    elseif type == "swap_inter"
        ft_cost_1, Modes1 = after_cost(data, σ_data, list_route_pos, list_route_pos[1], Parts[1], links[1], origin[1], solution, Floyd_Warshall)
        ft_cost_2, Modes2 = after_cost(data, σ_data, list_route_pos, list_route_pos[2], Parts[2], links[2], origin[2], solution, Floyd_Warshall)
        if ft_cost_1 + ft_cost_2 < 0
            #println("Total_cost_concat = ", Modes1)
            #println("Total_cost_concat = ", Modes2)
            return true
        else
            return false
        end
    elseif type == "relocate_inter"
        if isempty(Parts[1])
            ft_cost_1 = 0
            Modes1 = [0, 0, 0, 0]
        else   
            ft_cost_1, Modes1 = after_cost(data, σ_data, list_route_pos, list_route_pos[1], Parts[1], links[1], origin[1], solution, Floyd_Warshall)
        end

        ft_cost_2, Modes2 = after_cost(data, σ_data, list_route_pos, list_route_pos[2], Parts[2], links[2], origin[2], solution, Floyd_Warshall)
        if ft_cost_1 + ft_cost_2 < 0
            #println("Total_cost_concat = ", Modes1)
            #println("Total_cost_concat = ", Modes2)
            return true
        else
            return false
        end
    end    
end



function update_demand(data, solution, list_route_pos, pos1, pos2, capacity, type)

    old_demand_route_1 = solution.routes[list_route_pos[1]].demand
    old_demand_route_2 = solution.routes[list_route_pos[2]].demand

    if type == "swap_inter"
        service_1 = solution.routes[list_route_pos[1]].edges[pos1]
        service_2 = solution.routes[list_route_pos[2]].edges[pos2]

        demand_service_1 = data.edges[service_1].demand
        demand_service_2 = data.edges[service_2].demand
        new_demand_route_1 = old_demand_route_1 + demand_service_2 - demand_service_1
        new_demand_route_2 = old_demand_route_2 + demand_service_1 - demand_service_2

    elseif type == "relocate_inter"
        service_1 = solution.routes[list_route_pos[1]].edges[pos1]

        demand_service_1 = data.edges[service_1].demand
        new_demand_route_1 = old_demand_route_1 - demand_service_1
        new_demand_route_2 = old_demand_route_2 + demand_service_1
    end

    if new_demand_route_1 <= capacity && new_demand_route_2 <= capacity
        return true, [new_demand_route_1, new_demand_route_2]
    else 
        return false, [new_demand_route_1, new_demand_route_2]
    end
end

function LB_cost(data, Parts, Floyd_Warshall, list_route_pos, route_pos, σ_data, solution, origin)
    Min_cost = []
    Links = []
    Min_links = []
    n_Parts = length(Parts)

    if n_Parts != 1
        for i in 1:n_Parts - 1
            Link, min_link = get_links(data, Parts[i], Parts[i + 1], Floyd_Warshall)
            append!(Links, [Link])
            append!(Min_links, min_link)
        end
    else
        Min_links = [0]
    end

    for i in 1:n_Parts
        ini = Parts[i][1]
        final = Parts[i][2]
        append!(Min_cost, σ_data[list_route_pos[origin[i]]][ini, final][5])
    end
    if Parts[1][1] != solution.routes[route_pos].edges[1] && Parts[end][2] != solution.routes[route_pos].edges[end]
        depot_av = depot_cost(Parts[1][1], Parts[end][2], Floyd_Warshall)[5] ###
        depot_solution = concat_depot(data, solution.routes[route_pos], route_pos, σ_data)
        lb_cost = sum(Min_cost) + sum(Min_links) + depot_av - depot_solution[5]
    else
        lb_cost = sum(Min_cost) + sum(Min_links) - σ_data[route_pos][solution.routes[route_pos].edges[1], solution.routes[route_pos].edges[end]][5]
    end
    return Links, lb_cost
end


function after_cost(data, σ_data, list_route_pos, route_pos, Parts, links, origin, solution, Floyd_Warshall)
    Modes = []
    n_Parts = length(Parts)
    if n_Parts != 1
        ini = Parts[1]
        final = Parts[2]
        Modes = deepcopy(concat_links_know(Modes, σ_data, list_route_pos, ini, final, links[1], origin[1:2]))

        for i in 2:n_Parts - 1
            ini = [ini[1], final[2]]
            final = Parts[i + 1]   
            Modes = deepcopy(concat_links_know(Modes, σ_data, list_route_pos, ini, final, links[i], origin[i:i + 1]))
        end
    else
        Modes = deepcopy(σ_data[list_route_pos[origin[1]]][Parts[1][1], Parts[1][2]][1:4])
    end
    #if Parts[1][1] != solution.routes[route_pos].edges[1] && Parts[end][2] != solution.routes[route_pos].edges[end]
        original_cost = concat_depot(data, solution.routes[route_pos], route_pos, σ_data)
        new_cost = Modes + depot_cost(Parts[1][1], Parts[end][2], Floyd_Warshall)[1:4]
        ft_cost = minimum(new_cost) - original_cost[5]
        return ft_cost, new_cost
    #else
    #    ft_cost = minimum(Modes) - σ_data[route_pos][solution.routes[route_pos].edges[1], solution.routes[route_pos].edges[end]][5]
    #    new_cost = Modes + depot_cost(Parts[1][1], Parts[end][2], Floyd_Warshall)[1:4]
    #    return ft_cost, new_cost
    #end
end

function depot_cost(ini, final, Floyd_Warshall)

    Link_D_1 = Floyd_Warshall[1, data.edges[ini].from.id]
    Link_D_2 = Floyd_Warshall[1, data.edges[ini].to.id]

    Link_1_D = Floyd_Warshall[data.edges[final].to.id, 1]
    Link_2_D = Floyd_Warshall[data.edges[final].from.id, 1]

    if ini == final #route with only 1 service
        Mode_1_1 = Link_D_1 + Link_1_D
        Mode_2_1 = Link_D_2 + Link_2_D
        Mode_1_2 = Link_D_1 + Link_1_D
        Mode_2_2 = Link_D_2 + Link_2_D
        return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Link_D_1, Link_D_2) + min(Link_1_D, Link_2_D)]
    else
        Mode_1_1 = Link_D_1 + Link_1_D
        Mode_2_1 = Link_D_2 + Link_1_D
        Mode_1_2 = Link_D_1 + Link_2_D
        Mode_2_2 = Link_D_2 + Link_2_D
        return [Mode_1_1, Mode_2_1, Mode_1_2, Mode_2_2, min(Link_D_1, Link_D_2) + min(Link_1_D, Link_2_D)]
    end
end