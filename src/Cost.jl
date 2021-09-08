
function costDepot(data::Data, sp_matrix::Matrix{Int64}, ini::Int64, final::Int64)

    link_d_1 = sp_matrix[1, data.edges[ini].from.id]
    link_d_2 = sp_matrix[1, data.edges[ini].to.id]

    link_1_d = sp_matrix[data.edges[final].to.id, 1]
    link_2_d = sp_matrix[data.edges[final].from.id, 1]

    if ini == final #route with only 1 service
        mode_1_1 = link_d_1 + link_1_d
        mode_2_1 = link_d_2 + link_2_d
        mode_1_2 = link_d_1 + link_1_d
        mode_2_2 = link_d_2 + link_2_d
    else
        mode_1_1 = link_d_1 + link_1_d
        mode_2_1 = link_d_2 + link_1_d
        mode_1_2 = link_d_1 + link_2_d
        mode_2_2 = link_d_2 + link_2_d
    end
    return [mode_1_1 mode_1_2; mode_2_1 mode_2_2]
end

function calculateCost(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, solution::Solution)
    total = 0
    for r in 1:length(solution.routes)
        route_cost = minimum(concatDepot(data, σ_data, sp_matrix, solution.routes[r], r))
        solution.routes[r].cost = route_cost
        total = total + route_cost
    end
    solution.cost = total
    return solution
end 

function calculateTotalCost(solution::Solution)
    total = 0
    for r in 1:length(solution.routes)
        total = total + solution.routes[r].cost
    end
    solution.cost = total
    return solution
end 