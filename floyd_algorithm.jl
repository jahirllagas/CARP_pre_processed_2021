using LightGraphs, SimpleWeightedGraphs

function floyd_warshall(n_nodes,edges,cost)
    g = SimpleWeightedGraph(n_nodes)
    for i in 1:length(edges)
        add_edge!(g, edges[i][1], edges[i][2], cost[i])
    end
    return floyd_warshall_shortest_paths(g)
end