# Piecewise Affine Transformations

Package for smooth deformation of complex shapes. 

## Installation

    Pkg.add("PiecewiseAffineTransforms")

## Usage Overview

Piecewise affine transformation resembles ordinary affine transformation, but instead of warping single region linearly, it splits down area under the question into a set of triangles and warps each such triangle separately. Let's see it by example (full version is available in `examples/ex.jl`).

Say, we have an image of a face and want to warp it to have different expression: 

<table>
  <tr>
    <td>
      <img src="https://raw.githubusercontent.com/dfdx/PiecewiseAffineTransforms.jl/master/examples/cootes/107_0764.bmp"/>
    </td>
    <td>
      <img src="https://raw.githubusercontent.com/dfdx/PiecewiseAffineTransforms.jl/master/examples/cootes/107_0779.bmp"/>
    </td>
  </tr>
</table>



![cootes](https://github.com/dfdx/PiecewiseAffineTransforms.jl/tree/master/examples) 
