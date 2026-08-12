
@testset "AuthorInfo" begin
    # test default values #
    author = AuthorInfo(Name="Example Author")
    @test author.Name == "Example Author"
    @test author.Email == ""
    @test author.Affiliation == ""
    @test author.Github == ""
    @test author.ORCID == ""

    # test custom values #
    author = AuthorInfo(Name="Example Author", Email="ex.auth@example.com", Affiliation="Example Affiliation", Github="https://Github.com/example", ORCID="https://orcid.org/0000-0000-0000-0000")
    @test author.Name == "Example Author"
    @test author.Email == "ex.auth@example.com"
    @test author.Affiliation == "Example Affiliation"
    @test author.Github == "https://Github.com/example"
    @test author.ORCID == "https://orcid.org/0000-0000-0000-0000"

    # test type contraints #
    @test_throws MethodError AuthorInfo(Name=123)
    @test_throws MethodError AuthorInfo(Name="Example Author", Email=123)
    @test_throws MethodError AuthorInfo(Name="Example Author", Affiliation=123)
    @test_throws MethodError AuthorInfo(Name="Example Author", Github=123)
    @test_throws MethodError AuthorInfo(Name="Example Author", ORCID=123)
end


@testset "ProjectInfo" begin
    # test default values #
    project_info = ProjectInfo(ID="example_project")
    @test project_info.ID == "example_project"
    @test project_info.Title == "Example Project"
    @test project_info.Authors == Dict{AbstractString, AuthorInfo}("Author" => AuthorInfo(Name="Author"))
    @test Dates.value(project_info.Initialized) ≈ Dates.value(Dates.now()) atol=5000  # Allow for slight timing differences
    @test project_info.Description == ""

    # test custom values #
    project_info = ProjectInfo(ID="example_project", Title="Custom Project", Authors=DataRegistries.authorlist, Initialized=Dates.Date(today()), Description="This is a custom project.")
    @test project_info.ID == "example_project"
    @test project_info.Title == "Custom Project"
    @test project_info.Authors == DataRegistries.authorlist
    @test project_info.Initialized == Dates.Date(today())
    @test project_info.Description == "This is a custom project."

    # test type contraints #
    @test_throws MethodError ProjectInfo(ID=123)
    @test_throws MethodError ProjectInfo(ID="Example Author", Title=123)
    @test_throws MethodError ProjectInfo(ID="Example Author", Authors=123)
    @test_throws MethodError ProjectInfo(ID="Example Author", Initialized=123)
    @test_throws MethodError ProjectInfo(ID="Example Author", Description=123)
end


@testset "Dataset" begin
    # test default values #
    dataset = Dataset(ID="example_dataset")
    @test dataset.ID == "example_dataset"
    @test dataset.Title == "Example Dataset"
    @test dataset.DataPath == "data/example.nc"
    @test dataset.SourcePath == ""
    @test dataset.Description == ""
    @test dataset.Authors == Dict{AbstractString, AuthorInfo}("Author" => AuthorInfo(Name="Author"))
    @test dataset.ProcessingLevel == "raw"
    @test dataset.Parents == AbstractString[]
    @test Dates.value(dataset.Registered) ≈ Dates.value(Dates.now()) atol=5000  # Allow for slight timing differences
    @test Dates.value(dataset.LastModified) ≈ Dates.value(Dates.now()) atol=5000  # Allow for slight timing differences
    @test dataset.Metadata == Dict{AbstractString, Union{DataRegistries.TOMLTypes, AuthorInfo, ProjectInfo}}()

    # test custom values #
    custom_metadata = Dict{AbstractString, Union{DataRegistries.TOMLTypes, AuthorInfo, ProjectInfo}}("test_key"=>"test_value", "test_key2"=>AuthorInfo(Name="Test Author"), "test_key3"=>ProjectInfo(ID="test_project"), "test_key4"=>123)
    dataset = Dataset(ID="example_dataset", 
                        Title="Custom Dataset", 
                        DataPath="example.jl", 
                        SourcePath="example.jl",
                        Description="example description", 
                        Authors=DataRegistries.authorlist,
                        ProcessingLevel="L0",
                        Parents=["example_ID"],
                        Registered=Dates.Date(today()),
                        LastModified=Dates.Date(today()),
                        Metadata=custom_metadata)

    @test dataset.ID == "example_dataset"
    @test dataset.Title == "Custom Dataset"
    @test dataset.DataPath == "example.jl"
    @test dataset.SourcePath == "example.jl"
    @test dataset.Description == "example description"
    @test dataset.Authors == DataRegistries.authorlist
    @test dataset.ProcessingLevel == "L0"
    @test dataset.Parents == ["example_ID"]
    @test dataset.Registered == Dates.Date(today())  # Allow for slight timing differences
    @test dataset.LastModified == Dates.Date(today())  # Allow for slight timing differences
    @test dataset.Metadata == custom_metadata

    # test type contraints #
    @test_throws MethodError Dataset(ID=123)
    @test_throws MethodError Dataset(ID="Example Dataset", Title=123)
    @test_throws MethodError Dataset(ID="Example Dataset", DataPath=123)
    @test_throws MethodError Dataset(ID="Example Dataset", SourcePath=123)
    @test_throws MethodError Dataset(ID="Example Dataset", Description=123)
    @test_throws MethodError Dataset(ID="Example Dataset", Authors=123)
    @test_throws MethodError Dataset(ID="Example Dataset", ProcessingLevel=123)
    @test_throws MethodError Dataset(ID="Example Dataset", Parents=123)
    @test_throws MethodError Dataset(ID="Example Dataset", Registered=123)
    @test_throws MethodError Dataset(ID="Example Dataset", LastModified=123)
    @test_throws MethodError Dataset(ID="Example Dataset", Metadata=123)
end


@testset "DataRegistry" begin
    # test default values #
    project_info = ProjectInfo(ID="example_project")
    data_registry = DataRegistry(Info=project_info)
    @test data_registry.Info == project_info
    @test data_registry.Datasets == Dict{AbstractString, Dataset}()

    # test custom values #
    dataset = Dataset(ID="example_dataset")
    datasets = Dict{AbstractString, Dataset}("example_dataset" => dataset)
    data_registry = DataRegistry(Info=project_info, Datasets=datasets)
    @test data_registry.Info == project_info
    @test data_registry.Datasets == datasets

    # test type contraints #
    @test_throws MethodError DataRegistry(Info=123)
    @test_throws MethodError DataRegistry(Info=project_info, Datasets=123)
end