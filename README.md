# AffineSpaces

*The perfect Julia package for those who love being pedantic about points*

[![Build Status](https://travis-ci.org/andyferris/AffineSpaces.jl.svg?branch=master)](https://travis-ci.org/andyferris/AffineSpaces.jl)

### `abstract AffineSpace{T}``

An `AffineSpace` object represents points in an affine space, which is similar
to a Cartesian space but where no special meaning can be assigned to the origin.
Subtypes of `AffineSpace` should have a field named `pos` with vector-like
abilities describing the coordinates.

The consequences are that points do not have vector-like abilities such as
multiplication by a scalar (scaling the distance relative to the origin), unary
inversion (reflection about the origin) or addition of the coordinates of two
points (coordinates being relative to the origin).

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

### `AffinePoint{N,T} <: FixedAffineSpace{T}`

A concrete type describing a point in an affine space, where the Cartesian
coordinates of the point are stored in a `FixedSizeArrays.Vec{N,T}`. See
`AffineSpace` for a description of the interface for affine points.
