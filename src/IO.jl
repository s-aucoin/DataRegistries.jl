"""
    SaveRegistry(registry, filename)

Save a DatasetRegistry object to a TOML file.
"""
function SaveRegistry(registry::DatasetRegistry; path::String=DrWatson.projectdir("Data.toml"))

    # Convert registry object to TOML-compatible Dict
    registry_dict = ConvertToTOML(registry)

    # Write to file
    open(path, "w") do io
        TOML.print(io, registry_dict)
    end

    println("Registry saved to $path")
end


"""
    LoadRegistry(filename)

Load a DatasetRegistry from a TOML file.
"""
function LoadRegistry(filename::String)

    toml = TOML.parsefile(filename)

    return ConvertFromTOML(DatasetRegistry, toml)

end