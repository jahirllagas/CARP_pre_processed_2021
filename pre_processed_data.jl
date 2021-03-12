#update all routes
function preprocessing_total_data(ROUTES,floyd_warshall_matrix,instance)
    sigma_data=[]
    for pos_route in 1:length(ROUTES)
        dict_ROUTE=update(ROUTES,pos_route,floyd_warshall_matrix,instance)
        append!(sigma_data,[dict_ROUTE])
    end
    return sigma_data
end
#update one route
function preprocessing_data(ROUTES,pos_route,floyd_warshall_matrix,instance)
    dict_ROUTE=update(ROUTES,pos_route,floyd_warshall_matrix,instance)
    return dict_ROUTE
end

function update(ROUTES,pos_route,floyd_warshall_matrix,instance)
    route=ROUTES[pos_route]
    dict_ROUTE=create_dict_route(route)
    #Each service on the route is saved first
    for i in 1:length(route)
        dict_ROUTE[[route[i],route[i]]]=concat_FORW(dict_ROUTE,route,i,i,floyd_warshall_matrix,instance)
    end

    for i in 1:length(route)
        for j in i+1:length(route)
            dict_ROUTE[[route[i],route[j]]]=concat_FORW(dict_ROUTE,route,i,j,floyd_warshall_matrix,instance)
        end
    end 
    return dict_ROUTE
end

function create_dict_route(route) 
    #Dict for each route
    dict_ROUTE=Dict{Array{Int64,1},Array{Float64,1}}()
    for i in 1:length(route)
        for j in i:length(route) #upper part
            push!(dict_ROUTE,[route[i],route[j]] => [0,0,0,0,0])
        end
    end
    return dict_ROUTE
end

function concat_FORW(dict_ROUTE,route,pos1, pos2,floyd_warshall_matrix,instance) #concatenation one by one
    if (pos1==pos2)
        if pos1==1 || pos1==length(route)
            return [0,0,0,0,0]
        else
            service_cost=instance.COST[route[pos1]]
            return [service_cost,service_cost,service_cost,service_cost,service_cost]
        end
    else
        finish=route[pos2-1]
        start=route[pos2]
        if finish==-1 #Depot
            finish_nodes=[1,1]
        else
            finish_nodes=instance.EDGES[finish]
        end
        if start==0 #Depot
            start_nodes=[1,1]
        else 
            start_nodes=instance.EDGES[start]
        end

        Mode_finish=dict_ROUTE[[route[pos1],finish]]
        Mode_start=dict_ROUTE[[start,start]]

        if start==0 #return to the deposit
            Link_1_D=floyd_warshall_matrix[finish_nodes[2],start_nodes[1]]
            Link_2_D=floyd_warshall_matrix[finish_nodes[1],start_nodes[2]]
            Mode_1_1=Mode_finish[1]+Link_1_D
            Mode_2_1=Mode_finish[2]+Link_1_D
            Mode_1_2=Mode_finish[3]+Link_2_D
            Mode_2_2=Mode_finish[4]+Link_2_D
            return [Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2, min(Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2)]

        elseif finish==route[pos1] #service to service
            Link_1_1=floyd_warshall_matrix[finish_nodes[2],start_nodes[1]]
            Link_2_1=floyd_warshall_matrix[finish_nodes[1],start_nodes[1]]
            Link_1_2=floyd_warshall_matrix[finish_nodes[2],start_nodes[2]]
            Link_2_2=floyd_warshall_matrix[finish_nodes[1],start_nodes[2]]
            Mode_1_1=Mode_finish[1]+Link_1_1+Mode_start[1]
            Mode_2_1=Mode_finish[2]+Link_2_1+Mode_start[2]
            Mode_1_2=Mode_finish[3]+Link_1_2+Mode_start[3]
            Mode_2_2=Mode_finish[4]+Link_2_2+Mode_start[4]
            return [Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2, min(Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2)]

        else #concact to service
            Link_1_1=floyd_warshall_matrix[finish_nodes[2],start_nodes[1]]
            Link_2_1=floyd_warshall_matrix[finish_nodes[1],start_nodes[1]]
            Link_1_2=floyd_warshall_matrix[finish_nodes[2],start_nodes[2]]
            Link_2_2=floyd_warshall_matrix[finish_nodes[1],start_nodes[2]]
        end

        Mode_1_1=minimum([Mode_finish[1]+Link_1_1+Mode_start[1],Mode_finish[3]+Link_2_1+Mode_start[1]])
        Mode_2_1=minimum([Mode_finish[2]+Link_1_1+Mode_start[1],Mode_finish[4]+Link_2_1+Mode_start[1]])
        Mode_1_2=minimum([Mode_finish[1]+Link_1_2+Mode_start[4],Mode_finish[3]+Link_2_2+Mode_start[4]])
        Mode_2_2=minimum([Mode_finish[2]+Link_1_2+Mode_start[4],Mode_finish[4]+Link_2_2+Mode_start[4]])
        return [Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2, min(Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2)]

    end
end

function concat_links_know(Modes,sigma_data,list_pos_route,sigma_1,sigma_2,links,end_service,origin)
    
    if isempty(Modes)
        ini=sigma_data[list_pos_route[origin[1]]][sigma_1]
    else
        ini=Modes
    end
    final=sigma_data[list_pos_route[origin[2]]][sigma_2]
    if sigma_1[1]==sigma_1[2]
        if sigma_2[1]==sigma_2[2] #concat service to service
            Mode_1_1=ini[1]+links[1]+final[1]
            Mode_2_1=ini[4]+links[2]+final[1]
            Mode_1_2=ini[1]+links[3]+final[4]
            Mode_2_2=ini[4]+links[4]+final[4]
            Modes=deepcopy([Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2])        
        else #concat service to subsequence
            Mode_1_1=min(ini[1]+links[1]+final[1],ini[1]+links[3]+final[2])
            Mode_2_1=min(ini[4]+links[2]+final[1],ini[3]+links[4]+final[2])
            Mode_1_2=min(ini[1]+links[1]+final[3],ini[1]+links[3]+final[4])
            Mode_2_2=min(ini[4]+links[2]+final[3],ini[4]+links[4]+final[4])
            Modes=deepcopy([Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2])
        end
    else
        if sigma_2[1]==0
            Mode_1_1=ini[1]+links[1]
            Mode_2_1=ini[2]+links[2]
            Mode_1_2=ini[3]+links[3]
            Mode_2_2=ini[4]+links[4]
            Modes=deepcopy([Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2])
        elseif sigma_2[1]==sigma_2[2] || sigma_2[1]==end_service#concat subsequence to service
            Mode_1_1=min(ini[1]+links[1]+final[1],ini[3]+links[2]+final[1])
            Mode_2_1=min(ini[2]+links[1]+final[1],ini[4]+links[2]+final[1])
            Mode_1_2=min(ini[1]+links[3]+final[4],ini[3]+links[4]+final[4])
            Mode_2_2=min(ini[2]+links[3]+final[4],ini[4]+links[4]+final[4])
            Modes=deepcopy([Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2])
        else #concat subsequence to subsequence
            Mode_1_1=min(ini[1]+links[1]+final[1],ini[3]+links[2]+final[1],ini[1]+links[3]+final[2],ini[3]+links[4]+final[2])
            Mode_2_1=min(ini[2]+links[1]+final[1],ini[4]+links[2]+final[1],ini[2]+links[3]+final[2],ini[4]+links[4]+final[2])
            Mode_1_2=min(ini[1]+links[1]+final[3],ini[3]+links[2]+final[3],ini[1]+links[3]+final[4],ini[3]+links[4]+final[4])
            Mode_2_2=min(ini[2]+links[1]+final[3],ini[4]+links[2]+final[3],ini[2]+links[3]+final[4],ini[4]+links[4]+final[4])
            Modes=deepcopy([Mode_1_1,Mode_2_1,Mode_1_2,Mode_2_2])
        end
    end
    return Modes
end