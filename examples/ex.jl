
println("Simple example of transforming person's face from one shape to another")

using Images
using ImageView
using MAT
using VoronoiDelaunay
using PiecewiseAffineTransforms
using Color
using FixedPointNumbers

const IMG_HEIGHT = 480
package_dir = joinpath(Pkg.dir(), "PiecewiseAffineTransforms")
data_dir = joinpath(package_dir, "examples", "cootes")

# some auxilary functions for reading data
rawdata(img) = convert(Array{Float64, 3}, data(separate(img)))
xy2ij(shape, height) = [height .- shape[:, 2] shape[:, 1]]

read_image(path) = rawdata(imread(path))
read_shape(path) = xy2ij(matread(path)["annotations"], IMG_HEIGHT)


src_img_path = joinpath(data_dir, "107_0764.bmp")
dst_img_path = joinpath(data_dir, "107_0779.bmp")
src_shape_path = src_img_path * ".mat"
dst_shape_path = dst_img_path * ".mat"

# read 2 images: src_img will be transformed to resemble dst_img
src_img = read_image(src_img_path)
# dst_img = convert(Array, separate(imread(joinpath(data_dir, dst_img_name))))
dst_img = read_image(dst_img_path)
# read corresponding shape data
src_shape = read_shape(src_shape_path)
dst_shape = read_shape(dst_shape_path)

# get triangulation
trigs = delaunayindexes(src_shape)

println("Original images and shapes (press Enter to continue)")
triplot(src_img, src_shape, trigs)
triplot(dst_img, dst_shape, trigs)
readline(STDIN)

println("Simple warp (press Enter to continue)")
@time warped_simple = pa_warp(src_img, src_shape, dst_shape, trigs)
view(src_img)
view(warped_simple)
readline(STDIN)

println("Preparing warp parameters")
@time pa_params = pa_warp_params(dst_shape, trigs, (480, 640))

println("Prepared warp (press Enter to finish)")
@time warped_prepared = pa_warp(pa_params, src_img, src_shape)
view(src_img)
view(warped_prepared)
readline(STDIN)
