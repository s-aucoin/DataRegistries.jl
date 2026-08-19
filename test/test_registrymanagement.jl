@testset "InitializeRegistry" begin
    # test default initialization #
    registry = InitializeRegistry(ID="example_ID")
    @test registry.Info.ID == "example_ID"
    @test registry.Info.Title == "Example Project"
    @test registry.Info.Authors == Dict{String, AuthorInfo}("Author" => AuthorInfo(Name="Author"))
    @test registry.Info.Description == ""
    @test registry.Datasets == Dict{String, Dataset}()

    # test custom initialization #
    registry = InitializeRegistry(ID="example_ID", 
                                  Title="Example Project 2", 
                                  Authors=DataRegistries.authorlist, 
                                  Description="example description")
    @test registry.Info.ID == "example_ID"
    @test registry.Info.Title == "Example Project 2"
    @test registry.Info.Authors == DataRegistries.authorlist
    @test registry.Info.Description == "example description"
    @test registry.Datasets == Dict{String, Dataset}()
end

@testset "AddDataset" begin
    
    registry = InitializeRegistry(ID="test_registry")

    # Test that the dataset is added to registry #
    test_id = "test_dataset"
    dataset = Dataset(ID=test_id)
    AddDataset!(registry, dataset)
    @test haskey(registry.Datasets, test_id)
    @test registry.Datasets[test_id] == dataset

    @test Dates.value(registry.Datasets[test_id].Registered) ≈ Dates.value(Dates.now()) atol=5000  # Check that the registered time is now

    # Test the error for non-unique IDs #
    @test_throws ErrorException AddDataset!(registry, dataset)

    # Check adding a dataset with parents #
    dataset2 = Dataset(ID="test_dataset2", Parents=[test_id])
    AddDataset!(registry, dataset2)
    @test haskey(registry.Datasets, "test_dataset2")

    # Check the error for parents not existing #
    dataset3 = Dataset(ID="test_dataset3", Parents=["non-existant"])
    @test_throws ErrorException AddDataset!(registry, dataset)
end

@testset "UpdateDataset" begin
    
    test_id = "test_dataset"
    dataset = Dataset(ID=test_id)
    registry = InitializeRegistry(ID="test_registry")
    registry.Datasets[test_id] = dataset

    registry_copy = deepcopy(registry)

    first_modified = registry.Datasets[test_id].LastModified

    # Test that the dataset is updated in the registry #
    # update every field #
    custom_metadata = Dict{AbstractString, Any}("test_key"=>"test_value", "test_key4"=>123)
    update_kwargs = (Title="Updated Dataset", 
                        DataPath="update.jl", 
                        SourcePath="updatesrc.jl",
                        Description="updated description", 
                        Authors=DataRegistries.authorlist,
                        ProcessingLevel="L0",
                        Metadata=custom_metadata)

    UpdateDataset!(registry, test_id; update_kwargs...)
    @test registry.Datasets[test_id].Title == update_kwargs.Title
    @test registry.Datasets[test_id].DataPath == update_kwargs.DataPath
    @test registry.Datasets[test_id].SourcePath == update_kwargs.SourcePath
    @test registry.Datasets[test_id].Description == update_kwargs.Description
    @test registry.Datasets[test_id].Authors == update_kwargs.Authors
    @test registry.Datasets[test_id].ProcessingLevel == update_kwargs.ProcessingLevel
    @test registry.Datasets[test_id].Metadata == update_kwargs.Metadata
    
    @test registry.Datasets[test_id].LastModified != first_modified # check that LastModified was changed


    # test not changing anything #
    registry_copy = deepcopy(registry)
    UpdateDataset!(registry, test_id) # equivalent to touch!()

    # test that only the LastModified Field was updated #
    @test registry.Datasets[test_id].Title == registry_copy.Datasets[test_id].Title
    @test registry.Datasets[test_id].DataPath == registry_copy.Datasets[test_id].DataPath
    @test registry.Datasets[test_id].SourcePath == registry_copy.Datasets[test_id].SourcePath
    @test registry.Datasets[test_id].Description == registry_copy.Datasets[test_id].Description
    @test registry.Datasets[test_id].Authors == registry_copy.Datasets[test_id].Authors
    @test registry.Datasets[test_id].ProcessingLevel == registry_copy.Datasets[test_id].ProcessingLevel
    @test registry.Datasets[test_id].Metadata == registry_copy.Datasets[test_id].Metadata
    
    @test registry.Datasets[test_id].LastModified != registry_copy.Datasets[test_id].LastModified # check that LastModified was changed


    # test the error is the the dataset doesn't exist #
    @test_throws ErrorException UpdateDataset!(registry, "does_not_exist"; Title="Doesn't Exist") 

    # test the error for non-existant keys #
    @test_throws ErrorException UpdateDataset!(registry, test_id; DNE="does_not_exist") 

    # test that trying to change the ID fails #
    @test_throws ErrorException UpdateDataset!(registry, test_id; ID = "new_id") 

    # test that trying to change the Registered time fails #
    @test_throws ErrorException UpdateDataset!(registry, test_id; Registered = now()) 

    # Check the error for parents not existing if changed #
    @test_throws ErrorException UpdateDataset!(registry, test_id; Parents=["does_not_exist"])
end


@testset "UpdateOrAddDataset" begin

    registry = InitializeRegistry(ID="test_registry")

    # test if the ID doesn't exists, it adds it #
    test_id = "test_dataset"
    UpdateOrAddDataset!(registry, test_id)

    @test haskey(registry.Datasets, test_id)

    # test that if the ID exists, it updates #
    UpdateOrAddDataset!(registry, test_id; Title="Updated Dataset")
    @test registry.Datasets[test_id].Title == "Updated Dataset"

end


@testset "RemoveDataset" begin

    registry = InitializeRegistry(ID="test_registry")

    # Add a dataset with no parents
    test_id = "test_dataset"
    AddDataset!(registry, Dataset(ID=test_id))

    # Add a child dataset with the first dataset as a parent
    child_id = "child_dataset"
    AddDataset!(registry, Dataset(ID=child_id, Parents=[test_id]))

    # test that trying to remove a dataset with children fails if allow_orphans is false
    @test_throws ErrorException RemoveDataset!(registry, test_id; allow_orphans=false)

    # test allowing orphans gives a warning and removes the dataset #
    @test_warn "Dataset '$test_id' is a parent of datasets: $child_id. Deleting it will orphan these datasets and may cause problems." RemoveDataset!(registry, test_id; confirm=false, allow_orphans=true)
    @test !haskey(registry.Datasets, test_id) # check that the dataset was removed

    # Test that RemoveDataset! removes the dataset without children from the registry
    RemoveDataset!(registry, child_id)
    @test !haskey(registry.Datasets, child_id)

    # Test that RemoveDataset! throws an error for a non-existent dataset ID
    @test_throws ErrorException RemoveDataset!(registry, "non_existent_dataset")
end