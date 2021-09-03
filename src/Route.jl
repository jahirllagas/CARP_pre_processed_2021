mutable struct Route
    id      ::Int64
    edges   ::Vector{Int64}
    demand  ::Int64
    cost    ::Int64
end

function Base.show(io::IO, route::Route)
    print(io, "r$(route.id)")
end
