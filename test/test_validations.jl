@testset "ValidateParents" begin

    test_id = "test_dataset"
    dataset = Dataset(ID=test_id)

    registry = InitializeRegistry(ID="test_registry")
    registry.Datasets[test_id] = dataset

    # check that it passes if the Parent exists #
    parents = [test_id]
    @test isnothing(ValidateParents(registry, parents))

    # Check the error for parents not existing #
    parents = ["does_not_exist"]
    @test_throws ErrorException ValidateParents(registry, parents) 

end