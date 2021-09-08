using Random

include("Solution.jl")
include("Sigma.jl")
include("Preprocessed.jl")

function runConstructive(data::Data, sp_matrix::Matrix{Int64})

    requireds = shuffle(data.requireds)
    routes = Vector{Vector{Int64}}()
    total_demands = Vector{Int64}()

    for r in requireds
        if isempty(routes)
            push!(routes, [ r.id ])
            push!(total_demands, r.demand)
        else
            route = 0
            total_demand = 0
            for current_route in 1:length(routes)
                current_demand = total_demands[current_route] + r.demand
                if (current_demand <= data.capacity)
                    total_demand = current_demand
                    route = current_route
                end
            end
            if route == 0
                push!(routes, [ r.id ])
                push!(total_demands, r.demand)
            else                
                push!(routes[route], r.id)
                total_demands[route] = total_demand
            end
        end
    end
    routes = vcat.([ 0 ], routes, [ 0 ])

    σ_data = Vector{Matrix{σ}}()
    cost_routes = Vector{Float64}()
    total_cost = 0
    
    for r in 1:length(routes)
        push!(σ_data, update(data, routes[r], sp_matrix))
        cost_route = minimum(σ_data[r][2, end - 1].modes + costDepot(data, sp_matrix, 2, length(routes[r]) - 1))
        push!(cost_routes, cost_route)
        total_cost += cost_route
    end

    solution = Solution(cost_routes, total_cost, routes, total_demands)
    return solution, σ_data
end
