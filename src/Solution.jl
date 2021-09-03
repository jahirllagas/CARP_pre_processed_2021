include("Route.jl")

mutable struct Solution
    routes::Vector{Route}
    cost  ::Float64

    function Solution(routes::Vector{Vector{Int64}}, total_demands::Vector{Int64})
        new_routes = Route[]
        for r in 1:length(routes)
            route = Route(r, vcat([ 0 ], routes[r], [ 0 ]), total_demands[r], 0)
            push!(new_routes, route)
        end
    
        cost = 0
        return new(new_routes, cost)
    end
end
