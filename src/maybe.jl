#
# Maybe
#

"""
    Maybe{T}

Option type, either a [`Just{T}`](@ref) or [`None{T}`](@ref)
"""
abstract type Maybe{T} end

"""
    None{T} <: Maybe{T}
    None(T=Any)

Indicate the lack of a meaningful value (ie nothing when `::T` is expected)
"""
struct None{T} <: Maybe{T} end

None(T::Type=Any) = None{T}()
None(::T) where T = None(T)
None(s::Some) = None(typeof(something(s)))

"""
    Just{T} <: Maybe{T}
    Just(v::T)
    Just(s::Some{T})

Indicate a meaningful value.
"""
struct Just{T} <: Maybe{T}
    v::T
end

Just(s::Some) = Just(something(s))

Base.eltype(::Maybe{T}) where {T} = T

value(j::Just) = j.v
value(::Nothing) = nothing

isnone(::None) = true
isnone(_) = false

isjust(::Just) = true
isjust(_) = false

Base.join(n::None) = n
Base.join(j::Just{<:Just}) = join(value(j))
Base.join(j::Just{<:None}) = value(j)
Base.join(j::Just) = j

"""
    map(f, m::Either, S=eltype(m))

Return `Just(f(value(e)))` if `m::Just`, else return `None(S)`
"""
Base.map(f, m::Maybe) = map(f, m, eltype(m))
Base.map(_, ::None, T::Type) = None(T)
Base.map(f, j::Just, _) = Just(f(value(j)))

Base.promote_rule(::Type{Maybe{T1}}, ::Type{Maybe{T2}}) where {T1,T2} =
        Maybe{promote_type(T1, T2)}

Base.convert(::Type{None{T}}, ::None) where {T} = None(T)
Base.convert(::Type{Just{T}}, j::Just) where {T} = Just{T}(value(j))

Base.convert(::Type{Maybe{T}}, v) where {T} = Just{T}(v)
Base.convert(::Type{Maybe{T}}, ::Nothing) where {T} = None{T}()

Base.show(io::IO, j::Just) = print(io, "Just($(value(j)))")
Base.show(io::IO, n::None) = print(io, "None(::$(eltype(n)))")
