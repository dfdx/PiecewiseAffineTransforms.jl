
# simple example of transforming person's face from one shape to another

using Images
using ImageView
using MAT
using VoronoiDelaunay

const IMG_HEIGHT = 480

package_dir = joinpath(Pkg.dir(), "PiecewiseAffineTransforms")
data_dir = joinpath(package_dir, "examples", "data")

src_img_name = "107_0764.bmp"
dst_img_name = "107_0779.bmp"
src_shape_name = src_img_name + ".mat"
dst_shape_name = dst_img_name + ".mat"

# read 2 images: src_img will be transformed to resemble dsr_img
src_img = convert(Array, separate(imread(joinpath(data_dir, src_img_name))))
dst_img = convert(Array, separate(imread(joinpath(data_dir, dst_img_name))))
# read corresponding shape data
src_shape = matread(joinpath(data_dir, src_shape_name))["annotations"]
dst_shape = matread(joinpath(data_dir, dst_shape_name))["annotations"]

# get triangulation
trigs = 

println("Simple warp")
warped_simple = pa_warp(src_img, src_shape, dsr_shape, trigs)
