

function inpolygon{T<:Number}(x:: T, y:: T, vx:: Vector{T}, vy:: Vector{T})
    @assert length(vx) == length(vy)
    c = false
    j = length(vx)
    @inbounds for i=1:length(vx)
        if (((vy[i] <= y && y < vy[j]) ||
            (vy[j] <= y && y < vy[i])) &&
            (x < (vx[j] - vx[i]) * (y - vy[i]) / (vy[j] - vy[i]) + vx[i]))
            c = !c
        end
        j = i
    end
    return c
end


function fillpoly!{T,P<:Number}(M::Matrix{T}, px::Vector{P}, py::Vector{P}, value::T)
    @assert length(px) == length(py)
    left, right = round(Int, minimum(px)), round(Int, maximum(px))
    top, bottom = round(Int, minimum(py)), round(Int, maximum(py))
    for x=left:right
        ys = Set{Int64}()
        j = length(px)
        for i=1:length(px)
            if (px[i] <= x <= px[j]) || (px[j] <= x <= px[i])
                # special case: adding the whole cut to ys
                if abs(px[i] - px[j]) <= eps(P)
                    push!(ys, round(Int, py[i]))
                    push!(ys, round(Int, py[j]))
                else
                    y = py[i] + (x - px[i]) / (px[j] - px[i]) * (py[j] - py[i])
                    push!(ys, round(Int, y))
                end
            end
            j = i
        end
        ys = sort([y for y in ys])
        # if there's an odd number of intersection points, add one imeginary point
        if length(ys) % 2 == 1
            push!(ys, ys[end])
        end
        for i=1:2:length(ys)
            M[ys[i]:ys[i+1], x] = value  # <-- bounds error here!
        end
    end
    return M
end


function poly2mask{P}(px::Vector{P}, py::Vector{P}, m::Int, n::Int)
    mask = zeros(Bool, m, n)
    fillpoly!(mask, px, py, true)
end



