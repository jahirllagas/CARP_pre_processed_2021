using CARPData

include("Parameters.jl")
include("IteratedLocalSearch.jl")
include("FloydWarshall.jl")

function main()
    ARGS = ["kshs1", "42", "0.005", "0.1", "50", "4", "kshs1-out.txt"]

    params = Parameters(ARGS)
    data = load(Symbol(params.instance))
    sp_matrix = solveFloydWarshall(data)

    solution = runILS(params, data, sp_matrix)
end

main()
