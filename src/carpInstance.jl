mutable struct σ
    from        ::Int64
    to          ::Int64
    Modes       ::Matrix{Float64}
    lower_bound ::Float64
end

mutable struct Perturb_params
    num_iter        ::Int64
    initial_accept  ::Float64
    final_accept    ::Float64
end

function Base.show(io::IO, sigma::σ)

    print(io, "σ($(sigma.from), $(sigma.to))")
end