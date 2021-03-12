using Random
using Statistics

function swap_intra(sigma_data,route_pos,ROUTES,floyd_warshall_matrix,pos1,instance)
    accept=false

    if pos1 != length(ROUTES[route_pos]) # The deposit cannot move
        order_services=shuffle(rng,2:length(ROUTES[route_pos])-1) # The deposit cannot move

        for pos2 in order_services

            if pos2!=pos1
                ROUTES_av=deepcopy(ROUTES)
                list_route_pos=[route_pos]
                accept_LB,links=lower_bound(sigma_data,ROUTES_av,list_route_pos,floyd_warshall_matrix, pos1,pos2,instance,"swap_intra")
                
                if accept_LB==true
                    accept=after(sigma_data,ROUTES_av,list_route_pos,floyd_warshall_matrix, pos1,pos2,instance,"swap_intra",links)
                    
                    if accept==true
                        ROUTES_av[route_pos][pos1],ROUTES_av[route_pos][pos2] = ROUTES_av[route_pos][pos2], ROUTES_av[route_pos][pos1]

                        return accept, ROUTES_av,list_route_pos
                    end
                end 
            end
        end
    end
    return accept, ROUTES, [route_pos]
end
function relocate_intra(sigma_data,route_pos,ROUTES,floyd_warshall_matrix,pos1,instance)
    accept=false

    if pos1 != length(ROUTES[route_pos]) # The deposit cannot move
        order_services=shuffle(rng,2:length(ROUTES[route_pos])-1) # The deposit cannot move

        for pos2 in order_services

            if pos2!=pos1
                ROUTES_av=deepcopy(ROUTES)
                list_route_pos=[route_pos]
                accept_LB,links=lower_bound(sigma_data,ROUTES_av,list_route_pos,floyd_warshall_matrix, pos1,pos2,instance,"relocate_intra")
                
                if accept_LB==true
                    accept=after(sigma_data,ROUTES_av,list_route_pos,floyd_warshall_matrix, pos1,pos2,instance,"relocate_intra",links)
                    
                    if accept==true
                        service=splice!(ROUTES_av[route_pos],pos1) #remove
                        insert!(ROUTES_av[route_pos],pos2,service) #insert
                        return accept, ROUTES_av, list_route_pos
                    end
                end 
            end
        end
    end
    return accept, ROUTES, [route_pos]
end

function swap_inter(sigma_data,route_pos,ROUTES,D_ROUTES, floyd_warshall_matrix,pos1,instance)
    accept=false
    capacity=instance.CAPACITY
    if pos1 != length(ROUTES[route_pos]) # The deposit cannot move
        order_routes=shuffle(rng,1:length(ROUTES)) # The deposit cannot move

        for route_pos_2 in order_routes
            if route_pos != route_pos_2
                order_services=shuffle(rng,2:length(ROUTES[route_pos_2])-1) # The deposit cannot move
                for pos2 in order_services

                    ROUTES_av=deepcopy(ROUTES)
                    D_ROUTES_av=deepcopy(D_ROUTES)
                    list_route_pos=[route_pos,route_pos_2]
                    new_demand=[]
                    accept_demand,new_demand=update_demand(ROUTES_av,D_ROUTES_av,list_route_pos,pos1,pos2,capacity)
                    if accept_demand==true
                        accept_LB,links=lower_bound(sigma_data,ROUTES_av,list_route_pos,floyd_warshall_matrix, pos1,pos2,instance,"swap_inter")
                        if accept_LB==true
                            accept=after(sigma_data,ROUTES_av,list_route_pos,floyd_warshall_matrix, pos1,pos2,instance,"swap_inter",links)
                            
                            if accept==true
                                ROUTES_av[route_pos][pos1],ROUTES_av[route_pos_2][pos2] = ROUTES_av[route_pos_2][pos2], ROUTES_av[route_pos][pos1]
                                return accept, ROUTES_av,new_demand,list_route_pos
                            end
                        end
                    end
                end
            end
        end
    end
    return accept, ROUTES, [],[route_pos]
end