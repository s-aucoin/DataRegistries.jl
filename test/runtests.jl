using DataTrees
using Test

@testset "AuthorInfo" begin
    # test default values #
    author = AuthorInfo(name="Example Author")
    @test author.name == "Example Author"
    @test author.email == ""
    @test author.affiliation == ""
    @test author.github == ""
    @test author.ORCID == ""

    # test custom values #
    author2 = AuthorInfo(name="Example Author", email="ex.auth@example.com", affiliation="Example Affiliation", github="https://github.com/example", ORCID="https://orcid.org/0000-0000-0000-0000")
    @test author2.name == "Example Author"
    @test author2.email == "ex.auth@example.com"
    @test author2.affiliation == "Example Affiliation"
    @test author2.github == "https://github.com/example"
    @test author2.ORCID == "https://orcid.org/0000-0000-0000-0000"

    # test type contraints #
    @test_throws MethodError AuthorInfo(name=123)
    @test_throws MethodError AuthorInfo(name="Example Author", email=123)
    @test_throws MethodError AuthorInfo(name="Example Author", email="ex.auth@example.com", affiliation=123)
    @test_throws MethodError AuthorInfo(name="Example Author", email="ex.auth@example.com", affiliation="Example Affiliation", github=123)
    @test_throws MethodError AuthorInfo(name="Example Author", email="ex.auth@example.com", affiliation="Example Affiliation", github="https://github.com/example", ORCID=123)
end
