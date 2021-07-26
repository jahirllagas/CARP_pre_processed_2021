mutable struct Route
    id      ::Int64
    edges   ::Vector{}
    demand  ::Int64
    n_edges ::Int64
end

mutable struct Solution
    n_routes    ::Int64
    routes      ::Vector{Route}
    total_cost ::Float64
end


function new_solution(routes, d_routes)
    list = []

    for i in 1:length(routes)
        route = Route(i, routes[i], d_routes[i], length(routes[i]))
        append!(list, [route])
    end

    solution = Solution(length(routes), list, 0)
    return solution
end
