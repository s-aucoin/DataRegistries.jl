## Functions to convert the defined types to TOML-compatible formats ##
"""
    to_toml(x::Union{RegistryTypes, AbstractDict})

Convert RegistryTypes.
"""
function to_toml(x::Union{RegistryTypes, AbstractDict})
    return Dict{TOMLTypes, TOMLTypes}(to_toml(k) => to_toml(x[k]) for k in keys(x))
end

function to_toml(x::Symbol)
    return String(x)
end

function to_toml(x::AbstractVector)
    return to_toml.(x)
end

function to_toml(x::Union{AbstractString, Integer, AbstractFloat, Bool, Dates.DateTime, Dates.Time, Dates.Date}) # TOMLTypes except for Dict and Vector
    return x
end




"""
    ConvertFromTOML(T, x)

Convert TOML-compatible data back into a Julia object of type `T`.
"""
function ConvertFromTOML(::Type{T}, x) where T

    if T <: DateTime
        return DateTime(x)

    elseif T <: Symbol
        return Symbol(x)

    elseif T <: String || T <: Number || T <: Bool
        return convert(T, x)

    elseif T <: Dict
        K = keytype(T)
        V = valtype(T)

        return Dict(convert(K, k) => ConvertFromTOML(V, v) for (k, v) in x)

    elseif T <: AbstractVector
        V = eltype(T)

        return [ConvertFromTOML(V, v) for v in x]

    elseif isstructtype(T)
        values = (ConvertFromTOML(fieldtype(T, i), x[string(fieldname(T, i))]) for i in 1:fieldcount(T))

        return T(values...)

    else
        return convert(T, x)
    end
end