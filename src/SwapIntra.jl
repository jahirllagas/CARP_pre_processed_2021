include("Cost.jl")

function evalSwapIntra(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, route::Route, route_pos::Int64, links::Vector{Matrix{Float64}}, parts::Vector{Tuple{Int64, Int64}})
    profit = 0

    initial = CartesianIndex(parts[1])
    sequence = deepcopy(σ_data[route_pos][initial].modes)

    for i in 2:length(parts)
        final = CartesianIndex(parts[i])
        subsequence = deepcopy(σ_data[route_pos][final].modes)
        sequence = deepcopy(concatParts(sequence, links[i - 1], subsequence))
    end

    current = concatDepot(data, σ_data, sp_matrix, route, route_pos)
    new = sequence + costDepot(data, sp_matrix, route.edges[parts[1][1]], route.edges[parts[end][2]])
    profit = minimum(new) - minimum(current)

    if profit < 0
        return true
    else
        return false
    end
end

function evalLBSwapIntra(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, route::Route, route_pos::Int64, rq1::Int64, rq2::Int64)
    if rq1 > rq2
        rq1, rq2 = rq2, rq1
    end

    if rq1 + 1 == rq2
        parts = [(2, rq1 - 1), (rq2, rq2), (rq1, rq1), (rq2 + 1, length(route.edges) - 1)]
    else
        parts = [(2, rq1 - 1), (rq2, rq2), (rq1 + 1, rq2 - 1), (rq1, rq1), (rq2 + 1, length(route.edges) - 1)]
    end

    parts = parts[deleteDepot.(parts)]
    links, profit_lb = calculateLBSwapIntra(data, σ_data, sp_matrix, route, route_pos, parts)

    if profit_lb < 0
        return true, links, parts
    else
        return false, links, parts
    end
end

function calculateLBSwapIntra(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, route::Route, route_pos::Int64, parts::Vector{Tuple{Int64, Int64}})
    min_costs = Vector{Float64}()
    min_links = Vector{Float64}()
    links = Vector{Matrix{Float64}}()
    
    if length(parts) != 1
        for i in 1:length(parts) - 1
            part1 = [route.edges[parts[i][1]], route.edges[parts[i][2]]]
            part2 = [route.edges[parts[i + 1][1]], route.edges[parts[i + 1][2]]]
            link = getLinks(data, sp_matrix, part1, part2)
            push!(links, link)
            push!(min_links, minimum(link))
        end
    else
        push!(min_links, 0)
    end

    for i in 1:length(parts)
        subsequence = CartesianIndex(parts[i])
        push!(min_costs, σ_data[route_pos][subsequence].lower_bound)
    end
    depot = costDepot(data, sp_matrix, route.edges[parts[1][1]], route.edges[parts[end][2]])
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

function moveSwapIntra(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, solution::Solution, route_pos::Int64, rq1::Int64, rq2::Int64)
    # Effectively move the solution
    # First do SwapIntra move
    # Second update σ_data of the route
    # Third recalculate the cost of a route and the total cost
    solution.routes[route_pos].edges[rq1], solution.routes[route_pos].edges[rq2] = solution.routes[route_pos].edges[rq2], solution.routes[route_pos].edges[rq1]
    route = solution.routes[route_pos]
    σ_data[route_pos] = update(data, route.edges, sp_matrix)
    solution.routes[route_pos].cost = minimum(concatDepot(data, σ_data, sp_matrix, route, route_pos))
    solution = calculateTotalCost(solution)
    return solution, σ_data
end

function perturbSwapIntra()
    # Perturb the solution
end

function localSearchSwapIntra(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, solution::Solution, route_pos::Int64, rq1::Int64)
    accept = false
    route = deepcopy(solution.routes[route_pos])
    requireds = shuffle(2:length(route.edges) - 1)

    if rq1 != length(route.edges)
        for rq2 in requireds
            if rq1 != rq2
                accept_lb, links, parts = evalLBSwapIntra(data, σ_data, sp_matrix, route, route_pos, rq1, rq2)
                if accept_lb
                    accept = evalSwapIntra(data, σ_data, sp_matrix, route, route_pos, links, parts)
                    if accept
                        new_solution, σ_data = moveSwapIntra(data, σ_data, sp_matrix, solution, route_pos, rq1, rq2)
                        return accept, new_solution, σ_data
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