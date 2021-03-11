using Random
using Statistics

function swap_intra(sigma_data,route_pos,ROUTES,floyd_warshall_matrix,pos1,instance)
    accept=false

    if pos1 != length(ROUTES[route_pos]) # The deposit cannot move
        ordem_cliente2=shuffle(rng,2:length(ROUTES[route_pos])-1) # The deposit cannot move

        for pos2 in ordem_cliente2

            if pos2!=pos1
                ROUTES_av=deepcopy(ROUTES)
                list_route_pos=[route_pos]
                accept_LB,links=lower_bound(sigma_data,ROUTES_av,list_route_pos,floyd_warshall_matrix, pos1,pos2,instance,"swap_intra")
                
                if accept_LB==true
                    accept=after(sigma_data,ROUTES_av,list_route_pos,floyd_warshall_matrix, pos1,pos2,instance,"swap_intra",links)
                    
                    if accept==true
                        ROUTES_av[route_pos][pos1],ROUTES_av[route_pos][pos2] = ROUTES_av[route_pos][pos2], ROUTES_av[route_pos][pos1]

                        return accept, ROUTES_av
                    end
                end 
            end
        end
    end
    return accept, ROUTES
end