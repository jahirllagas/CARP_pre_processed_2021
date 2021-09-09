include("Constructive.jl")
include("LocalSearch.jl")
function runILS(params::Parameters, data::Data, sp_matrix::Matrix{Int64})
    start_time = time()

    solution, σ_data = runConstructive(data, sp_matrix)
    solution, σ_data = localSearch(data, σ_data, sp_matrix, solution)
    current = deepcopy(solution)
    σ_current = deepcopy(σ_data)
    best = deepcopy(solution)
    σ_best = deepcopy(σ_data)
    println("Cost = ", best.cost)
    start = (params.initial * solution.cost) / -log(params.initial)
    stop = (params.final * solution.cost) / -log(params.final)
    factor = (stop / start) ^ (1 / params.iter)

    temp = start
    while (temp < stop)

        current, σ_current = perturb(data, σ_current, sp_matrix, current, params.perturb)
        current, σ_current = localSearch(data, σ_current, sp_matrix, current)

        profit_cost = solution.cost - current.cost
        profit_veh = length(solution.routes) - length(current.routes)

        println("ILS[$temp] $(current.cost) - $(solution.cost) - $(best.cost)")

        prob = exp(- profit_cost / temp) #Its negative
        dice = rand()

        if profit_cost > 0 || profit_veh > 0 || dice < prob
            solution = deepcopy(current)
            σ_data = deepcopy(σ_current)
            if solution.cost < best.cost || length(solution.routes) < length(best.routes)
                best = deepcopy(solution)
                σ_best = deepcopy(σ_data)
            end
        else
            current = deepcopy(solution)
            current = deepcopy(σ_data)
        end

        temp *= factor
    end
    println("Cost = ", best.cost)

    total_time = time() - start_time
    println("Time = ", total_time)

    out_file = data.name * "-out.csv";
    open(out_file, "a") do file
        write(file, "
            $(data.name),
            $(params.seed),
            $(params.initial),
            $(params.final),
            $(params.iter),
            $(params.perturb),
            $total_time,
            $(solution.cost),
            $(data.lb),
            $(data.ub)\n
        ")
        close(file)
    end

    return best
end
