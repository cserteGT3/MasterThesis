using LinearAlgebra
using StaticArrays
using Makie
using GeometryTypes
using Random

using Revise
using RANSAC
using RANSACVisualizer

## Easy examples

n1 = SVector(1,0,0)
n2 = SVector(0,1,0.5)
nullp = SVector(0,0,0)

# Plane
pV, pN = sampleplane(nullp, n1, n2, (1,1), (4,4));

noiN = noisifynormals(pN, 45);
noiV = noisifyvertices(pV, true, 0.2)

plaN = normalsforplot(pV, pN);
plaNoi = normalsforplot(noiV, noiN);

scatter(pV)
scatter(noiV)

linesegments!(plaNoi, color = :blue)
linesegments!(plaN, color = :blue)

# Cylinder
cP, cN = samplecylinder(SVector(0,0,1), nullp, 5, 10, (100, 150))

noiNc = noisifynormals(cN, 45);
noiVc = noisifyvertices(cP, true, 0.2);

plaNc = normalsforplot(cP, cN);
plaNcoi = normalsforplot(noiVc, noiNc);

scatter(cP)
scatter(noiVc)

linesegments!(plaNc,  color = :blue)
linesegments!(plaNcoi,  color = :blue)

# Sphere
sP, sN = samplesphere(SVector(1,0.5,7), 5, (70,73))
scatter(sP)

sphereN = normalsforplot(sP, sN);
linesegments!(sphereN, color = :blue)

noisPsp = noisifyvertices(sP, true, 0.02);
noisNsp = noisifynormals(sN, 20);
sphereNois = normalsforplot(noisPsp, noisNsp);

scatter(noisPsp)
linesegments!(sphereNois, color = :blue)

## a random sample
vs, ns, normsP = makemeanexample(true)

scatter(vs)
linesegments!(normsP, color = :blue)

## Regiontree tests

using StaticArrays
using RegionTrees

r = Cell(SVector(0.0,0,0),SVector(1.0,1,1))
split!(r)
cb1 = child_boundary(r,(1,1,1))
vcb1 = vertices(cb1)

for i in 1:2
   for j in 1:2
       for k in 1:2
           @show (i,j,k)
           @show child_boundary(r,(i,j,k))
       end
   end
end

v2 = collect(1:30);
v3 = rand(Bool,10);
v33 = rand(Bool,10);

v4 = SVector(0,0);
v5 = SVector(-1,1);

using GeometryTypes: Point3f0

r = Cell(SVector(0.0,0,0),SVector(1.0,1,1))
d = OctreeNode(rand(Point3f0, 10), collect(1:10), 1.0, 0)
octref = OctreeRefinery(1)
r2 = Cell(SVector(0.0,0,0),SVector(1.0,1,1), d)

iswithinrectangle(r2.boundary, rand(Point3f0))
map(x -> iswithinrectangle(r2.boundary, x), rand(Point3f0,10))

## Fitting tests

# plane

n1 = SVector(1,0,0);
n2 = SVector(0,1,0);
nullp = SVector(0,0,0);

tpv, tpn = sampleplane(nullp, n1, n2, (0.5,7.5), (2,2));

showgeometry(tpv, tpn)

α = 10;
isplane(tpv,tpn, deg2rad(α))

fp = isplane(cP,cN, deg2rad(α))

# sphere
o = SVector(0.0,5,π);
R = 5;
tsP, tsN = samplesphere(o, R, (70,73));

s = Scene();
showgeometry(s, tsP, tsN)

α = 10;
ϵ = 0.1;
rk = [125, 1517, 2941];
issphere(tsP[rk], tsN[rk], ϵ, deg2rad(α))

testv = [SVector(6,8,4), SVector(6,8,2)];
testn = [SVector(6,7,0), SVector(6,7,4)];

# cross test

tpv2, tpn2 = sampleplane(nullp, n1, n2, (0.5,7.5), (70,73));
tsP2, tsN2 = samplesphere(o, R, (70,73));

ra = [195,1596,3845]
isplane(tsP2[ra],tsP2[ra], deg2rad(α))

issphere(tpv2[rk], tpv2[rk], ϵ, deg2rad(α))

# cylinder

n1 = SVector(1,0,0);
n2 = SVector(0,1,0);
n3 = SVector(-1,0,0);
nsc = [n1,n2,n3];
psc = [SVector(n[1], n[2],3.14) for n in nsc]
psc = [SVector(nsc[i][1], nsc[i][2], i) for i in eachindex(nsc)]
psc = [ 2*n for n in nsc]

fcc = iscylinder(psc, nsc, 0.1, deg2rad(15))

n1 = SVector(0,0,-1);
n2 = SVector(0,1,0);
n3 = SVector(0,0,1);
nsc = [n1,n2,n3];
psc = [SVector(n[1]+5, n[2] +2,3.14) for n in nsc]
psc = [ 2*n for n in nsc]

iscylinder(psc, nsc, 0.1, deg2rad(15))

n1 = SVector(0,0,-1);
n2 = SVector(0,1,0);
n3 = SVector(0,0,1);
nsc = [n1,n2,n3];
psc = [SVector(n[1]+5, n[2]+1,n[3]+2) for n in nsc]

iscylinder(psc, nsc, 0.1, deg2rad(15))

## bitmap
# plane

v1 = [0,1,0];
degg = 45;
v2 = normalize([cos(deg2rad(degg)),sin(deg2rad(degg)),0])

isparallel(v1, [0,-1,0], deg2rad(1))

n1 = SVector(1,0,0);
n2 = SVector(0,1,0.0);
nullp = SVector(0,0,0);

# Plane
pV, pN = sampleplane(nullp, n1, n2, (1,1), (5,5));
ixs = [1,15,20]
tp = isplane(pV[ixs], pN[ixs], deg2rad(50))

pC, pP = compatiblesPlane(tp, pV, pN, 0.1, deg2rad(10));
sC, sP = compatiblesPlane(tp, tsP, tsN, 0.1, deg2rad(10));

# Cylinder
a = normalize(SVector(0,5,1.0));
n2 = SVector(0,1,0.0);
pcc, ncc = samplecylinder(a, n2, 5,10, (29,47))
showgeometry(pcc, ncc)

k1, k2 = samplecylinder(normalize(SVector(2,1.3,-0.5)), SVector(4,16,-3.9), 3.79, 4, (57,29) )
showgeometry(k1,k2)

ixs = [15,587, 313]
ic = iscylinder(pcc[ixs], ncc[ixs], 0.1, deg2rad(10))

ccc, ccp = compatiblesCylinder(ic, pcc, ncc, 0.1, deg2rad(10))
length(pcc)
count(ccc)
# bitmapper
using ImageView

bM, idxM, betas = bitmapparameters(chopzaxis(pP), pC, 0.1);
imshow(bM);
largestconncomp(bM, idxM)

# Sphere

sP, sN = samplesphere(SVector(1,0.5,7), 5, (70,73));
α = 10;
ϵ = 0.1;
rk = [125, 1517, 2941];
fsp = issphere(sP[rk], sN[rk], ϵ, deg2rad(α));

cSP, uoT, params = compatiblesSphere(fsp, sP, sN, ϵ, deg2rad(50));
unders = uoT.under;
overs = uoT.over;
overSbm, overSid, overSb = bitmapparameters(params[overs], cSP[overs], 0.1, overs);
underSbm, underSid, underSb = bitmapparameters(params[unders], cSP[unders], 0.1, unders);

imshow(overSbm);
imshow(underSbm);

largestconncomp(overSbm, overSid)
largestconncomp(underSbm, underSid)


## cone

n1 = SVector(1.,0,0);
n2 = SVector(0,1,0.0);
n3 = SVector(0,0,1.0);

Random.seed!(1234)
p1 = SVector{3}(rand(3))
p2 = SVector{3}(rand(3))
p3 = SVector{3}(rand(3))

p = [p1, p2, p3]
n = [n1, n2, n3]

m1 = hcat([n1, n2, n3]...)
dvs = [-1*dot(p[i], n[i]) for i in 1:3]
m2 = hcat(m1, dvs)

# test cone

apex = SVector(0,0,0)
apex = SVector(15,-7, 0.5)
axis = SVector(0,0,1.)
opang = deg2rad(20)
h = 10.
sizet = (10,10)

cps, cns = samplecone(apex, axis, opang, h, sizet)
showgeometry(cps, cns)

ex6v, ex6n, _, sh_s = examplepc6()
showgeometry(ex6v ,ex6n)

rrr = [25, 19, 97]
rrr2 = [25, 97, 19]
hicone = RANSAC.fit3pointcone(cps[rrr], cns[rrr])
hicone2 = RANSAC.fit3pointcone(cps[rrr2], cns[rrr2])

sc = scatter(cps)
scatter!(sc, p3, color=:red, markersize=0.5)
scatter!(sc, cps[rrr], color=:green, markersize=0.5)
showgeometry!(sc, cps[rrr], cns[rrr])

p = RANSACParameters{Float64}()

hcone = RANSAC.fitcone(cps[rrr], cns[rrr], p)
hcone2 = RANSAC.fitcone(cps[rrr2], cns[rrr2], p)
