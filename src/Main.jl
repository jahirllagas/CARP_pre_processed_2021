using CARPData

include("Parameters.jl")
include("IteratedLocalSearch.jl")
include("FloydWarshall.jl")

function main()
    ARGS = ["gdb23", "42", "0.005", "0.1", "50", "4", "kshs1-out.txt"]

    params = Parameters(ARGS)
    data = load(Symbol(params.instance))
    println(data)
    sp_matrix = solveFloydWarshall(data)

    solution = runILS(params, data, sp_matrix)
end

main()
