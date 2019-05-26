using MaybeEither
using Test

@testset "MaybeEither" begin
    @testset "Either" begin
        @test left(3) isa Left{Int, Any}
        @test left(3) isa Either{Int, Any}

        @test right("Sdfds", Vector) isa Either{Vector,String}

        @test right(right(0.3, String)) == Right{String,Float64}(0.3)
        @test left(left(0.3, Char)) == Left{Float64,Char}(0.3)

        @test value(left(16.0im)) == 16.0im
        @test value(right(16.0im)) == 16.0im

        @test isleft(left(0.3)) == true
        @test isleft(right(0.3)) == false

        @test isright(left(0.3)) == false
        @test isright(right(1)) == true
        @test isright(Vector) == false

        l = Left{Float32, String}(left(1, Array))
        @test l == Left{String}(1.0f0)
        @test lefttype(l) == Float32
        @test righttype(l) == String

        r = Right{Int, Float32}(right(1, String))
        @test r == Right{Int}(1.0f0)
        @test lefttype(r) == Int
        @test righttype(r) == Float32

        @test Left{ComplexF64}(Left{AbstractFloat,String}(0.9)) isa
                Left{AbstractFloat, ComplexF64}
        @test Right{String}(Right{Int,Number}(0)) isa Right{String,Number}

        @testset "joins" begin
            @test join(left(right(0.4, 'a'))) == right(0.4, Char)

            @test join(left(right(right(4, left(left(3)))), 'a')) ==
                    Right{Left{Left{Int64,Any},Any},Int}(4)

        end
    end

    @testset "Maybe" begin
        j = Just{Integer}(5)
        @test eltype(j) == Integer
        @test j != Just(5)

        m = Just(Just(Just(None("no"))))
        @test join(m) == None(String)
        @test eltype(m) == String
        @test value(m) == nothing

        j = Just("Hello")
        @test map(length, j, Vector) == map(length, j) == Just(5)
        n = None(String)
        @test map(length, n) == n
        @test map(length, n, Int) == n

        @test join(map(_ -> nothing, Just(4))) == None(Int)
    end
end
