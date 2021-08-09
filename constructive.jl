function constructive(Floyd_Warshall, data, depot)

    clients_order = shuffle(rng, data.requireds)
    #Empty route list
    ROUTES = []
    #Save demand
    D_ROUTES = []
    for c in clients_order
        if  isempty(ROUTES)
            append!(ROUTES, [[c.id]])
            append!(D_ROUTES, c.demand)
        else
            pos = 0
            demand = 0
            for route_pos in 1:length(ROUTES)
                demand_eval = D_ROUTES[route_pos] + c.demand #Current demand + new client
                if (demand_eval <= data.capacity) #Limited capacity
                    demand = demand_eval
                    pos = route_pos
                end
            end
            if pos == 0
                append!(ROUTES, [[c.id]])
                append!(D_ROUTES, c.demand)
            else                
                append!(ROUTES[pos], [c.id])
                D_ROUTES[pos] = demand
            end
        end
    end

    start_solution = new_solution(ROUTES, D_ROUTES)
    return start_solution
end
