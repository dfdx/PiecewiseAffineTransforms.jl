# Piecewise Affine Transformations

Package for smooth deformation of complex shapes. 

## Installation

    Pkg.add("PiecewiseAffineTransforms")

## Usage Overview

Piecewise affine transformation resembles ordinary affine transformation, but instead of warping single region linearly, it splits down area under the question into a set of triangles and warps each such triangle separately. 

Let's say, we have an image of a face and want to warp it to have different expression (destination image is here only for demonstration, we will not use it): 

    using PiecewiseAffineTransforms

    src_img = ...
    dst_img = ...

(full version of code is available in `examples/ex.jl`)

<table>
  <thead>
    <tr><td>Source image</td><td>Destination image</td></tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <img src="https://raw.githubusercontent.com/dfdx/PiecewiseAffineTransforms.jl/master/examples/cootes/107_0764.bmp"/>
      </td>
      <td>
        <img src="https://raw.githubusercontent.com/dfdx/PiecewiseAffineTransforms.jl/master/examples/cootes/107_0779.bmp"/>
      </td>
    </tr>
  </tbody>
</table>

We will also assume that both faces are annotated with corresponding shape landmarks: 

    src_shape = ... # should be a Nx2 matrix of Float64, 
                    #  where N is a number of landmarks
    dst_shape = ...

First of all, we need to split the shapes into triangles, i.e. triangulate them:

    trigs = delaunayindexes(src_shape)  # Tx3 matrix of Int, where T is 
                                        #  a number of resuling triangles
    triplot(src_img, src_shape, trigs)
    triplot(dst_img, dst_shape, trigs)

<table>
  <thead>
    <tr><td>Source shape</td><td>Destination shape</td></tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <img src="https://raw.githubusercontent.com/dfdx/PiecewiseAffineTransforms.jl/master/examples/processed/triplot_src.png"/>
      </td>
      <td>
        <img src="https://raw.githubusercontent.com/dfdx/PiecewiseAffineTransforms.jl/master/examples/processed/triplot_src.png"/>
      </td>
    </tr>
  </tbody>
</table>

Warping `src_image` from `src_shape` to `dst_shape` may be as simple as calling this:

    @time warped = pa_warp(src_img, src_shape, dst_shape, trigs)
    # 1.44 seconds 

But if you are going to repeat warping to `dst_shape` for many source images or just many times, it's worth to prepare warp by creating `PAWarpParams` object and using it for all future transformation to `dst_shape`:

    @time pa_params = pa_warp_params(dst_shape, trigs, (480, 640))
    # 5.92 seconds
    @time warped = pa_warp(pa_params, src_img, src_shape)
    # 0.075 seconds

But anyway, they both give (almost) the same result: 

    <img src="https://raw.githubusercontent.com/dfdx/PiecewiseAffineTransforms.jl/master/examples/processed/warped_prepared.png"/>


## Acknowledgement

Code for prepared warp was mostly extracted from ICAAM project by Luca Vezzaro.