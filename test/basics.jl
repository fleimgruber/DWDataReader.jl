@testset "DWDataReader.File basics" begin
    @test_throws ArgumentError DWDataReader.File("")
end
