## These are the basic structures that the DataRegistries package is built on. ##
export AuthorInfo, ProjectInfo, Dataset, DataRegistry, propertytype


### Acceptable types for converting to TOML ###
const TOMLTypes = Union{
    AbstractDict,
    AbstractVector,
    AbstractString,
    Integer,
    AbstractFloat,
    Bool,
    Dates.DateTime,
    Dates.Time,
    Dates.Date
}


### AUTHOR INFORMATION ###
@with_kw struct AuthorInfo @deftype AbstractString
    Name
    Email = ""
    Affiliation = ""
    Github = ""
    ORCID = ""
end

authorlist = Dict{String, AuthorInfo}(
"Sam Aucoin" => AuthorInfo(Name="Sam Aucoin",
                           Email="sam.aucoin@dal.ca",
                           Affiliation="Department of Oceanography, Dalhousie University",
                           Github="https://github.com/s-aucoin",
                           ORCID="https://orcid.org/0009-0009-6772-3418")
)


@with_kw struct ProjectInfo @deftype AbstractString
    ID                                   # Unique identifier for the project
    Title = "Example Project"            # Title of the project
    Authors::Dict{String,AuthorInfo} = Dict("Author" => AuthorInfo(Name="Author")) # The contributing authors to the project
    Initialized::DateTime = now()        # When the project was initialized (in UTC)
    Description = ""                     # A description of the project
end

@with_kw mutable struct Dataset @deftype AbstractString
    ID                                              # Unique identifier for the dataset
    Title = "Example Dataset"                       # Title of the dataset
    DataPath = "data/example.nc"                    # Relative path to the data file
    SourcePath = ""                                 # Relative path to the script that generated the dataset
    Description = ""                                # A description of the dataset

    Authors::Dict{String, AuthorInfo} = Dict("Author" => AuthorInfo(Name="Author")) # The contributing authors to this dataset

    ProcessingLevel = "raw"                         # Processing level of the dataset (e.g. raw, L0, L1, L2)

    Parents::Vector{String} = String[]              # List of parent dataset IDs (if any)

    Registered::DateTime = now()                    # The date and time when the dataset was added to the registry (in UTC)
    LastModified::DateTime = now()                  # The last date and time the dataset was modified (in UTC)

    Metadata::Dict{AbstractString, Any} = Dict{String, TOMLTypes}() # Any other arbitrary metadata associated with the dataset except RegistryTypes (maybe in the future)
end


@with_kw mutable struct DataRegistry
    Info::ProjectInfo                                       # The overall metadata for the project
    Datasets::Dict{String, Dataset} = Dict{String, Dataset}() # A map of dataset IDs to Dataset objects
end


## A collection of the defined types #
const RegistryTypes = Union{AuthorInfo, ProjectInfo, Dataset, DataRegistry}



## Macro to define equality for the defined types ##
macro auto_equals(type_name)
    return esc(quote
        function Base.:(==)(a::$type_name, b::$type_name)
            return all(f -> getfield(a, f) == getfield(b, f), fieldnames($type_name))
        end

        function Base.hash(a::$type_name, h::UInt)
            for f in fieldnames($type_name)
                h = hash(getfield(a, f), h)
            end
            return h
        end
    end)
end

## Macro to define iterate for the defined types ##
macro make_iterable(type_name)
    return esc(quote
        # Define starting iteration
        Base.iterate(x::$type_name) = Base.iterate(x, 1)
        
        # Define subsequent iteration steps
        function Base.iterate(x::$type_name, state::Int)
            if state > fieldcount($type_name)
                return nothing
            else
                return (getfield(x, state), state + 1)
            end
        end
    end)
end


## Extend Base functions to work with the defined types ##

# AuthorInfo #
Base.getindex(x::AuthorInfo, s::Symbol) = getfield(x, s)
Base.keys(p::AuthorInfo) = propertynames(p)
@auto_equals AuthorInfo
Base.length(x::AuthorInfo) = 1
@make_iterable AuthorInfo
Base.values(x::AuthorInfo) = getfield.(Ref(x), fieldnames(AuthorInfo))
Base.keytype(::Type{AuthorInfo}) = Symbol
Base.keytype(x::AuthorInfo) = Symbol
Base.valtype(::Type{AuthorInfo}) = Union{fieldtypes(AuthorInfo)...}

# define a new function to get the actual concrete type of a property #
propertytype(x::AuthorInfo, field::Symbol) = typeof(getfield(x, field))
propertytype(x::AuthorInfo) = Union{(propertytype(x, field) for field in fieldnames(AuthorInfo))...}


# ProjectInfo #
Base.getindex(x::ProjectInfo, s::Symbol) = getfield(x, s)
Base.keys(p::ProjectInfo) = propertynames(p)
@auto_equals ProjectInfo
Base.length(x::ProjectInfo) = 1
@make_iterable ProjectInfo
Base.values(x::ProjectInfo) = getfield.(Ref(x), fieldnames(ProjectInfo))
Base.keytype(::Type{ProjectInfo}) = Symbol
Base.keytype(x::ProjectInfo) = Symbol
Base.valtype(::Type{ProjectInfo}) = Union{fieldtypes(ProjectInfo)...}

# define a new function to get the actual concrete type of a property #
propertytype(x::ProjectInfo, field::Symbol) = typeof(getfield(x, field))
propertytype(x::ProjectInfo) = Union{(propertytype(x, field) for field in fieldnames(ProjectInfo))...}


# Dataset #
Base.getindex(x::Dataset, s::Symbol) = getfield(x, s)
Base.keys(p::Dataset) = propertynames(p)
@auto_equals Dataset
Base.length(x::Dataset) = 1
@make_iterable Dataset
Base.values(x::Dataset) = getfield.(Ref(x), fieldnames(Dataset))
Base.keytype(::Type{Dataset}) = Symbol
Base.keytype(x::Dataset) = Symbol
Base.valtype(::Type{Dataset}) = Union{fieldtypes(Dataset)...}

# define a new function to get the actual concrete type of a property #
propertytype(x::Dataset, field::Symbol) = typeof(getfield(x, field))
propertytype(x::Dataset) = Union{(propertytype(x, field) for field in fieldnames(Dataset))...}


# DataRegistry #
Base.getindex(x::DataRegistry, s::Symbol) = getfield(x, s)
Base.keys(p::DataRegistry) = propertynames(p)
@auto_equals DataRegistry
Base.length(x::DataRegistry) = length(x.Datasets)
@make_iterable DataRegistry
Base.values(x::DataRegistry) = getfield.(Ref(x), fieldnames(DataRegistry))
Base.keytype(::Type{DataRegistry}) = Symbol
Base.keytype(x::DataRegistry) = Symbol
Base.valtype(::Type{DataRegistry}) = Union{fieldtypes(DataRegistry)...}

# define a new function to get the actual concrete type of a property #
propertytype(x::DataRegistry, field::Symbol) = typeof(getfield(x, field))
propertytype(x::DataRegistry) = Union{(propertytype(x, field) for field in fieldnames(DataRegistry))...}


# define a new function to get the actual concrete type of a property for an AbstractDict too #
propertytype(x::AbstractDict, field::Any) = typeof(get(x, field, nothing))
propertytype(x::AbstractDict) = Union{(propertytype(x, field) for field in keys(x))...}