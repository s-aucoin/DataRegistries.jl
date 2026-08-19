@testset "FindChildren" begin

    registry = InitializeRegistry(ID="test_registry")

    # Add a dataset with no parents
    test_id = "test_dataset"
    AddDataset!(registry, Dataset(ID=test_id))

    # Add a child dataset with the first dataset as a parent
    child_id = "child_dataset"
    AddDataset!(registry, Dataset(ID=child_id, Parents=[test_id]))

    # Test that FindChildren returns the correct child dataset
    children = FindChildren(registry, test_id)
    @test children == [child_id]

    # Test that FindChildren returns an empty array for a dataset with no children
    no_children = FindChildren(registry, child_id)
    @test isempty(no_children)

    # Test that FindChildren throws an error for a non-existent dataset ID
    @test_throws ErrorException FindChildren(registry, "non_existent_dataset")
end