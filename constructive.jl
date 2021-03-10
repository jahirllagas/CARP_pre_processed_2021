using Random
using Statistics


function constructive(floyd_warshall_matrix, instance,cost_open_route)
    clients_order=shuffle(rng,1:instance.ARISTAS_REQ)
    #Empty route list
    ROUTES=[]
    #Save demand
    D_ROUTES=[]
    for c in clients_order
        if  isempty(ROUTES)
            append!(ROUTES,[[-1,c]])
            append!(D_ROUTES, instance.DEMAND[c])
        else
            pos=0
            demand=0
            for route_pos in 1:length(ROUTES)
                demand_eval=D_ROUTES[route_pos] + instance.DEMAND[c] #Current demand + new client
                if (demand_eval <= instance.CAPACITY) #Limited capacity
                    demand=demand_eval
                    pos= route_pos
                end
            end
            if pos==0
                append!(ROUTES,[[-1,c]])
                append!(D_ROUTES, instance.DEMAND[c])
            else                
                append!(ROUTES[pos],c)
                D_ROUTES[pos]=demand
            end
        end
    end
    for route_pos in 1:length(ROUTES)
        append!(ROUTES[route_pos],0)
    end
    return ROUTES, D_ROUTES
end
