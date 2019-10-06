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

erveg_v = [SVector{3}(v) for v in vertices(erveg)];
erveg_n = [SVector{3}(normalize(v)) for v in normals(erveg)];

#showgeometry(erveg_v, erveg_n, arrow=0.4)
## Erveg
pcr = PointCloud(erveg_v, erveg_n, 1);
p = RANSACParameters{Float64}()
p = RANSACParameters(p, ϵ_plane=0.3, α_plane=deg2rad(5))
p = RANSACParameters(p, ϵ_cylinder=0.3, α_cylinder=deg2rad(5))
p = RANSACParameters(p, ϵ_sphere=0.3, α_sphere=deg2rad(5))
p = RANSACParameters(p, minsubsetN=15, prob_det=0.9, τ=900)
p = RANSACParameters(p, itermax=200, drawN=3)
p = RANSACParameters(p, shape_types=[:plane])
cand, extr = ransac(pcr, p, true)
showtype(extr)
showshapes(pcr, extr)

showbytype(pcr, extr)
