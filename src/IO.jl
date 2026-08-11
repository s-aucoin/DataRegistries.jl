"""
    SaveRegistry(registry, filename)

Save a DatasetRegistry object to a TOML file.
"""
function SaveRegistry(registry::DatasetRegistry; path::AbstractString="DataRegistry.toml")

    open(path, "w") do io
        TOML.print(io, to_toml(registry))
    end

    println("Registry saved to $path")
    return nothing
end


"""
    LoadRegistry(filename)

Load a DatasetRegistry from a TOML file.
"""
function LoadRegistry(filename::AbstractString)

    toml = TOML.parsefile(filename)

    return ConvertFromTOML(DatasetRegistry, toml)
end