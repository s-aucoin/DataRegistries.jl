module DataRegistries

export AuthorInfo, ProjectInfo, Dataset, DataRegistry,
       propertytype,
       ValidateParents,
       InitializeRegistry, SaveRegistry, LoadRegistry,
       AddDataset!, UpdateDataset!, UpdateOrAddDataset!


using Parameters
using TOML
using Dates

include("Structures.jl")
include("Validations.jl")
include("RegistryManagement.jl")
include("Conversions.jl")
include("IO.jl")

end
