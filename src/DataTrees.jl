module DataTrees

export AuthorInfo, ProjectInfo, Dataset, DatasetRegistry,
       InitializeRegistry, SaveRegistry, LoadRegistry,
       AddDataset!, UpdateDataset!, UpdateOrCreateDataset!


using Parameters
using TOML
using Dates

include("Structures.jl")
include("RegistryManagement.jl")
include("Conversions.jl")
include("IO.jl")

end
