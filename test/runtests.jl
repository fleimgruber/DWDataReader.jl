using Test, DWDataReader

const dir = joinpath(dirname(pathof(DWDataReader)), "..", "test", "testfiles")

@testset "DWDataReader" begin

    DWInit()
    @test DWDataReader.DWGetVersion() == 4020020
    DWDeInit()

    @testset "DWDataReader.File" begin

        include("basics.jl")
        include("testfiles.jl")

    end # @testset "DWDataReader.File"

end
