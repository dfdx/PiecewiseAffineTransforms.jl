
function triplot(img::Image, shape::Matrix{Float64}, trigs::Matrix{Int64})
    imgc, img2 = view(img)
    for i=1:size(trigs, 1)
        a = (shape[trigs[i, 1], 2], shape[trigs[i, 1], 1])
        b = (shape[trigs[i, 2], 2], shape[trigs[i, 2], 1])
        c = (shape[trigs[i, 3], 2], shape[trigs[i, 3], 1])
        annotate!(imgc, img2, AnnotationLine(a, b))
        annotate!(imgc, img2, AnnotationLine(b, c))
        annotate!(imgc, img2, AnnotationLine(c, a))
    end
    imgc, img2
end

triplot{T,N}(mat::Array{T, N}, shape::Matrix{}, trigs::Matrix{Int64}) =
    triplot(convert(Image, mat), shape, trigs)
