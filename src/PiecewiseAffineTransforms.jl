module PiecewiseAffineTransforms

export PAWarpParams,
       pa_warp_params,
       pa_warp,
       delaunayindexes,
       triplot,
       ## probably these fucntions should not reside here,
       ## but I couldn't find better place for them
       inpolygon,
       fillpoly!,
       poly2mask
       

include("core.jl")

end
