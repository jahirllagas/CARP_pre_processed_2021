struct Parameters
    instance::String
    seed::Int64
    initial::Float64
    final::Float64
    iter::Int64
    perturb::Int64

    function Parameters(args::Vector{String})
        instance = args[1]
        seed = parse(Int64, args[2])
        initial = parse(Float64, args[3])
        final = parse(Float64, args[4])
        iter = parse(Int64, args[5])
        perturb = parse(Int64, args[6])

        return new(instance, seed, initial, final, iter, perturb)
    end
end
