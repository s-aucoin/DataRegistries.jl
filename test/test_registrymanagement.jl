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