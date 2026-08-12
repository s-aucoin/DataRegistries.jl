## Functions to convert the defined types to TOML-compatible formats ##
"""
    to_toml(x::Union{RegistryTypes, AbstractDict})

Convert `RegistryTypes` and `AbstractDict` to a `Dict` of TOML-compatible formats.
"""
function to_toml(x::Union{RegistryTypes, AbstractDict})
    return Dict{TOMLTypes, TOMLTypes}(to_toml(k) => to_toml(x[k]) for k in keys(x))
end

"""
    to_toml(x::Symbol)

Convert `Symbol` to TOML-compatible `String`.
"""
function to_toml(x::Symbol)
    return String(x)
end

"""
    to_toml(x::AbstractVector)

Convert each element of an `AbstractVector` to TOML-compatible formats.
"""
function to_toml(x::AbstractVector)
    return to_toml.(x)
end

"""
    to_toml(x::Union{AbstractString, Integer, AbstractFloat, Bool, Dates.DateTime, Dates.Time, Dates.Date})

Allow every TOML-compatible format except `AbstractDict` and `AbstractVector` to pass unchanged.
"""
function to_toml(x::Union{AbstractString, Integer, AbstractFloat, Bool, Dates.DateTime, Dates.Time, Dates.Date}) # TOMLTypes except for Dict and Vector
    return x
end




"""
    from_toml(::Type{T}, x::AbstractDict) where T <: RegistryTypes

Convert TOML-formatted `RegistryTypes` from an `AbstractDict` to the appropriate type.
"""
function from_toml(::Type{T}, x::AbstractDict) where T <: RegistryTypes
    T((from_toml(fieldtype(T, i), x[string(fieldnames(T)[i])]) for i in 1:fieldcount(T))...)
end

"""
    from_toml(::Type{Symbol}, x::AbstractString)

Convert `String` to `Symbol`.
"""
function from_toml(::Type{Symbol}, x::AbstractString)
    return Symbol(x)
end

"""
    from_toml(::Type{Vector{T}}, x::AbstractVector) where T

Convert each element of a TOML-formatted `AbstractVector` to the appropriate type.
"""
function from_toml(::Type{Vector{T}}, x::AbstractVector) where T
    from_toml.(Ref(T), x)
end

"""
    from_toml(::Type{Dict{K,V}}, x::AbstractDict) where {K,V}

Convert each key-value pair of a TOML-formated `AbstractDict` to the appropriate types.
"""
function from_toml(::Type{Dict{K,V}}, x::AbstractDict) where {K,V}
    Dict(from_toml(K, k) => from_toml(V, v) for (k, v) in x)
end

"""
    from_toml(::Type{T}, x::T) where T <: Union{AbstractString, Integer, AbstractFloat, Bool, Dates.DateTime, Dates.Time, Dates.Date}

Allow every TOML-compatible format except `AbstractDict` and `AbstractVector` to pass unchanged.
"""
function from_toml(::Type{T}, x::T) where T <: Union{AbstractString, Integer, AbstractFloat, Bool, Dates.DateTime, Dates.Time, Dates.Date}
    return x
end