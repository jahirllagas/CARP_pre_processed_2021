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
    else
        return
    end
end

function get_links(sigma_data,Part1,Part2,floyd_warshall_matrix,instance)

    if Part1[2]==-1
        edge_ini=instance.EDGES[Part2[1]]

        Link_D_1=floyd_warshall_matrix[1,edge_ini[1]]
        Link_D_2=floyd_warshall_matrix[1,edge_ini[2]]
        return [Link_D_1,Link_D_1,Link_D_2,Link_D_2],min(Link_D_1,Link_D_1,Link_D_2,Link_D_2)
    
    elseif Part2[1]==0
        edge_end=instance.EDGES[Part1[2]]

        Link_1_D=floyd_warshall_matrix[edge_end[2],1]
        Link_2_D=floyd_warshall_matrix[edge_end[1],1]
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
        else
            Parts=[[route[1],route[pos1-1]],[route[pos2],route[pos2]],[route[pos1+1],route[pos2-1]],[route[pos1],route[pos1]],[route[pos2+1],route[length(route)]]]
        end

        end_service=-2 #Impossible
        if pos2+1==length(route)-1 #if the subsequence begins in the ultimate service until the deposit. This subsequence is considered as a single service
            end_service=route[pos2+1]
        end
        ini=Parts[1]
        final=Parts[2]
        Modes=deepcopy(concat_links_know(Modes,sigma_data,list_pos_route,1,ini,final,links[1],end_service))
        for i in 2:length(Parts)-1
            ini=[ini[1],final[2]]
            final=Parts[i+1]
            
            Modes=deepcopy(concat_links_know(Modes,sigma_data,list_pos_route,1,ini,final,links[i],end_service))
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
        
        ini=Parts[1]
        final=Parts[2]
        Modes=deepcopy(concat_links_know(Modes,sigma_data,list_pos_route,1,ini,final,links[1],end_service))
        for i in 2:length(Parts)-1
            ini=[ini[1],final[2]]
            final=Parts[i+1]
            Modes=deepcopy(concat_links_know(Modes,sigma_data,list_pos_route,1,ini,final,links[i],end_service))
        end

        if minimum(Modes)-minimum(sigma_data[list_pos_route[1]][[-1,0]][5])<0
            println("Total_cost_concat= ",Modes)
            return true
        else
            return false
        end

    else 
        return
    end    
end