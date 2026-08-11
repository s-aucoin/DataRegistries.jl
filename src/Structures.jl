## These are the basic structures that the DataTrees package is built on. ##

### AUTHOR INFORMATION ###
@with_kw struct AuthorInfo @deftype String
    name
    email = ""
    affiliation = ""
    github = ""
    ORCID = ""
end

authorlist = Dict{String, AuthorInfo}(
"Sam Aucoin" => AuthorInfo(name="Sam Aucoin",
                           email="sam.aucoin@dal.ca",
                           affiliation="Department of Oceanography, Dalhousie University",
                           github="https://github.com/s-aucoin",
                           ORCID="https://orcid.org/0009-0009-6772-3418")
)


@with_kw struct ProjectMetadata @deftype String
    ID                                   # Unique identifier for the project
    Title = "Example Project"            # Title of the project
    Authors::Dict{String, AuthorInfo} = Dict{String, AuthorInfo}("Author" => AuthorInfo(name="Author")) # The contributing authors to the project
    Initialized::DateTime = now()        # When the project was initialized (in UTC)
    Description = ""                     # A description of the project
end


@with_kw mutable struct Dataset @deftype String
    ID                                              # Unique identifier for the dataset
    Title = "Example Dataset"                       # Title of the dataset
    DataPath = "data/example.nc"                    # Relative path to the data file
    SourcePath = ""                                 # Relative path to the script that generated the dataset
    Description = ""                                # A description of the dataset

    Authors::Dict{String, AuthorInfo} = Dict{String, AuthorInfo}("Author" => AuthorInfo(name="Author")) # The contributing authors to this dataset

    ProcessingLevel = "raw"                         # Processing level of the dataset (e.g. raw, L0, L1, L2)

    Parents::Vector{String} = String[]              # List of parent dataset IDs (if any)

    Registered::DateTime = now()                    # The date and time when the dataset was added to the registry (in UTC)
    LastModified::DateTime = now()                  # The last date and time the dataset was modified (in UTC)

    Metadata::Dict{String,Any} = Dict{String,Any}() # Any other arbitrary metadata associated with the dataset
end


@with_kw mutable struct DatasetRegistry
    Info::ProjectMetadata                                   # The overall metadata for the project
    Datasets::Dict{String,Dataset} = Dict{String,Dataset}() # A map of dataset IDs to Dataset objects
end