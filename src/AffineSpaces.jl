module AffineSpaces

using FixedSizeArrays

export AffineSpace, FixedAffineSpace, AffinePoint

"""
    abstract AffineSpace{T}

An `AffineSpace` object represents points in an affine space, which is similar
to a Cartesian space but where no special meaning can be assigned to the origin.
Subtypes of `AffineSpace` should have a field named `pos` with vector-like
abilities describing the coordinates.

The consequences are that points do not have vector-like abilities such as
multiplication by a scalar (scaling the distance relative to the origin), unary
inversion (reflection about the origin) or addition of the coordinates of two
points (coorinates being relative to the origin).

Outside these restriction, one can take affine combinations of points, finding
for instance the midpoint of two points. Affine combinations are built with
the colon operation `p₁:p₂` and indexed with a scalar `(p₁:p₂)[i]`, where
`i = 0.0` indicates the point `p₁`, and `i = 1.0` indicates the point `p₂`, and
other values of `i` trace out the line connecting the two points. Generally,
the affine combination of `n` points can be generated with `(p₁:...:pₙ)[i₁,...,iₙ]`
so long as the `iⱼ`s sum to `1` (or the last `iₙ` is not given, and is
automatically calculated).

Furthermore, standard vectors can be added and subtracted from affine points as
a displacement of the point. The displacement vector between two points is given
by their subtraction.

The goal of these types are to provide some programmer safety to avoid
conceptual mistakes regarding manipulation of points, by removing the meaning
of the possibly-arbitrary origin.
"""
abstract AffineSpace{T}
abstract FixedAffineSpace{N,T} <: AffineSpace

"""
    AffinePoint{N,T} <: FixedAffineSpace{T}

A concrete type describing a point in an affine space, where the Cartesian
coordinates of the point are stored in a `FixedSizeArrays.Vec{N,T}`. See
`AffineSpace` for a description of the interface for affine points.
"""
immutable AffinePoint{N,T} <: FixedAffineSpace{T}
    pos::Vec{N,T}
end

Base.length(point::AffineSpace) = length(point.pos)
Base.size(point::AffineSpace) = size(point.pos)
Base.size(point::AffineSpace, d) = size(point.pos, d)
Base.endof(point::AffineSpace) = endof(point.pos)
Base.getindex(point::AffineSpace, i) = point.pos[i]
Base.setindex!(point::AffineSpace, v, i) = setindex!(point.pos, v, i)
Base.start(point::AffineSpace) = start(point.pos)
Base.next(point::AffineSpace, i) = next(point.pos, i)
Base.done(point::AffineSpace, i) = done(point.pos, i)

function Base.show(io::IO, point::AffinePoint)
    print(io, "AffinePoint(")
    showcompact(io, point.pos)
    print(io,")")
end
function Base.showcompact(io::IO, point::AffinePoint)
    showcompact(io, point.pos)
end

# Adding and subtracting vectors from points
Base.(:+){P <: AffineSpace}(point::P, vec::Union{AbstractVector,FixedVector}) = P(point.pos + vec)
Base.(:+){P <: AffineSpace}(vec::Union{AbstractVector,FixedVector}, point::P) = P(vec + point.pos)

Base.(:-){P <: AffineSpace}(point::P, vec::Union{AbstractVector,FixedVector}) = P(point.pos + vec)

# Subtract to give vectors - uses underlying vector structure of the .pos field
Base.(:-)(point1::AffineSpace, point2::AffineSpace) = point1.pos - point2.pos

# Nice messages for disallowed operations
Base.(:+)(point1::AffineSpace, point2::AffineSpace) = error("Cannot add affine points. Consider adding a displacement vector instead.")
Base.(:*)(point::AffineSpace, x::Number) = error("Cannot scale affine points, since scaling is relative to the origin.")
Base.(:*)(x::Number, point::AffineSpace) = error("Cannot scale affine points, since scaling is relative to the origin.")
Base.(:-)(point::AffineSpace) = error("The additive inverse of an affine point is not defined, since affine points cannot be added.")
Base.(:-)(vec::Union{AbstractVector,FixedVector}, point::AffineSpace) = error("Cannot subtract an affine point from a vector.")

# Taking affine combinations of points
immutable AffineSubSpace{N, P<:AffineSpace}
    points::NTuple{N,P}
end

Base.start(ss::AffineSubSpace) = 1
Base.next(ss::AffineSubSpace, n::Int) = (ss.points[n], n+1)
Base.done{N}(ss::AffineSubSpace{N}, n::Int) = n > N

function Base.getindex{N, P}(ss::AffineSubSpace{N, P}, x...)
    lx = length(x)
    if lx == N
        @assert sum(x) ≈ 1 # maybe consider this a boundscheck?
        return P(sum(map(*, x, map(p -> p.pos, ss))))
    elseif lx == N - 1
        x = (x..., 1 - sum(x))
        return P(sum(map(*, x,  map(p -> p.pos, ss))))
    else
        error("Must specify either $N or $(N-1) numbers to define affine combination of $N points - got $lx")
    end
end

# Allow syntax like (point1:point2)[0.5] to get midpoint between point1 and point2
Base.colon(points::AffineSpace...) = AffineSubSpace(points)
Base.colon(ss::AffineSubSpace, points::AffineSpace...) = AffineSubSpace((ss.points..., points...))

# Base.mean as special case of affine combination
Base.mean{N,P <: AffineSpace}(points::NTuple{N,P}) = P(sum(map(p -> p.pos, points)) / N)

end # module
