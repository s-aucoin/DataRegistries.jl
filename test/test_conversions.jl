@testset "to_toml" begin
    # Test with one object of each possible type #
    # Check that TOML-compatible types are left unchanged
    @test DataRegistries.to_toml("test") == "test"
    @test DataRegistries.to_toml(123) == 123
    @test DataRegistries.to_toml(123.456) == 123.456
    @test DataRegistries.to_toml(true) == true

    testdatetime = now()
    testtoday = today()
    testtime = Time(now())
    @test DataRegistries.to_toml(testdatetime) == testdatetime
    @test DataRegistries.to_toml(testtoday) == testtoday
    @test DataRegistries.to_toml(testtime) == testtime

    test_array = ["test", 1, 2.3]
    @test DataRegistries.to_toml(test_array) == test_array

    # Test that Dicts with Symbol keys are converted to String keys #
    @testset "Dict" begin
        @test DataRegistries.to_toml(Dict{String, Float64}("key" => 1.0)) == Dict{String, Float64}("key" => 1.0)
        @test DataRegistries.to_toml(Dict{String, typeof(test_array)}("key" => test_array)) == Dict{String, typeof(test_array)}("key" => test_array)
    end

    # AuthorInfo #
    author = AuthorInfo(Name="Test Author", Email="test@example.com", Affiliation="Test Institution", Github="test", ORCID="0000-0000")
    toml_author = DataRegistries.to_toml(author)

    @test toml_author == Dict{String, String}("Name"=>"Test Author", "Email"=>"test@example.com", "Affiliation"=>"Test Institution", "Github"=>"test", "ORCID"=>"0000-0000")

    # ProjectInfo #
    project_info = ProjectInfo(ID="test_project", Title="Test Project", Authors=Dict("Author" => author), Initialized=testdatetime, Description="Test project description")
    expected_type_project_info = Union{String, Dict{String, Dict{String, String}}, Dates.DateTime}
    toml_project_info = DataRegistries.to_toml(project_info)

    @test toml_project_info == Dict{String, expected_type_project_info}("ID"=>"test_project", "Title"=>"Test Project", "Authors"=>Dict("Author" => Dict{String, String}("Name"=>"Test Author", "Email"=>"test@example.com", "Affiliation"=>"Test Institution", "Github"=>"test", "ORCID"=>"0000-0000")), "Initialized"=>testdatetime, "Description"=>"Test project description")
    
    # Dataset #
    custom_metadata = Dict{String, DataRegistries.TOMLTypes}("test_key"=>"test_value", "test_key4"=>123)
    dataset = Dataset(ID="example_dataset", 
                        Title="Custom Dataset", 
                        DataPath="example.jl", 
                        SourcePath="example.jl",
                        Description="example description", 
                        Authors=DataRegistries.authorlist,
                        ProcessingLevel="L0",
                        Parents=["example_ID"],
                        Registered=testdatetime,
                        LastModified=testdatetime,
                        Metadata=custom_metadata)

    expected_type_dataset = Union{String, Dict{String, Dict{String, String}}, Dates.DateTime, Vector{String}, Dict{String, Any}}
    toml_dataset = DataRegistries.to_toml(dataset)

    @test propertytype(toml_dataset) == expected_type_dataset
    @test toml_dataset == Dict("ID"=>"example_dataset", 
                                "Title"=>"Custom Dataset",
                                "DataPath"=>"example.jl", 
                                "SourcePath"=>"example.jl",
                                "Description"=>"example description", 
                                "Authors"=> DataRegistries.to_toml(DataRegistries.authorlist),
                                "ProcessingLevel"=>"L0",
                                "Parents"=>["example_ID"],
                                "Registered"=>testdatetime,
                                "LastModified"=>testdatetime,
                                "Metadata"=>DataRegistries.to_toml(custom_metadata))


    # DataRegistry #
    data_registry = DataRegistry(Info=project_info, Datasets=Dict("example_dataset" => dataset))
    expected_type_data_registry = Union{Dict{String, Dict{String, Any}}, Dict{String, Any}}
    toml_data_registry = DataRegistries.to_toml(data_registry)

    @test propertytype(toml_data_registry) == expected_type_data_registry
    @test toml_data_registry == Dict("Info"=>DataRegistries.to_toml(project_info), "Datasets"=>Dict("example_dataset" => DataRegistries.to_toml(dataset)))



    ## Test from_toml with the same objects ##
    @testset "from_toml" begin
        # Test with one object of each possible type #
        @test DataRegistries.from_toml(String, "test") == "test"
        @test DataRegistries.from_toml(Int64, 123) == 123
        @test DataRegistries.from_toml(Float64, 123.456) == 123.456
        @test DataRegistries.from_toml(Bool, true) == true

        @test DataRegistries.from_toml(Dates.DateTime, testdatetime) == testdatetime
        @test DataRegistries.from_toml(Dates.Date, testtoday) == testtoday
        @test DataRegistries.from_toml(Dates.Time, testtime) == testtime

        @test DataRegistries.from_toml(Vector{Union{String, Int64, Float64}}, test_array) == test_array

        # Test that Dicts with String keys are converted to Symbol keys #
        @testset "Dict" begin
            @test DataRegistries.from_toml(Dict{Symbol, Float64}, Dict("key" => 1.0)) == Dict(:key => 1.0)
            @test DataRegistries.from_toml(Dict{Symbol, Vector{Union{String, Int64, Float64}}}, Dict("key" => test_array)) == Dict(:key => test_array)
        end


        # AuthorInfo #
        back_to_author = DataRegistries.from_toml(AuthorInfo, toml_author)

        @test typeof(back_to_author) == AuthorInfo
        @test propertytype(back_to_author) == String
        @test back_to_author == author


        # ProjectInfo #
        back_to_project_info = DataRegistries.from_toml(ProjectInfo, toml_project_info)

        @test typeof(back_to_project_info) == ProjectInfo
        @test propertytype(back_to_project_info) == Union{String, Dict{String, AuthorInfo}, DateTime}
        @test back_to_project_info == project_info


        # Dataset #
        back_to_dataset = DataRegistries.from_toml(Dataset, toml_dataset)

        @test typeof(back_to_dataset) == Dataset
        @test propertytype(back_to_dataset) == Union{String, Dict{String, AuthorInfo}, DateTime, Vector{String}, Dict{AbstractString, Any}}
        @test back_to_dataset == dataset


        # DataRegistry #
        back_to_data_registry = DataRegistries.from_toml(DataRegistry, toml_data_registry)

        @test typeof(back_to_data_registry) == DataRegistry
        @test propertytype(back_to_data_registry) == Union{ProjectInfo, Dict{String, Dataset}}
        @test back_to_data_registry == data_registry
    end

end