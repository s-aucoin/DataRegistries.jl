## These are the basic structures that the DataRegistries package is built on. ##

### AUTHOR INFORMATION ###
@with_kw struct AuthorInfo @deftype AbstractString
    name
    email = ""
    affiliation = ""
    github = ""
    ORCID = ""
end

authorlist = Dict{AbstractString, AuthorInfo}(
"Sam Aucoin" => AuthorInfo(name="Sam Aucoin",
                           email="sam.aucoin@dal.ca",
                           affiliation="Department of Oceanography, Dalhousie University",
                           github="https://github.com/s-aucoin",
                           ORCID="https://orcid.org/0009-0009-6772-3418")
)


@with_kw struct ProjectInfo @deftype AbstractString
    ID                                   # Unique identifier for the project
    Title = "Example Project"            # Title of the project
    Authors::Dict{AbstractString, AuthorInfo} = Dict{AbstractString, AuthorInfo}("Author" => AuthorInfo(name="Author")) # The contributing authors to the project
    Initialized::DateTime = now()        # When the project was initialized (in UTC)
    Description = ""                     # A description of the project
end


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

@with_kw mutable struct Dataset @deftype AbstractString
    ID                                              # Unique identifier for the dataset
    Title = "Example Dataset"                       # Title of the dataset
    DataPath = "data/example.nc"                    # Relative path to the data file
    SourcePath = ""                                 # Relative path to the script that generated the dataset
    Description = ""                                # A description of the dataset

    Authors::Dict{AbstractString, AuthorInfo} = Dict{AbstractString, AuthorInfo}("Author" => AuthorInfo(name="Author")) # The contributing authors to this dataset

    ProcessingLevel = "raw"                         # Processing level of the dataset (e.g. raw, L0, L1, L2)

    Parents::Vector{AbstractString} = AbstractString[]              # List of parent dataset IDs (if any)

    Registered::DateTime = now()                    # The date and time when the dataset was added to the registry (in UTC)
    LastModified::DateTime = now()                  # The last date and time the dataset was modified (in UTC)

    Metadata::Dict{AbstractString, Union{TOMLTypes, AuthorInfo, ProjectInfo}} = Dict{AbstractString, Union{TOMLTypes, AuthorInfo, ProjectInfo}}() # Any other arbitrary metadata associated with the dataset
end


@with_kw mutable struct DataRegistry
    Info::ProjectInfo                                       # The overall metadata for the project
    Datasets::Dict{AbstractString,Dataset} = Dict{AbstractString,Dataset}() # A map of dataset IDs to Dataset objects
end


## A collection of the defined types #
RegistryTypes = Union{AuthorInfo, ProjectInfo, DataRegistry}


## Extend Base.getindex and Base.keys to work with the defined types ##
Base.getindex(x::AuthorInfo, s::Symbol) = getfield(x, s)
Base.keys(p::AuthorInfo) = propertynames(p)

Base.getindex(x::ProjectInfo, s::Symbol) = getfield(x, s)
Base.keys(p::ProjectInfo) = propertynames(p)

Base.getindex(x::Dataset, s::Symbol) = getfield(x, s)
Base.keys(p::Dataset) = propertynames(p)

Base.getindex(x::DataRegistry, s::Symbol) = getfield(x, s)
Base.keys(p::DataRegistry) = propertynames(p)
