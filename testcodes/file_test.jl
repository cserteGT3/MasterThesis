# every include
using LinearAlgebra
using StaticArrays
using Random
using Colors
using Makie

using Revise
using RANSAC
using RANSACVisualizer

using DelimitedFiles

cd(@__DIR__)

pwdata = joinpath(pwd(),"data")
fdarm = joinpath(pwd(), "darmstadt.dat")
fpulley = joinpath(pwdata, "pulley.dat")

darm_dat = readdlm(fdarm, ' ', Float64, '\n', skipstart = 1 )
p_dat = readdlm(fpulley, ' ', Float64, '\n', skipstart = 1 )

p_vs = [SVector(p_dat[i,1], p_dat[i,2], p_dat[i,3]) for i in 1:size(p_dat,1)]
p_ns_ = [SVector(p_dat[i,4], p_dat[i,5], p_dat[i,6]) for i in 1:size(p_dat,1)]
p_ns = normalize.(p_ns_)

scatter(p_vs)
showgeometry(p_vs, p_ns, arrow = 0.4)

d_vs = [SVector(darm_dat[i,1], darm_dat[i,2], darm_dat[i,3]) for i in 1:size(darm_dat,1)]
d_ns_ = [SVector(darm_dat[i,4], darm_dat[i,5], darm_dat[i,6]) for i in 1:size(darm_dat,1)]
d_ns = normalize.(d_ns_)

scatter(d_vs)
sc = showgeometry(d_vs, d_ns)
cam3d_cad!(sc)

## Pulley
rndr = randperm(length(p_vs))
indi = rndr[1:4:length(p_vs)]
pcr = PointCloud(p_vs[indi], p_ns[indi], 20);
pcr = PointCloud(p_vs, p_ns, 20);

# plane
p_ae = (ϵ = 2, α=deg2rad(10));
# cylidner
cy_ae = (ϵ = 2, α=deg2rad(10));
# sphere
sp_ae = (ϵ = 0.2, α=deg2rad(5));
one_ae = AlphSilon(sp_ae, p_ae, cy_ae);
# number of minimal subsets drawed in one iteration
tt = 20;
# probability that we found shapes
ptt = 0.9
# minimum shape size
ττ = 500
# maximum number of iteration
itermax = 50000
# size of the minimal set
draws = 3
cand, extr = ransac(pcr, one_ae, tt, ptt, ττ, itermax, draws, 500, true)
showtype(extr)
showshapes(pcr, extr)

showbytype(pcr, extr)

# Darmstadt
Random.seed!(1234)
rndr2 = randperm(length(d_vs))
indi2 = rndr2[1:4:length(d_vs)]
pcr2 = PointCloud(d_vs[indi2], d_ns[indi2], 20);
pcr2 = PointCloud(d_vs, d_ns, 32);

using Logging
global_logger(nosource_IterInflog())

# plane
p = RANSACParameters{Float64}(ϵ_plane=0.4,
                                α_plane=deg2rad(5),
                                ϵ_sphere=0.3,
                                α_sphere=deg2rad(2.5),
                                ϵ_cylinder=0.3,
                                α_cylinder=deg2rad(2.5),
                                ϵ_cone=0.15,
                                α_cone=deg2rad(1),
                                minsubsetN=15,
                                itermax=100_000);

cand, extr = ransac(pcr2, p, true, reset_rand=true);
showtype(extr)
showbytype(pcr2, extr, markersize=0.5)
showshapes(pcr2, extr, markersize=0.5)
showshapes!(sc, pcr2, [cand[6]]; markersize=1)


## by type
sc = showbytype(pcr2, extr; markersize=0.5)
scatter!(sc, pcr2.vertices[getrest(pcr2)], markersize=0.5)
cam3d_cad!(sc)

sc2 = showgeometry(d_vs, d_ns);
sc3 = hbox(sc, sc2)


## different
sc = showshapes(pcr2, extr; markersize=0.3)
scatter!(sc, pcr2.vertices[getrest(pcr2)], markersize=0.3)
cam3d_cad!(sc)

sc2 = showgeometry(d_vs, d_ns);
sc3 = hbox(sc, sc2)


using ColorSchemes

colsss = ColorSchemes.gnuplot
get(colsss, 0.5)
