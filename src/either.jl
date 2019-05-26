#
# Either
#

"""
    Either{L,R}

A binary tagged union of `L` and `R`; either  [`Left`](@ref) or [`Right`](@ref).
"""
abstract type Either{L,R} end

for (E, c, V, O) in [(:Left, :left, :L, :R), (:Right, :right, :R, :L)]
    ise = Symbol(:is, c)

    # string and expr interpolations don't mix well
    dE = """
        $E{L,R} <: Either{L,R}

    $E case of `Either{L,R}`, constructed with [`$c`](@ref).
    """

    dc = """
        $c(v::$V, [$O])

    Return a `$E{L,R}(v) <: Either{L,R}`, with `$O = Any` as the default.
    """

    dis = """
        $ise(e)

    Return whether `e` is of type `$E`.
    """

    @eval begin
        @doc $dE
        struct $E{L,R} <: Either{L,R}
            v::$V
        end
        $E{$O}(v::$V) where {L,R} = $E{L,R}(v)

        Base.promote_rule(::Type{$E{L1,R1}}, ::Type{$E{L2,R2}}) where {L1,L2,R1,R2} =
                $E{promote_type(L1, L2), promote_type(R1, R2)}
        Base.convert(::Type{$E{L,R}}, e::$E) where {L,R} = $E{L,R}(value(e))

        @doc $dc
        $c(v, $O::Type=Any) = $E{$O}(v)
        $c(v, ::$O) where {$O} = $E{$O}(v)

        @doc $dis
        $ise(::$E) = true
        $ise(_) = false
    end
end

lefttype(::Either{L}) where {L} = L
righttype(::Either{L,R}) where {L,R} = R

Base.eltype(l::Left) = lefttype(l)
Base.eltype(r::Right) = righttype(r)

value(e::Either) = e.v

Base.join(e::Either) = _join(e, value(e))
_join(e, v::Either) = _join(v, value(v))
_join(e, v) = e

"""
    map(f, e::Either, [R2])

Return `right(f(value(e)))` if `e::Right`, else return `e`

`R2` is `f`s expected return type, to ensure the map returns `e::Left{L, R2}`.
"""
Base.map(f, e::Either) = Base.map(f, e, righttype(e))
Base.map(_, l::Left, R::Type) = left(l, R)
Base.map(f, r::Right, _::Type) = right(f(value(r)), lefttype(r))

Base.show(io::IO, l::Left) =
        print(io, "Left($(value(l)), ::$(righttype(l)))")
Base.show(io::IO, r::Right) =
        print(io, "Right(::$(lefttype(r)), $(value(r)))")
