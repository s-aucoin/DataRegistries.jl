"""
    SaveRegistry(registry, filename)

Save a DataRegistry object to a TOML file.
"""
function SaveRegistry(registry::DataRegistry; path::AbstractString="DataRegistry.toml")

    open(path, "w") do io
        TOML.print(io, to_toml(registry))
    end

    println("Registry saved to $path")
    return nothing
end


"""
    LoadRegistry(filename)

Load a DataRegistry from a TOML file.
"""
function LoadRegistry(filename::AbstractString)

    toml = TOML.parsefile(filename)

    return from_toml(DataRegistry, toml)
end