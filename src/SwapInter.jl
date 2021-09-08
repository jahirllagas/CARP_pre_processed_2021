include("Cost.jl")

function evalSwapInter(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, routes::Vector{Route}, routes_pos::Vector{Int64}, links::Vector{Vector{Matrix{Float64}}}, parts::Vector{Vector{Tuple{Int64, Int64}}}, origins::Vector{Vector{Int64}})
    profit = Vector{Int64}()

    for r in 1:2
        initial = CartesianIndex(parts[r][1])
        sequence = deepcopy(σ_data[routes_pos[origins[r][1]]][initial].modes)

        for i in 2:length(parts[r])
            final = CartesianIndex(parts[r][i])
            subsequence = deepcopy(σ_data[routes_pos[origins[r][i]]][final].modes)
            sequence = deepcopy(concatParts(sequence, links[r][i - 1], subsequence))
        end

        current = concatDepot(data, σ_data, sp_matrix, routes[r], routes_pos[r])
        new = sequence + costDepot(data, sp_matrix, routes[origins[r][1]].edges[parts[r][1][1]], routes[origins[r][end]].edges[parts[r][end][2]])

        push!(profit, minimum(new) - minimum(current))
    end

    if sum(profit) < 0
        return true
    else
        return false
    end
end

function evalLBSwapInter(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, routes::Vector{Route}, routes_pos::Vector{Int64}, rq1::Int64, rq2::Int64)

    parts1 = [(2, rq1 - 1), (rq2, rq2), (rq1 + 1, length(routes[1].edges) - 1)]
    parts2 = [(2, rq2 - 1), (rq1, rq1), (rq2 + 1, length(routes[2].edges) - 1)]
    origin1 = [1, 2, 1]
    origin2 = [2, 1, 2]

    origin1 = origin1[deleteDepot.(parts1)]
    origin2 = origin2[deleteDepot.(parts2)]
    parts1 = parts1[deleteDepot.(parts1)]
    parts2 = parts2[deleteDepot.(parts2)]

    sequence1 = [[routes[origin1[i]].edges[parts1[i][j]] for j in 1:2] for i in 1:length(origin1)]
    sequence2 = [[routes[origin2[i]].edges[parts2[i][j]] for j in 1:2] for i in 1:length(origin2)]

    links1, profit_lb1 = calculateLBSwapInter(data, σ_data, sp_matrix, sequence1, parts1, routes_pos, routes[1], routes_pos[1], origin1)
    links2, profit_lb2 = calculateLBSwapInter(data, σ_data, sp_matrix, sequence2, parts2, routes_pos, routes[2], routes_pos[2], origin2)

    if profit_lb1 + profit_lb2 < 0
        return true, [links1, links2], [parts1, parts2], [origin1, origin2]
    else
        return false, [links1, links2], [parts1, parts2], [origin1, origin2]
    end
end

function calculateLBSwapInter(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, sequence::Vector{Vector{Int64}}, parts::Vector{Tuple{Int64, Int64}}, routes_pos::Vector{Int64}, route::Route, route_pos::Int64, origin::Vector{Int64})
    min_costs = Vector{Float64}()
    min_links = Vector{Float64}()
    links = Vector{Matrix{Float64}}()
    
    if length(sequence) != 1
        for i in 1:length(parts) - 1
            part1 = sequence[i]
            part2 = sequence[i + 1]
            link = getLinks(data, sp_matrix, part1, part2)
            push!(links, link)
            push!(min_links, minimum(link))
        end
    else
        push!(min_links, 0)
    end

    for i in 1:length(parts)
        subsequence = CartesianIndex(parts[i])
        push!(min_costs, σ_data[routes_pos[origin[i]]][subsequence].lower_bound)
    end
    depot = costDepot(data, sp_matrix, sequence[1][1], sequence[end][2])
    profit_lb = minimum(depot) + sum(min_costs) + sum(min_links) - minimum(concatDepot(data, σ_data, sp_matrix, route, route_pos))
    return links, profit_lb
end

function getLinks(data::Data, sp_matrix::Matrix{Int64}, part1::Vector{Int64}, part2::Vector{Int64})
    edge_end = [data.edges[part1[2]].from.id, data.edges[part1[2]].to.id]
    edge_ini = [data.edges[part2[1]].from.id, data.edges[part2[1]].to.id]

    link_1_1 = sp_matrix[edge_end[2], edge_ini[1]]
    link_2_1 = sp_matrix[edge_end[1], edge_ini[1]]
    link_1_2 = sp_matrix[edge_end[2], edge_ini[2]]
    link_2_2 = sp_matrix[edge_end[1], edge_ini[2]]

    return [link_1_1 link_1_2; link_2_1 link_2_2]
end

function moveSwapInter(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, solution::Solution, routes_pos::Vector{Int64}, new_demand::Vector{Int64}, rq1::Int64, rq2::Int64)
    # Effectively move the solution
    # First do SwapInter move
    # Second update σ_data of the route
    # Third recalculate the cost of a route and the total cost
    # Fourth recalculate demand
    solution.routes[routes_pos[1]].edges[rq1], solution.routes[routes_pos[2]].edges[rq2] = solution.routes[routes_pos[2]].edges[rq2], solution.routes[routes_pos[1]].edges[rq1]
    solution.routes[routes_pos[1]].demand = new_demand[1]
    solution.routes[routes_pos[2]].demand = new_demand[2]
    route1 = solution.routes[routes_pos[1]]
    route2 = solution.routes[routes_pos[2]]
    σ_data[routes_pos[1]] = update(data, route1.edges, sp_matrix)
    σ_data[routes_pos[2]] = update(data, route2.edges, sp_matrix)
    solution.routes[routes_pos[1]].cost = minimum(concatDepot(data, σ_data, sp_matrix, route1, routes_pos[1]))
    solution.routes[routes_pos[2]].cost = minimum(concatDepot(data, σ_data, sp_matrix, route2, routes_pos[2]))
    solution = calculateTotalCost(solution)
    return solution, σ_data
end

function demandSwapInter(data::Data, solution::Solution, routes_pos::Vector{Int64}, rq1::Int64, rq2::Int64, capacity::Int64)

    old_demand_route1 = solution.routes[routes_pos[1]].demand
    old_demand_route2 = solution.routes[routes_pos[2]].demand

    service1 = solution.routes[routes_pos[1]].edges[rq1]
    service2 = solution.routes[routes_pos[2]].edges[rq2]

    demand_service1 = data.edges[service1].demand
    demand_service2 = data.edges[service2].demand
    new_demand_route1 = old_demand_route1 + demand_service2 - demand_service1
    new_demand_route2 = old_demand_route2 + demand_service1 - demand_service2

    if new_demand_route1 <= capacity && new_demand_route2 <= capacity
        return true, [new_demand_route1, new_demand_route2]
    else 
        return false, [new_demand_route1, new_demand_route2]
    end
end

function perturbSwapInter()
    # Perturb the solution
end

function localSearchSwapInter(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, solution::Solution, route_pos1::Int64, rq1::Int64)
    accept = false
    route_1 = deepcopy(solution.routes[route_pos1])
    routes = shuffle(1:length(solution.routes))
    if rq1 != length(route_1.edges)
        for route_pos2 in routes
            if route_pos1 != route_pos2
                route_2 = deepcopy(solution.routes[route_pos2])
                requireds = shuffle(2:length(route_2.edges) - 1)
                for rq2 in requireds
                    if rq1 != rq2
                        routes = [route_1, route_2]
                        routes_pos = [route_pos1, route_pos2]
                        accept_demand, new_demand = demandSwapInter(data, solution, routes_pos, rq1, rq2, data.capacity)
                        if accept_demand
                            accept_lb, links, parts, origins = evalLBSwapInter(data, σ_data, sp_matrix, routes, routes_pos, rq1, rq2)
                            if accept_lb
                                accept = evalSwapInter(data, σ_data, sp_matrix, routes, routes_pos, links, parts, origins)
                                if accept
                                    new_solution, σ_data = moveSwapInter(data, σ_data, sp_matrix, solution, routes_pos, new_demand, rq1, rq2)
                                    return accept, new_solution, σ_data
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return accept, solution, σ_data
end


function deleteDepot(part::Tuple{Int64, Int64})
    return part[1] <= part[2]
end