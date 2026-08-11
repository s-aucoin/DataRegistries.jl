module DataTrees

export AuthorInfo, ProjectMetadata, Dataset, DatasetRegistry,
       InitializeRegistry, SaveRegistry, LoadRegistry,
       AddDataset!, UpdateDataset!, UpdateOrCreateDataset!


using Parameters
using TOML
using Dates
#using DrWatson


include("Structures.jl")
include("RegistryManagement.jl")
include("Conversions.jl")
include("IO.jl")

end
