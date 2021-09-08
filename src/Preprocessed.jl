function update(data::Data, route::Vector{Int64}, sp_matrix::Matrix{Int64})::Matrix{σ}
    matrix_σ = σ[σ(0, 0, zeros(Float64, 2, 2), 0) for i = 1:length(route), j = 1:length(route)]
    for i in 2:length(route) - 1
        matrix_σ[i, i] = deepcopy(concatRequired(data, matrix_σ, route, i, i, sp_matrix))
    end
    for i in 2:length(route) - 1
        for j in (i + 1):length(route) - 1
            matrix_σ[i, j] =  deepcopy(concatRequired(data, matrix_σ, route, i, j, sp_matrix))
        end
    end
    return matrix_σ
end

function concatRequired(data::Data, matrix_σ::Matrix{σ}, route::Vector{Int64}, rq1::Int64, rq2::Int64, sp_matrix::Matrix{Int64})::σ
    if (rq1 == rq2)
        cost_service = data.edges[route[rq1]].cost
        return σ(route[rq1], route[rq1], [cost_service Inf; Inf cost_service], cost_service)

    else
        finish_1 = data.edges[route[rq2 - 1]]
        start = data.edges[route[rq2]]

        finish_nodes = [finish_1.from.id, finish_1.to.id]
        start_nodes = [start.from.id, start.to.id]

        sequence = matrix_σ[rq1, rq2 - 1].modes      
        required = matrix_σ[rq2, rq2].modes 

        matrix_links = Links(sp_matrix, finish_nodes, start_nodes)
        matrix_sequence = concatParts(sequence, matrix_links, required)

        return σ(route[rq1], route[rq2], matrix_sequence, minimum(matrix_sequence))
    end
end

function Links(sp_matrix::Matrix{Int64}, finish_nodes::Vector{Int64}, start_nodes::Vector{Int64})::Matrix{Float64}
    link_1_1 = sp_matrix[finish_nodes[2], start_nodes[1]]
    link_2_1 = sp_matrix[finish_nodes[1], start_nodes[1]]
    link_1_2 = sp_matrix[finish_nodes[2], start_nodes[2]]
    link_2_2 = sp_matrix[finish_nodes[1], start_nodes[2]]
    return [link_1_1 link_1_2; link_2_1 link_2_2]
end

function concatForw(sequence::Matrix{Float64}, matrix_links::Matrix{Float64}, required::Matrix{Float64}, k::Int64, l::Int64)::Float64
    mode = Vector{Float64}()
    for x in 1:2
        for y in 1:2
            push!(mode, sequence[k, x] + matrix_links[x, y] + required[y, l])
        end
    end
    return minimum(mode)
end


function concatDepot(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, route::Route, route_pos::Int64)
    ini = route.edges[2]
    final = route.edges[end - 1]

    link_d_1 = sp_matrix[1, data.edges[ini].from.id]
    link_d_2 = sp_matrix[1, data.edges[ini].to.id]

    link_1_d = sp_matrix[data.edges[final].to.id, 1]
    link_2_d = sp_matrix[data.edges[final].from.id, 1]

    sequence = σ_data[route_pos][2, end - 1].modes

    if ini == final
        mode_1_1 = link_d_1 + sequence[1, 1] + link_1_d
        mode_2_1 = Inf
        mode_1_2 = Inf
        mode_2_2 = link_d_2 + sequence[2, 2] + link_2_d 
    else
        mode_1_1 = link_d_1 + sequence[1, 1] + link_1_d
        mode_2_1 = link_d_2 + sequence[2, 1] + link_1_d
        mode_1_2 = link_d_1 + sequence[1, 2] + link_2_d
        mode_2_2 = link_d_2 + sequence[2, 2] + link_2_d
    end
    return [mode_1_1  mode_1_2; mode_2_1 mode_2_2]
end


function concatParts(sequence::Matrix{Float64}, links::Matrix{Float64}, subsequence::Matrix{Float64})

    mode_1_1 = concatForw(sequence, links, subsequence, 1, 1)
    mode_2_1 = concatForw(sequence, links, subsequence, 2, 1)
    mode_1_2 = concatForw(sequence, links, subsequence, 1, 2)
    mode_2_2 = concatForw(sequence, links, subsequence, 2, 2)
        
    return [mode_1_1 mode_1_2; mode_2_1 mode_2_2]
end