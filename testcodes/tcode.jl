using StaticArrays
using GeometryTypes
using Makie

using Revise
using RANSAC

p1 = SVector(0.,0,0.001);
p2 = SVector(1.,0,0);
p3 = SVector(0.,1,0);
ps = [p1,p2,p3];

n1 = SVector(0.,0,1);
ns = [n1,n1,n1];

p = RANSACParameters{Float64}()

fp = RANSAC.fitplane(ps,ns,p)
plotshape(fp)

fs = FittedSphere(true, SVector(0.,0,0),1.,true)
plotshape(fs)

fc = FittedCylinder(true,n1,p2,1.,true)
plotshape(fc, scale=(2,))

fco = SVector(0.,0,0);
fcextr = SVector(0.,5,10);
mesh(Cylinder(Point(fco),Point(fcextr),1.))

## sample plane 1
randn = SVector{3}(normalize(rand(3)))
sp1_fp = FittedPlane(true, SVector(0.,0,0),randn)
v_sp1, n_sp1 = sampleplane(SVector(0.,0,0),randn,(5,5), (25,25))

sc1 = plotshape(sp1_fp, color=(:red, 0.2), scale=(5,5))
scatter!(v_sp1)

bs, prs = RANSAC.compatiblesPlane(sp1_fp, v_sp1, n_sp1, p)
bs == trues(size(bs))
# that is true

# noisifying vertices
v_sp1n = RANSAC.noisifyv_fixed(deepcopy(v_sp1), true)
sc2 = plotshape(sp1_fp, color=(:red, 0.2), scale=(5,5))
scatter!(sc2, v_sp1n)
#scatter!(v_sp1, color=:blue)
RANSAC.shiftplane!(sc2, sp1_fp, p.ϵ_plane, scale=(5,5), color=(:green,0.3))
RANSAC.shiftplane!(sc2, sp1_fp, -p.ϵ_plane, scale=(5,5), color=(:green,0.3))

bs2, prs2 = RANSAC.compatiblesPlane(sp1_fp, v_sp1n, n_sp1, p)
scatter!(sc2, v_sp1n[bs2], color=:green)

# this looks good to me

# noisifying vertices
v_sp1n = RANSAC.noisifyv_fixed(deepcopy(v_sp1), true)
sc2 = plotshape(sp1_fp, color=(:red, 0.2), scale=(5,5))
scatter!(sc2, v_sp1n)
#scatter!(v_sp1, color=:blue)
RANSAC.shiftplane!(sc2, sp1_fp, p.ϵ_plane, scale=(5,5), color=(:green,0.3))
RANSAC.shiftplane!(sc2, sp1_fp, -p.ϵ_plane, scale=(5,5), color=(:green,0.3))

bs2, prs2 = RANSAC.compatiblesPlane(sp1_fp, v_sp1n, n_sp1, p)
scatter!(sc2, v_sp1n[bs2], color=:green)

# this looks good to me
# v_sp1, n_sp1
n_sp1n = noisifynormals(deepcopy(n_sp1), 20)
sc3 = showgeometry(v_sp1, n_sp1n)
bs3, prs3 = RANSAC.compatiblesPlane(sp1_fp, v_sp1, n_sp1n, p)
scatter!(sc3, v_sp1[bs3], color=:green)


## ööö izé

vs, ns, norms4Plot, shape_s = examplepc3();
pcr = PointCloud(vs, ns, 32)
p = RANSACParameters{Float64}()
p = RANSACParameters(p, ϵ_plane=0.3, α_plane=deg2rad(5))
p = RANSACParameters(p, ϵ_cylinder=0.3, α_cylinder=deg2rad(5))
p = RANSACParameters(p, ϵ_sphere=0.3, α_sphere=deg2rad(5))
p = RANSACParameters(p, minsubsetN=15, prob_det=0.9, τ=900)
p = RANSACParameters(p, itermax=20_000, drawN=3)
b1, b2 = ransac(pcr, p, true);


pl1 = b2[8].candidate.shape

sc4 = plotshape!(pl1, scale= (10,10))
cpl1, _ = RANSAC.compatiblesPlane(pl1, pcr.vertices, pcr.normals, p)
scatter!(pcr.vertices[cpl1], color=:green)
scatter!(pcr.vertices[ .~ cpl1], color=:red)
