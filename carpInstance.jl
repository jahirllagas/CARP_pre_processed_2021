mutable struct σ
    from        ::Int64
    to          ::Int64
    Modes       ::Matrix{Float64}
    lower_bound ::Float64
end
mutable struct Route
    id      ::Int64
    edges   ::Vector{Int64}
    demand  ::Int64
    n_edges ::Int64
    #cost    ::Float64
end

mutable struct Solution
    n_routes    ::Int64
    routes      ::Vector{Route}
    total_cost  ::Float64
end

mutable struct Perturb_params
    num_iter        ::Int64
    initial_accept  ::Float64
    final_accept    ::Float64
end



function new_solution(routes, d_routes)
    list_route = []
    for i in 1:length(routes)
        route = Route(i, vcat([0], routes[i], [0]), d_routes[i], length(routes[i]) + 2) # take into account depot
        append!(list_route, [route])
    end

    solution = Solution(length(routes), list_route, 0)
    return solution
end

function Base.show(io::IO, route::Route)
    print(io, "r$(route.id)")
end

function Base.show(io::IO, sigma::σ)

    print(io, "σ($(sigma.from), $(sigma.to))")
end