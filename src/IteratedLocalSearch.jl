include("Constructive.jl")

function runILS(params::Parameters, data::Data, sp_matrix::Matrix{Int64})
    start_time = time()

    solution = runConstructive(data)
    # solution = localSearch(solution)

    current = deepcopy(solution)
    best = deepcopy(solution)

    start = (params.initial * solution.cost) / -log(params.initial)
    stop = (params.final * solution.cost) / -log(params.final)
    factor = (stop / start) ^ (1 / params.iter)

    temp = start
    while (temp > stop)

        # current = preturb(current)
        # current = localSearch(current)

        profit_cost = solution.cost - current.cost
        profit_veh = length(solution.routes) - length(current.routes)

        println("ILS[$temp] $(current.cost) - $(solution.cost) - $(best.cost)")

        prob = exp(-profit_cost / temp) #TODO: Check if we need the minus sign.
        dice = rand()

        if profit_cost > 0 || profit_veh > 0 || dice < prob
            solution = deepcopy(current)

            if solution.cost < best.cost || length(solution.routes) < length(best.routes)
                best = deepcopy(solution)
            end
        else
            current = deepcopy(solution)
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
