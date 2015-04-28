

type PAWarpParams
    shape::Matrix{Float64}             # shape to warp to 
    dst_size::@compat(Tuple{Int, Int}) # destination size
    trigs::Matrix{Int}                 # triangulation of a shape
    warp_map::Matrix{Int}              # map from pixel in destination to
                                       #   corresponding triangle
    alpha_coords::Matrix{Float64}      # 1st barycentric coordinate w.r.t.
                                       #   corrsponding triangle in warp_map
    beta_coords::Matrix{Float64}       # 2nd barycentric coordinate w.r.t.
                                       #   corrsponding triangle in warp_map
end


function pa_warp_params(shape::Matrix{Float64}, trigs::Matrix{Int},
                        dst_size::@compat(Tuple{Int, Int}))
    h, w = dst_size
    warp_map = zeros(Int, h, w)
    alpha_coords = zeros(h, w)
    beta_coords = zeros(h, w)
    for j=1:w
        for i=1:h
            for k=1:size(trigs, 1)
                t = trigs[k, :]
                i1 = shape[t[1], 1]
                j1 = shape[t[1], 2]
                i2 = shape[t[2], 1]
                j2 = shape[t[2], 2]
                i3 = shape[t[3], 1]
                j3 = shape[t[3], 2]

                den = (i2 - i1) * (j3 - j1) - (j2 - j1) * (i3 - i1)
                alpha = ((i - i1) * (j3 - j1) - (j - j1) * (i3 - i1)) / den
                beta = ((j - j1) * (i2 - i1) - (i - i1) * (j2 - j1)) / den

                if alpha >= 0 && beta >= 0 && (alpha + beta) <= 1
                    # found the triangle, save data to the bitmaps and break
                    warp_map[i, j] = k
                    alpha_coords[i, j] = alpha
                    beta_coords[i,j] = beta
                    break;
                end
            end
        end
    end
    return PAWarpParams(copy(shape), dst_size, trigs,
                        warp_map, alpha_coords, beta_coords)
end


function pa_warp{T,N}(params::PAWarpParams, src_img::Array{T,N},
                    src_shape::Matrix{Float64};
                    interp=:bilinear)
    nc = size(src_img, 3)
    h, w = params.dst_size
    warp_map = params.warp_map
    alpha_coords, beta_coords = params.alpha_coords, params.beta_coords
    dst_img = zeros(T, h, w, nc)
    for j=1:w
        for i=1:h           
            t = warp_map[i, j]
            # if t <= 0, pixel is out of destination shape
            if t > 0                
                # index of first vertex of the triangle
                v1 = params.trigs[t, 1]
                i1 = src_shape[v1, 1]
                j1 = src_shape[v1, 2]

                v2 = params.trigs[t, 2]
                i2 = src_shape[v2, 1]
                j2 = src_shape[v2, 2]
                
                v3 = params.trigs[t, 3]
                i3 = src_shape[v3, 1]
                j3 = src_shape[v3, 2]

                wi = (i1 +
                      alpha_coords[i, j] * (i2 - i1) +
                      beta_coords[i, j] * (i3 - i1))
                wj = (j1 +
                      alpha_coords[i, j] * (j2 - j1) +
                      beta_coords[i, j] * (j3 - j1))

                if wi < 1 || wi > size(src_img, 1) ||
                    wj < 1 || wj > size(src_img, 2)
                    # throw(@compat(BoundsError("Warp pixel is out of bounds: " *
                    #                   "wi=$wi, wj=$wj")))
                    throw(BoundsError())
                end

                lli = convert(Int, floor(wi))
                llj = convert(Int, floor(wj))
                uri = lli + 1
                urj = llj + 1

                f0 = (uri - wi) * (urj - wj)
                f1 = (wi - lli) * (urj - wj)
                f2 = (uri - wi) * (wj - llj)
                f3 = (wi - lli) * (wj - llj)
                
                for c=1:nc
                    if interp == :bilinear
                        interpolated = (src_img[lli, llj, c] * f0 +
                                        src_img[uri, llj, c] * f1 +
                                        src_img[lli, urj, c] * f2 +
                                        src_img[uri, urj, c] * f3)
                        dst_img[i, j, c] = interpolated
                    elseif interp == :nearest
                        dst_img[i, j, c] = src_img[convert(Int, round(wi)),
                                                   convert(Int, round(wj)), c]
                    else
                        error("Unknown interpolation type: $interp")
                    end
                end 
            end            
        end
    end
    # for 2D images, fix dimensions
    return squeeze(dst_img, N+1)
end

