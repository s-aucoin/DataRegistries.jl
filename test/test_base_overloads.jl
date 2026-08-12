@testset "AuthorInfo" begin
    author = AuthorInfo(Name="Example Author", Email="example@test.com", Affiliation="Test Institution", Github="test", ORCID="0000-0000")

    # test getindex #
    @test getindex(author, :Name) == "Example Author"
    @test getindex(author, :Email) == "example@test.com"
    @test getindex(author, :Affiliation) == "Test Institution"
    @test getindex(author, :Github) == "test"
    @test getindex(author, :ORCID) == "0000-0000"

    # test keys #
    @test keys(author) == (:Name, :Email, :Affiliation, :Github, :ORCID)

    # test equality #
    author2 = AuthorInfo(Name="Example Author", Email="example@test.com", Affiliation="Test Institution", Github="test", ORCID="0000-0000")
    @test author == author2

    # test length #
    @test length(author) == 1

    # test iteration #
    iterated_fields = []
    for field in author
        push!(iterated_fields, field)
    end
    @test iterated_fields == ["Example Author", "example@test.com", "Test Institution", "test", "0000-0000"]

    # test values #
    @test values(author) == ("Example Author", "example@test.com", "Test Institution", "test", "0000-0000")
end


@testset "ProjectInfo" begin
    time = now()
    project_info = ProjectInfo(ID="Example Project", Title="Example Project", Authors=DataRegistries.authorlist, Initialized=time, Description="Example project description")

    # test getindex #
    @test getindex(project_info, :ID) == "Example Project"
    @test getindex(project_info, :Title) == "Example Project"
    @test getindex(project_info, :Authors) == DataRegistries.authorlist
    @test getindex(project_info, :Initialized) == time
    @test getindex(project_info, :Description) == "Example project description"

    # test keys #
    @test keys(project_info) == (:ID, :Title, :Authors, :Initialized, :Description)

    # test equality #
    project_info2 = ProjectInfo(ID="Example Project", Title="Example Project", Authors=DataRegistries.authorlist, Initialized=time, Description="Example project description")
    @test project_info == project_info2

    # test length #
    @test length(project_info) == 1

    # test iteration #
    iterated_fields = []
    for field in project_info
        push!(iterated_fields, field)
    end
    @test iterated_fields == ["Example Project", "Example Project", DataRegistries.authorlist, time, "Example project description"]

    # test values #
    @test values(project_info) == ("Example Project", "Example Project", DataRegistries.authorlist, time, "Example project description")
end


@testset "Dataset" begin
    time = now()
    custom_metadata = Dict{AbstractString, Union{DataRegistries.TOMLTypes, AuthorInfo, ProjectInfo}}("test_key"=>"test_value", "test_key2"=>AuthorInfo(Name="Test Author"), "test_key3"=>ProjectInfo(ID="test_project"), "test_key4"=>123)
    dataset = Dataset(ID="example_dataset", 
                        Title="Custom Dataset", 
                        DataPath="example.jl", 
                        SourcePath="example.jl",
                        Description="example description", 
                        Authors=DataRegistries.authorlist,
                        ProcessingLevel="L0",
                        Parents=["example_ID"],
                        Registered=time,
                        LastModified=time,
                        Metadata=custom_metadata)

    # test getindex #
    @test getindex(dataset, :ID) == "example_dataset"
    @test getindex(dataset, :Title) == "Custom Dataset"
    @test getindex(dataset, :DataPath) == "example.jl"
    @test getindex(dataset, :SourcePath) == "example.jl"
    @test getindex(dataset, :Description) == "example description"
    @test getindex(dataset, :Authors) == DataRegistries.authorlist
    @test getindex(dataset, :ProcessingLevel) == "L0"
    @test getindex(dataset, :Parents) == ["example_ID"]
    @test getindex(dataset, :Registered) == time
    @test getindex(dataset, :LastModified) == time
    @test getindex(dataset, :Metadata) == custom_metadata

    # test keys #
    @test keys(dataset) == (:ID, :Title, :DataPath, :SourcePath, :Description, :Authors, :ProcessingLevel, :Parents, :Registered, :LastModified, :Metadata)

    # test equality #
    dataset2 = Dataset(ID="example_dataset", 
                    Title="Custom Dataset", 
                    DataPath="example.jl", 
                    SourcePath="example.jl",
                    Description="example description", 
                    Authors=DataRegistries.authorlist,
                    ProcessingLevel="L0",
                    Parents=["example_ID"],
                    Registered=time,
                    LastModified=time,
                    Metadata=custom_metadata)
    @test dataset == dataset2

    # test length #
    @test length(dataset) == 1

    # test iteration #
    iterated_fields = []
    for field in dataset
        push!(iterated_fields, field)
    end
    @test iterated_fields == ["example_dataset", "Custom Dataset", "example.jl", "example.jl", "example description", DataRegistries.authorlist, "L0", ["example_ID"], time, time, custom_metadata]

    # test values #
    @test values(dataset) == ("example_dataset", "Custom Dataset", "example.jl", "example.jl", "example description", DataRegistries.authorlist, "L0", ["example_ID"], time, time, custom_metadata)
end


@testset "DataRegistry" begin
    time = now()

    project_info = ProjectInfo(ID="Example Project", Title="Example Project", Authors=DataRegistries.authorlist, Initialized=time, Description="Example project description")
    
    custom_metadata = Dict{AbstractString, Union{DataRegistries.TOMLTypes, AuthorInfo, ProjectInfo}}("test_key"=>"test_value", "test_key2"=>AuthorInfo(Name="Test Author"), "test_key3"=>ProjectInfo(ID="test_project"), "test_key4"=>123)
    dataset = Dataset(ID="example_dataset", 
                        Title="Custom Dataset", 
                        DataPath="example.jl", 
                        SourcePath="example.jl",
                        Description="example description", 
                        Authors=DataRegistries.authorlist,
                        ProcessingLevel="L0",
                        Parents=["example_ID"],
                        Registered=time,
                        LastModified=time,
                        Metadata=custom_metadata)
    datasets = Dict{AbstractString, Dataset}("example_dataset" => dataset, "example_dataset2" => dataset)

    data_registry = DataRegistry(Info=project_info, Datasets=datasets)

    # test getindex #
    @test getindex(data_registry, :Info) == project_info
    @test getindex(data_registry, :Datasets) == datasets

    # test keys #
    @test keys(data_registry) == (:Info, :Datasets)

    # test equality #
    data_registry2 = DataRegistry(Info=project_info, Datasets=datasets)
    @test data_registry == data_registry2

    # test length #
    @testset "DataRegistry length" begin
        for n in 1:10
            datasets = Dict{AbstractString, Dataset}("example_dataset_$i" => dataset for i in 1:n)
            data_registry = DataRegistry(Info=project_info, Datasets=datasets)
            @test length(data_registry) == n
        end
    end

    # test iteration #
    iterated_fields = []
    for field in data_registry
        push!(iterated_fields, field)
    end
    @test iterated_fields == [project_info, datasets]

    # test values #
    @test values(data_registry) == (project_info, datasets)
end