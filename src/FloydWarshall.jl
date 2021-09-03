using LightGraphs
using SimpleWeightedGraphs

function solveFloydWarshall(data::Data)::Matrix{Int64}
    g = SimpleWeightedGraph(length(data.vertices))
    for edge in data.edges
        add_edge!(g, edge.from.id, edge.to.id, edge.cost)
    end
    dists = floyd_warshall_shortest_paths(g).dists
    return [ Int64(round(value)) for value in dists ]
end
