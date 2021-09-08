mutable struct σ
    from        ::Int64
    to          ::Int64
    modes       ::Matrix{Float64}
    lower_bound ::Float64
end

function Base.show(io::IO, sigma::σ)
    print(io, "σ($(sigma.from), $(sigma.to))")
end