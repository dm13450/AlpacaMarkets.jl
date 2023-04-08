@testset "Trading API Functions Tests" begin

    @testset "account() return size and data structure type" begin
        res = account()

        @test size(res,2) == 35
        @test isa(res, DataFrame)
    end

end