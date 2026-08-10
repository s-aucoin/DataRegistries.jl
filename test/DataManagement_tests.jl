using DataManagement
using ResearchTemplates
using Dates


# Create a registry #
registry = InitializeRegistry(Title = "Test Registry", ID="testregistry", Authors = ResearchTemplates.authorlist, Description="Test description")  

# Save it to a file #
registry_path = joinpath(@__DIR__, "test_registry.toml")
SaveRegistry(registry, path=registry_path)

# Load it back #
registry = LoadRegistry(registry_path)


# Create a dataset #
dataset = Dataset("testdataset", "Test Dataset", "data/test_data.csv", "scripts/generate_test_data.jl", "This is a test dataset.", ResearchTemplates.authorlist, "L1", "CSV", [], now(), now(), Dict())

# Add the dataset to the registry and save it #
AddDataset!(registry, dataset)
SaveRegistry(registry, path=registry_path)

# Load the registry back and update the dataset #
registry = LoadRegistry(registry_path)
UpdateDataset!(registry, "testdataset"; Description="Updated test dataset.", FileType="netcdf")
SaveRegistry(registry, path=registry_path)


## test UpdateOrCreateDataset! ##
# try to update an existing dataset #
registry = LoadRegistry(registry_path)
UpdateOrCreateDataset!(registry, "testdataset"; Description="Updated again test dataset.")
SaveRegistry(registry, path=registry_path)

# try to create a new dataset #
registry = LoadRegistry(registry_path)
UpdateOrCreateDataset!(registry, "defaultdataset")
SaveRegistry(registry, path=registry_path)