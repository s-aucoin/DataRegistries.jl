@testset "to_toml" begin
    # Test with one object of each possible type #
    possible_types = [AbstractDict,
                        AbstractVector,
                        AbstractString,
                        Integer,
                        AbstractFloat,
                        Bool,
                        Dates.DateTime,
                        Dates.Time,
                        Dates.Date, 
                        AuthorInfo, 
                        ProjectInfo, 
                        Dataset, 
                        DataRegistry]

    @test DataRegistries.to_toml("test") == "test"
    @test DataRegistries.to_toml(123) == 123
    @test DataRegistries.to_toml(123.456) == 123.456
    @test DataRegistries.to_toml(true) == true
    @test DataRegistries.to_toml(false) == false

    testdatetime = now()
    testtoday = today()
    testtime = Time(now())
    @test DataRegistries.to_toml(testdatetime) == testdatetime
    @test DataRegistries.to_toml(testtoday) == testtoday
    @test DataRegistries.to_toml(testtime) == testtime

    test_array = ["test", 1, 2.3]
    @test DataRegistries.to_toml(test_array) == test_array

    @testset "Dict" begin
        @test DataRegistries.to_toml(Dict{String, Float64}("key" => 1.0)) == Dict{String, Float64}("key" => 1.0)
        @test DataRegistries.to_toml(Dict{String, typeof(test_array)}("key" => test_array)) == Dict{String, typeof(test_array)}("key" => test_array)
    end

    author = AuthorInfo(Name="Test Author", Email="test@example.com", Affiliation="Test Institution", Github="test", ORCID="0000-0000")
    @test DataRegistries.to_toml(author) == Dict{String, String}("Name"=>"Test Author", "Email"=>"test@example.com", "Affiliation"=>"Test Institution", "Github"=>"test", "ORCID"=>"0000-0000")

    # ProjectInfo #
    project_info = ProjectInfo(ID="test_project", Title="Test Project", Authors=Dict("Author" => author), Initialized=testdatetime, Description="Test project description")
    expected_type_project_info = Union{String, Dict{String, Dict{String, String}}, Dates.DateTime}
    @test DataRegistries.to_toml(project_info) == Dict{String, expected_type_project_info}("ID"=>"test_project", "Title"=>"Test Project", "Authors"=>Dict("Author" => Dict{String, String}("Name"=>"Test Author", "Email"=>"test@example.com", "Affiliation"=>"Test Institution", "Github"=>"test", "ORCID"=>"0000-0000")), "Initialized"=>testdatetime, "Description"=>"Test project description")
    
    # Dataset #
    custom_metadata = Dict{String, Union{DataRegistries.TOMLTypes, AuthorInfo, ProjectInfo}}("test_key"=>"test_value", "test_key2"=>AuthorInfo(Name="Test Author"), "test_key3"=>project_info, "test_key4"=>123)
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

    expected_type = Union{String, Dict{String, Dict{String, String}}, Dates.DateTime, Vector{String}, Dict{String, Any}}
    @test propertytype(DataRegistries.to_toml(dataset)) == expected_type
    #@test DataRegistries.to_toml(dataset) == Dict{String, expected_type}("ID"=>"test_project", "Title"=>"Test Project", "Authors"=>Dict("Author" => Dict("Name"=>"Test Author", "Email"=>"test@example.com", "Affiliation"=>"Test Institution", "Github"=>"test", "ORCID"=>"0000-0000")), "Initialized"=>testdatetime, "Description"=>"Test project description")

    # DataRegistry #
end

#=
@testset "from_toml" begin
    

end
=#