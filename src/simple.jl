
# u ~ x ~ j
# v ~ y ~ i

function source_point_mat(X, Y)
    x1, x2, x3 = X
    y1, y2, y3 = Y    
    F = [x1 x2 x3; y1 y2 y3; 1 1 1]
    F
end

function target_point_mat(U, V)
    u1, u2, u3 = U
    v1, v2, v3 = V
    T = [u1 u2 u3; v1 v2 v3]
    T
end


function affine_params(X, Y, U, V)
    F = source_point_mat(X, Y)
    T = target_point_mat(U, V)
    M = T * inv(F)
    M
end

warp_pixel(M, x::Float64, y::Float64) = M * [x, y, 1]

function pa_warp{N}(img::Array{Float64, N},
                    src::Matrix{Float64}, dst::Matrix{Float64},
                    trigs::Matrix{Int})
    warped = zeros(eltype(img), size(img))    
    for t=1:size(trigs, 1)    
        tr = squeeze(trigs[t, :], 1)
        Y = src[tr, 1]
        X = src[tr, 2]
        
        V = dst[tr, 1]
        U = dst[tr, 2]
               
        # warp parameters from target (U, V) to source (X, Y)
        M = affine_params(U, V, X, Y)
        
        mask = poly2mask(U, V, size(img)[1:2]...)
        vs, us = findn(mask)
        
        # for every pixel in target triangle we find corresponding pixel in source
        # and copy its value
        for i=1:length(vs)
            u, v = us[i], vs[i]
            x, y = warp_pixel(M, float64(u), float64(v))
            if 1 <= y && y <= size(img, 1) && 1 <= x && x <= size(img, 2)
                warped[v, u, :] = img[int(y), int(x), :]
            end
        end
        
    end
    warped
end

