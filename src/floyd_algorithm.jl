function floyd_warshall(n_vertex, edges)
    g = SimpleWeightedGraph(n_vertex)
    for i in 1:length(edges)
        add_edge!(g, edges[i].from.id, edges[i].to.id, edges[i].cost)
    end
    return floyd_warshall_shortest_paths(g)
end

function Total_Cost(solution ,σ_data)
    TOTAL_COST = 0
    for i in 1:solution.n_routes
        cost_modes = FORW_D_Subsequence_D(data, solution.routes[i], i, σ_data)
        TOTAL_COST = TOTAL_COST + minimum(cost_modes)
    end
    return TOTAL_COST
end 