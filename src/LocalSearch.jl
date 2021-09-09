include("SwapIntra.jl")
include("RelocateIntra.jl")
include("SwapInter.jl")
include("RelocateInter.jl")
const SWAP_INTRA = 1
const RELOCATE_INTRA = 2
const SWAP_INTER = 3
const RELOCATE_INTER = 4

function localSearch(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, solution::Solution)

    moved = true
    while moved
        moved = false
        routes = shuffle(1:length(solution.routes))

        for r in routes
            route = solution.routes[r]
            requireds = shuffle(2:length(route.edges))

            for rq1 in requireds
                order_moves = shuffle(1:4)

                for i in order_moves
                    if i == SWAP_INTRA
                        moved, solution, σ_data = localSearchSwapIntra(data, σ_data, sp_matrix, solution, r, rq1)
                    elseif i == RELOCATE_INTRA
                        moved, solution, σ_data = localSearchRelocateIntra(data, σ_data, sp_matrix, solution, r, rq1)
                    elseif i == SWAP_INTER
                        moved, solution, σ_data = localSearchSwapInter(data, σ_data, sp_matrix, solution, r, rq1)
                    elseif i == RELOCATE_INTER
                        moved, solution, σ_data = localSearchRelocateInter(data, σ_data, sp_matrix, solution, r, rq1)
                    end
                    if moved break end
                end
                if moved break end
            end
            if moved break end
        end  
    end
    return solution, σ_data
end

function perturb(data::Data, σ_data::Vector{Matrix{σ}}, sp_matrix::Matrix{Int64}, solution::Solution, perturb::Int64)
    moved = 0
    while moved < perturb
        routes = shuffle(1:length(solution.routes))

        for r in routes
            route = solution.routes[r]
            requireds = shuffle(2:length(route.edges))

            for rq1 in requireds
                order_moves = shuffle(1:4)

                for i in order_moves
                    if i == SWAP_INTRA
                        moved, solution, σ_data = perturbSwapIntra(data, σ_data, sp_matrix, solution, r, rq1, moved)
                    elseif i == RELOCATE_INTRA
                        moved, solution, σ_data = perturbRelocateIntra(data, σ_data, sp_matrix, solution, r, rq1, moved)
                    elseif i == SWAP_INTER
                        moved, solution, σ_data = perturbSwapInter(data, σ_data, sp_matrix, solution, r, rq1, moved)
                    elseif i == RELOCATE_INTER
                        moved, solution, σ_data = perturbRelocateInter(data, σ_data, sp_matrix, solution, r, rq1, moved)
                    end
                    break
                end
                break
            end
            break
        end  
    end
    return solution, σ_data
end
