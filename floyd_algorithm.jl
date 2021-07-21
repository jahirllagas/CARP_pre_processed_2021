function floyd_warshall(n_vertex, edges)
    g = SimpleWeightedGraph(n_vertex)
    for i in 1:length(edges)
        add_edge!(g, edges[i].from.id, edges[i].to.id, edges[i].cost)
    end
    return floyd_warshall_shortest_paths(g)
end