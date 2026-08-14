@testset "IO" begin
    filename = "test_registry.toml"

    # Create a sample DataRegistry object for testing #
    project_info = ProjectInfo(ID="example_project")
    dataset = Dataset(ID="example_dataset")
    data_registry = DataRegistry(Info=project_info, Datasets=Dict("example_dataset" => dataset))

    # test saving the object to a TOML file #
    SaveRegistry(data_registry; path=filename)
    @test isfile(filename)

    # test that the saved TOML file was properly formatted #
    import TOML
    toml = TOML.parsefile(filename)
    @test toml == DataRegistries.to_toml(data_registry)

    # test loading the object from a TOML file #
    loaded_registry = LoadRegistry(filename)
    @test loaded_registry == data_registry # test that the loaded object is the same as the original object

    if isfile(filename)
        rm(filename)
    end
end