"""
    ConvertToTOML(x)

Convert a Julia object into a format suitable for TOML serialization. This function recursively converts structs, dictionaries, and arrays into dictionaries and arrays of basic types (strings, numbers, etc.) that can be serialized to TOML.
"""
function ConvertToTOML(x)

    if x isa DateTime
        return string(x)

    elseif x isa String || x isa Number || x isa Bool
        return x

    elseif x === nothing
        return "NULL"

    elseif x isa Dict
        return Dict(string(k) => ConvertToTOML(v) for (k,v) in x)

    elseif x isa AbstractVector
        return [ConvertToTOML(v) for v in x]

    elseif isstructtype(typeof(x))
        return Dict(string(field) => ConvertToTOML(getfield(x, field)) for field in fieldnames(typeof(x)))

    else
        return x
    end
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