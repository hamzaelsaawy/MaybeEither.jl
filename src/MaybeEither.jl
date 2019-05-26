#
# module file
#

module MaybeEither

export
    Maybe, Just, None, isjust, isnone, eltype,
    Either, Left, Right, left, right, isleft, isright, lefttype, righttype, value

include("maybe.jl")
include("either.jl")

end # module

