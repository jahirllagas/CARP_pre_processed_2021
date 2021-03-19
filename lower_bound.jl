function lower_bound(sigma_data,ROUTES,list_route_pos,floyd_warshall_matrix, pos1,pos2,instance,type)
    Min_cost=[]
    Links=[]
    Min_links=[]
    if type=="swap_intra"
        if pos1>pos2
            pos1,pos2=pos2,pos1
        end
        route=ROUTES[list_route_pos[1]]
        if pos1+1==pos2
            Parts=[[route[1],route[pos1-1]],[route[pos2],route[pos2]],[route[pos1],route[pos1]],[route[pos2+1],route[length(route)]]]
        else
            Parts=[[route[1],route[pos1-1]],[route[pos2],route[pos2]],[route[pos1+1],route[pos2-1]],[route[pos1],route[pos1]],[route[pos2+1],route[length(route)]]]
        end

        for i in 1:length(Parts)-1
            Link, min_link =get_links(sigma_data,Parts[i],Parts[i+1],floyd_warshall_matrix,instance)
            append!(Links,[Link])
            append!(Min_links,min_link)
        end
        for i in 1:length(Parts)
            ini=Parts[i][1]
            final=Parts[i][2]
            append!(Min_cost,sigma_data[list_route_pos[1]][[ini,final]][5]) #min_cost of modes
        end  

        if sum(Min_cost)+sum(Min_links)-minimum(sigma_data[list_route_pos[1]][[-1,0]][5])<0
            return true,Links
        else
            return false,Links
        end     
    elseif type=="relocate_intra"
        route=ROUTES[list_route_pos[1]]
        if pos2>pos1
            Parts=[[route[1],route[pos1-1]],[route[pos1+1],route[pos2]],[route[pos1],route[pos1]],[route[pos2+1],route[length(route)]]]
        else
            Parts=[[route[1],route[pos2-1]],[route[pos1],route[pos1]],[route[pos2],route[pos1-1]],[route[pos1+1],route[length(route)]]]
        end

        for i in 1:length(Parts)-1
            Link, min_link =get_links(sigma_data,Parts[i],Parts[i+1],floyd_warshall_matrix,instance)
            append!(Links,[Link])
            append!(Min_links,min_link)
        end
        for i in 1:length(Parts)
            ini=Parts[i][1]
            final=Parts[i][2]
            append!(Min_cost,sigma_data[list_route_pos[1]][[ini,final]][5]) #min_cost of modes
        end  

        if sum(Min_cost)+sum(Min_links)-minimum(sigma_data[list_route_pos[1]][[-1,0]][5])<0
            return true,Links
        else
            return false,Links
        end

    elseif type=="swap_inter"

        route_1,route_2=ROUTES[list_route_pos[1]],ROUTES[list_route_pos[2]]
        Part_route_1=[[route_1[1],route_1[pos1-1]],[route_2[pos2],route_2[pos2]],[route_1[pos1+1],route_1[length(route_1)]]]
        Part_route_2=[[route_2[1],route_2[pos2-1]],[route_1[pos1],route_1[pos1]],[route_2[pos2+1],route_2[length(route_2)]]]
        route_1_links=[]
        route_2_links=[]
        for i in 1:length(Part_route_1)-1
            Link, min_link =get_links(sigma_data,Part_route_1[i],Part_route_1[i+1],floyd_warshall_matrix,instance)
            append!(route_1_links,[Link])
            append!(Min_links,min_link)
        end
        for i in 1:length(Part_route_2)-1
            Link, min_link =get_links(sigma_data,Part_route_2[i],Part_route_2[i+1],floyd_warshall_matrix,instance)
            append!(route_2_links,[Link])
            append!(Min_links,min_link)
        end
        append!(Links,[route_1_links])
        append!(Links,[route_2_links])

        append!(Min_cost,sigma_data[list_route_pos[1]][Part_route_1[1]][5]) #min_cost of modes
        append!(Min_cost,sigma_data[list_route_pos[2]][Part_route_1[2]][5]) #min_cost of modes
        append!(Min_cost,sigma_data[list_route_pos[1]][Part_route_1[3]][5]) #min_cost of modes
        append!(Min_cost,sigma_data[list_route_pos[2]][Part_route_2[1]][5]) #min_cost of modes
        append!(Min_cost,sigma_data[list_route_pos[1]][Part_route_2[2]][5]) #min_cost of modes
        append!(Min_cost,sigma_data[list_route_pos[2]][Part_route_2[3]][5]) #min_cost of modes

        if sum(Min_cost)+sum(Min_links)-minimum(sigma_data[list_route_pos[1]][[-1,0]][5])-minimum(sigma_data[list_route_pos[2]][[-1,0]][5])<0
            return true,Links
        else
            return false,Links
        end  
    end
end

function get_links(sigma_data,Part1,Part2,floyd_warshall_matrix,instance)
    depot=instance.DEPOT
    if Part1[2]==-1
        edge_ini=instance.EDGES[Part2[1]]

        Link_D_1=floyd_warshall_matrix[depot,edge_ini[1]]
        Link_D_2=floyd_warshall_matrix[depot,edge_ini[2]]
        return [Link_D_1,Link_D_1,Link_D_2,Link_D_2],min(Link_D_1,Link_D_1,Link_D_2,Link_D_2)
    
    elseif Part2[1]==0
        edge_end=instance.EDGES[Part1[2]]

        Link_1_D=floyd_warshall_matrix[edge_end[2],depot]
        Link_2_D=floyd_warshall_matrix[edge_end[1],depot]
        return [Link_1_D,Link_1_D,Link_2_D,Link_2_D],min(Link_1_D,Link_1_D,Link_2_D,Link_2_D)
    
    else
        edge_end=instance.EDGES[Part1[2]]
        edge_ini=instance.EDGES[Part2[1]]

        Link_1_1=floyd_warshall_matrix[edge_end[2],edge_ini[1]]
        Link_2_1=floyd_warshall_matrix[edge_end[1],edge_ini[1]]
        Link_1_2=floyd_warshall_matrix[edge_end[2],edge_ini[2]]
        Link_2_2=floyd_warshall_matrix[edge_end[1],edge_ini[2]]
        return [Link_1_1,Link_2_1,Link_1_2,Link_2_2],min(Link_1_1,Link_2_1,Link_1_2,Link_2_2)
    end
end

function after(sigma_data,ROUTES,list_pos_route,floyd_warshall_matrix, pos1,pos2,instance,type,links)

    ROUTES_av=deepcopy(ROUTES)

    if type=="swap_intra" #swap
        Modes=[]
        if pos1>pos2
            pos1,pos2=pos2,pos1
        end
        route=ROUTES[list_pos_route[1]]

        if pos1+1==pos2
            Parts=[[route[1],route[pos1-1]],[route[pos2],route[pos2]],[route[pos1],route[pos1]],[route[pos2+1],route[length(route)]]]
            origin=[1,1,1,1]
        else
            Parts=[[route[1],route[pos1-1]],[route[pos2],route[pos2]],[route[pos1+1],route[pos2-1]],[route[pos1],route[pos1]],[route[pos2+1],route[length(route)]]]
            origin=[1,1,1,1,1]
        end

        end_service=-2 #Impossible
        if pos2+1==length(route)-1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
            end_service=route[pos2+1]
        end
        ini=Parts[1]
        final=Parts[2]
        Modes=deepcopy(concat_links_know(Modes,sigma_data,list_pos_route,ini,final,links[1],end_service,origin[1:2]))
        for i in 2:length(Parts)-1
            ini=[ini[1],final[2]]
            final=Parts[i+1]
            
            Modes=deepcopy(concat_links_know(Modes,sigma_data,list_pos_route,ini,final,links[i],end_service,origin[i:i+1]))
        end

        if minimum(Modes)-minimum(sigma_data[list_pos_route[1]][[-1,0]][5])<0
            println("Total_cost_concat= ",Modes)
            return true
        else
            return false
        end
    elseif type=="relocate_intra"
        Modes=[]
        route=ROUTES[list_pos_route[1]]
        end_service=-2 #Impossible
        if pos2>pos1
            Parts=[[route[1],route[pos1-1]],[route[pos1+1],route[pos2]],[route[pos1],route[pos1]],[route[pos2+1],route[length(route)]]]
            if pos2+1==length(route)-1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
                end_service=route[pos2+1]
            end
        else
            Parts=[[route[1],route[pos2-1]],[route[pos1],route[pos1]],[route[pos2],route[pos1-1]],[route[pos1+1],route[length(route)]]]
            if pos1+1==length(route)-1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
                end_service=route[pos1+1]
            end            
        end
        origin=[1,1,1,1]
        
        ini=Parts[1]
        final=Parts[2]
        Modes=deepcopy(concat_links_know(Modes,sigma_data,list_pos_route,ini,final,links[1],end_service,origin[1:2]))
        for i in 2:length(Parts)-1
            ini=[ini[1],final[2]]
            final=Parts[i+1]
            Modes=deepcopy(concat_links_know(Modes,sigma_data,list_pos_route,ini,final,links[i],end_service,origin[i:i+1]))
        end

        if minimum(Modes)-minimum(sigma_data[list_pos_route[1]][[-1,0]][5])<0
            println("Total_cost_concat= ",Modes)
            return true
        else
            return false
        end

    elseif type=="swap_inter" #swap
            Modes_routes=[]
            route_1,route_2 =ROUTES[list_pos_route[1]],ROUTES[list_pos_route[2]]

            Part_routes=[[[route_1[1],route_1[pos1-1]],[route_2[pos2],route_2[pos2]],[route_1[pos1+1],route_1[length(route_1)]]],
            [[route_2[1],route_2[pos2-1]],[route_1[pos1],route_1[pos1]],[route_2[pos2+1],route_2[length(route_2)]]]]
            origin=[[1,2,1],[2,1,2]]
            for route in 1:2
                Modes=[]
                end_service=-2 #Impossible
                if route==1
                    if pos1+1==length(route_1)-1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
                        end_service=route_1[pos1+1]
                    end
                else
                    if pos2+1==length(route_2)-1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
                        end_service=route_2[pos2+1]
                    end
                end
                ini=Part_routes[route][1]
                final=Part_routes[route][2]
                Modes=deepcopy(concat_links_know(Modes,sigma_data,list_pos_route,ini,final,links[route][1],end_service,origin[route][1:2]))
                for i in 2:length(Part_routes[route])-1
                    ini=[ini[1],final[2]]
                    final=Part_routes[route][i+1]   
                    Modes=deepcopy(concat_links_know(Modes,sigma_data,list_pos_route,ini,final,links[route][i],end_service,origin[route][i:i+1]))
                end
                append!(Modes_routes,[Modes])
            end

    
            if minimum(Modes_routes[1])+minimum(Modes_routes[2])-minimum(sigma_data[list_pos_route[1]][[-1,0]][5])-minimum(sigma_data[list_pos_route[2]][[-1,0]][5])<0
                for i in 1:2
                    println("Total_cost_concat= ",Modes_routes[i])
                end
                return true
            else
                return false
            end
    end    
end

function update_demand(ROUTES_av,D_ROUTES_av,list_route_pos,pos1,pos2,capacity)
    
    old_demand_route_1=D_ROUTES_av[list_route_pos[1]]
    old_demand_route_2=D_ROUTES_av[list_route_pos[2]]

    service_1=ROUTES_av[list_route_pos[1]][pos1]
    service_2=ROUTES_av[list_route_pos[2]][pos2]

    demand_service_1=instance.DEMAND[service_1]
    demand_service_2=instance.DEMAND[service_2]

    new_demand_route_1=old_demand_route_1+demand_service_2-demand_service_1
    new_demand_route_2=old_demand_route_2+demand_service_1-demand_service_2

    if new_demand_route_1 <= capacity && new_demand_route_2 <= capacity
        return true,[new_demand_route_1,new_demand_route_2]
    else 
        return false,[new_demand_route_1,new_demand_route_2]
    end
end