include("Route.jl")

mutable struct Solution
    routes::Vector{Route}
    cost  ::Float64

    function Solution(cost_routes::Vector{Float64}, total_cost::Float64, routes::Vector{Vector{Int64}}, total_demands::Vector{Int64})
        new_routes = Route[]
        for r in 1:length(routes) 
            route = Route(r, routes[r], total_demands[r], cost_routes[r])
            push!(new_routes, route)
        end
        return new(new_routes, total_cost)
    end
end
