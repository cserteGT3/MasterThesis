using LinearAlgebra
using StaticArrays
using Random
using Colors
using FileIO
using GeometryTypes: vertices, normals

using Makie

using Revise
using RANSAC

erveg = load(raw"C:\Users\cstamas\Documents\SZTAKI\ransac\erveg2.ply")

erveg_v = [SVector{3}(v) for v in vertices(erveg)]
erveg_n = [SVector{3}(normalize(v)) for v in normals(erveg)]

#showgeometry(erveg_v, erveg_n, arrow=0.4)
## Erveg
pcr = PointCloud(erveg_v, erveg_n, 1);

# plane
p_ae = (ϵ = 5, α=deg2rad(20));
cy_ae = (ϵ = 5, α=deg2rad(10));
sp_ae = (ϵ = 2, α=deg2rad(5));
one_ae = AlphSilon(sp_ae, p_ae, cy_ae);
# number of minimal subsets drawed in one iteration
tt = 20;
# probability that we found shapes
ptt = 0.9
# minimum shape size
ττ = 500
# maximum number of iteration
itermax = 20
# size of the minimal set
draws = 3
cand, extr = ransac(pcr, one_ae, tt, ptt, ττ, itermax, draws, 500, true)
showtype(extr)
showshapes(pcr, extr)

showbytype(pcr, extr)
