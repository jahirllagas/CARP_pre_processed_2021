using Random

include("Solution.jl")

function runConstructive(data::Data)

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

    solution = Solution(routes, total_demands)
    return solution
end
