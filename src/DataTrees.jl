module DataTrees

export ProjectMetadata, Dataset, DatasetRegistry,
       InitializeRegistry, SaveRegistry, LoadRegistry,
       AddDataset!, UpdateDataset!, UpdateOrCreateDataset!


using TOML
using Dates
using DrWatson


## Define the structures that the functions are based on ##
struct ProjectMetadata
    Title::String                        # Title of the project
    Authors::Dict{String, ResearchTemplates.AuthorInfo} # The contributing authors to the project (defined in ResearchTemplates.jl)
    Initialized::DateTime                # When the project was initialized (in UTC)
    Description::String                  # A description of the project
    ID::String                           # Unique identifier for the project
end

mutable struct Dataset
    ID::String                           # Unique identifier for the dataset
    Title::String                        # Title of the dataset
    DataPath::String                     # Relative path to the data file
    SourcePath::String                   # Relative path to the script that generated the dataset
    Description::String                  # A description of the dataset

    Authors::Dict{String, ResearchTemplates.AuthorInfo} # A dictionary of the contributing authors to this dataset (defined in ResearchTemplates.jl)

    ProcessingLevel::String              # Processing level of the dataset (e.g., L0, L1, L2)
    FileType::String                     # File type of the dataset (e.g., netCDF, CSV, HDF5)

    Parents::Vector{String}              # List of parent dataset IDs (if any)

    Registered::DateTime                 # The date and time when the dataset was added to the registry (in UTC)
    LastModified::DateTime               # The last date and time the dataset was modified (in UTC)

    Metadata::Dict{String,Any} # Any other arbitrary metadata associated with the dataset
end


mutable struct DatasetRegistry
    Info::ProjectMetadata                # The overall metadata for the project
    Datasets::Dict{String,Dataset}       # A dictionary mapping dataset IDs to Dataset objects
end


### AUTHOR INFORMATION ###
struct AuthorInfo
    name::String
    email::String
    affiliation::String
    github::String
    ORCID::String
end

authorlist = Dict{String, AuthorInfo}(
"Sam Aucoin" => AuthorInfo("Sam Aucoin", "sam.aucoin@dal.ca", "Department of Oceanography, Dalhousie University", "https://github.com/s-aucoin", "https://orcid.org/0009-0009-6772-3418")
)

#######################################################################################################
## Base Functions ##

"""
    InitializeRegistry(; Title::String = DrWatson.projectname(),
                         ID::String,
                         Authors::Dict{String, ResearchTemplates.AuthorInfo} = ResearchTemplates.authorlist,
                         Description::String = "")

Create an empty DatasetRegistry object.
"""
function InitializeRegistry(; Title::String = DrWatson.projectname(),
                                ID::String,
                                Authors::Dict{String, ResearchTemplates.AuthorInfo} = ResearchTemplates.authorlist,
                                Description::String = "")

    info = ProjectMetadata(
        Title,
        Authors,
        now(),
        Description,
        ID)

    return DatasetRegistry(
        info,
        Dict{String, Dataset}())
end


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


"""
    Dataset(ID; kwargs...)

Create a default Dataset with the given ID and optional keyword arguments.
"""
function Dataset(ID::String;
                    Title="Default Title",
                    DataPath="data/default_data.csv",
                    SourcePath="scripts/generate_default_data.jl",
                    Description="Default description.",
                    Authors=ResearchTemplates.authorlist,
                    ProcessingLevel="L1",
                    FileType="CSV",
                    Parents=String[],
                    Registered=now(),
                    LastModified=now(),
                    Metadata=Dict{String,Any}())

    Dataset(ID,
            Title,
            DataPath,
            SourcePath,
            Description,
            Authors,
            ProcessingLevel,
            FileType,
            Parents,
            Registered,
            LastModified,
            Metadata)
end


#######################################################################################################
## Core Management Functions ##

"""
    AddDataset!(registry, dataset)

Add a Dataset to a DatasetRegistry.

Checks:
- Dataset ID does not already exist
- All parent dataset IDs exist in the registry

Updates:
- Adds dataset to `registry.Datasets`
- Sets the registration timestamp
"""
function AddDataset!(registry::DatasetRegistry, dataset::Dataset)

    # Check that ID is unique
    if haskey(registry.Datasets, dataset.ID)
        error("Dataset with ID '$(dataset.ID)' already exists in registry.")
    end

    # Check that parent datasets exist
    missing_parents = [p for p in dataset.Parents if !haskey(registry.Datasets, p)]

    if !isempty(missing_parents)
        error("Cannot add dataset '$(dataset.ID)'. " *
            "The following parent datasets do not exist: " *
            "$(join(missing_parents, ", "))")
    end

    # Add dataset
    dataset.Registered = now()
    registry.Datasets[dataset.ID] = dataset

    println("Dataset '$(dataset.ID)' added to registry.")
end


"""
    UpdateDataset!(registry, ID; kwargs...)

Update fields of an existing Dataset in a DatasetRegistry.

Only fields provided as keyword arguments are modified.
The dataset's LastModified timestamp is updated automatically.

Example:
    UpdateDataset!(
        registry,
        "temperature_L1";
        Parents=["temperature_raw"],
        Description="Updated description"
    )
"""
function UpdateDataset!(registry::DatasetRegistry, ID::String; kwargs...)

    # Check that dataset exists
    if !haskey(registry.Datasets, ID)
        error("Dataset with ID '$ID' does not exist in registry.")
    end

    dataset = registry.Datasets[ID]

    # Check that all fields exist
    valid_fields = Set(fieldnames(Dataset))

    for key in keys(kwargs)
        if !(key in valid_fields)
            error("Dataset has no field '$key'. " * "Valid fields are: $(join(valid_fields, ", "))")
        end
    end

    # Update fields
    for (key, value) in kwargs

        # Do not allow changing the ID
        if key == :ID
            error("Dataset ID cannot be modified. Use RemoveDataset! and AddDataset! instead.")
        end

        # Do not allow changing the registration time
        if key == :Registered
            error("Dataset registration time cannot be modified. Use RemoveDataset! and AddDataset! instead.")
        end

        setfield!(dataset, key, value)
    end


    # Validate parents if changed
    if :Parents in keys(kwargs)

        missing_parents = [p for p in dataset.Parents if !haskey(registry.Datasets, p)]

        if !isempty(missing_parents)
            error("Cannot update dataset '$ID'. " * "The following parent datasets do not exist: " * "$(join(missing_parents, ", "))")
        end
    end


    # Update modification timestamp
    dataset.LastModified = now()

println("Dataset '$(dataset.ID)' updated in the registry.")
end



"""
    UpdateOrCreateDataset!(registry, ID; kwargs...)

Update an existing Dataset in a DatasetRegistry, or create a new Dataset if
it does not exist.

If the dataset already exists, only the supplied fields are modified.
If it does not exist, a new Dataset is created using the supplied fields
and default values for unspecified fields.
"""
function UpdateOrCreateDataset!(registry::DatasetRegistry, ID::String; kwargs...)

    if haskey(registry.Datasets, ID)
        println("Dataset '$(ID)' already exists, updating...")
        UpdateDataset!(registry, ID; kwargs...)
    else
        println("Dataset '$(ID)' does not exist, creating it instead.")
        dataset = Dataset(ID; kwargs...)
        AddDataset!(registry, dataset)
    end
end


#######################################################################################################
## Helpful convenient functions ##
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


end
