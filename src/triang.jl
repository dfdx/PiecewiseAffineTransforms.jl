
import GeometricalPredicates.getx
import GeometricalPredicates.gety


type IndexedPoint2D <: AbstractPoint2D
    _x::Float64
    _y::Float64
    _idx::Int64
    IndexedPoint2D(x, y, idx) = new(x, y, idx)
    IndexedPoint2D(x, y) = new(x, y, 0)
end


getx(p::IndexedPoint2D) = p._x
gety(p::IndexedPoint2D) = p._y
getidx(p::IndexedPoint2D) = p._idx


function to_points(shape::Matrix{Float64})
    min_value, max_value = (minimum(shape), maximum(shape))
    sc = (max_value - min_value) / (max_coord - min_coord)
    sc_shape = (shape .- min_value) / sc + min_coord
    points = IndexedPoint2D[IndexedPoint2D(sc_shape[i, 1], sc_shape[i, 2], i)
                            for i in 1:size(shape, 1)] 
    return (points, sc)
end


function gettriangles(shape::Matrix{Float64})
    npoints = size(shape, 1)
    tess = DelaunayTessellation2D{IndexedPoint2D}(npoints)
    points, _ = to_points(shape)
    push!(tess, points)
    return collect(tess)[1:end-1]   # TODO: don't include into iterator
end

 
function delaunayindexes(shape::Matrix{Float64})
    trigs = gettriangles(shape)
    idxs = zeros(Int64, length(trigs), 3)
    for i=1:length(trigs)
        idxs[i, 1] = getidx(geta(trigs[i]))
        idxs[i, 2] = getidx(getb(trigs[i]))
        idxs[i, 3] = getidx(getc(trigs[i]))
    end
    return idxs
end


