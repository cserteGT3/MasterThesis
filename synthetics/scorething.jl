using StaticArrays
using Logging
using AbstractTrees
using D3Trees
using LinearAlgebra
using Makie

using Revise
using RANSAC
using RANSACVisualizer
using CSGBuilding
const CSGB = CSGBuilding

cd(@__DIR__)

function makeit()
    sp = ImplicitSphere([0.0,0,0], 5)
    pl = ImplicitPlane([0.0,0,0], [0,1,0])
    cyl = ImplicitCylinder([0,0,1], [0,-2.5,0], 1.5)

    spn = CSGNode(sp, [])
    pln = CSGNode(pl, [])
    cyln = CSGNode(cyl, [])
    tr1 = CSGNode(CSGB.intersection, [spn, pln])
    tr = CSGNode(CSGB.subtraction, [tr1, cyln])
    return tr, [sp, pl, cyl]
end

edgel = (mincorner=-5, maxcorner=5, edgelength=150);

vsw, nsw = readobj("wtr.obj", edgel);

sc = showgeometry(vsw, -1 .* nsw)
scatter(vsw)
scatter!(vsw[[158, 159]], color= :red)

smv = vsw[1:4:end]
smn = nsw[1:4:end]

ftree, surfac = makeit()

cmp_norm = [normal(ftree, c) for c in smv]

cnodes, cvals, cnorms = cachenodes(surfac, smv)


sc = plotimplshape(surfac[1])
plotimplshape!(sc, surfac[2], color=(:red, 0.2), scale = (10., 10.))
plotimplshape!(sc, surfac[3], color=(:green, 0.2), scale=10)

using FileIO
wtrm = load("wtr.obj")
mesh(wtrm)

scatter!(sc, smv[1:4:end], color=:blue)


## holed cube

edgel = (mincorner=-2, maxcorner=2, edgelength=110);
vhc, nhc = readobj("hcube.obj", edgel);
schc = scatter(vhc[1:8:end])
plotimplshape!(schc, surfs[1], color= (:red, 0.2), scale=(2.,2.))
plotimplshape!(schc, surfs[end-1], color= (:blue, 0.8), scale=(2.))
plotimplshape!(schc, surfs[end], color= (:orange, 0.2), scale=(5.,5.))




## cube
n1 = SVector(1,0,0.0);
n2 = SVector(0,1,0.0);
n3 = SVector(0,0,1.0);

pl1 = ImplicitPlane(n1, n1)
pl2 = ImplicitPlane(n2, n2)
pl3 = ImplicitPlane(n3, n3)
pl4 = ImplicitPlane(-n1, -n1)
pl5 = ImplicitPlane(-n2, -n2)
pl6= ImplicitPlane(-n3, -n3)
surfs = [pl1, pl2, pl3, pl4, pl5, pl6]

cubesize=10
vs2, ns2 = sampleunitcube(cubesize)

## just vis
scc = scatter(SVector{3, Float64}.(vs2))
plotimplshape!(scc, surface[1], color= (:red, 0.2), scale = (2.,2.))
plotimplshape!(scc, surface[2], color= (:green, 0.2), scale = (2.,2.))
plotimplshape!(scc, surface[3], color= (:blue, 0.2), scale = (2.,2.))
plotimplshape!(scc, surface[4], color= (:orange, 0.2), scale = (2.,2.))
plotimplshape!(scc, pl55, color= (:green, 0.2), scale = (2.,2.))
plotimplshape!(scc, surface[6], color= (:blue, 0.2), scale = (2.,2.))

pln1 = CSGNode(pl1, [])
pln2 = CSGNode(pl2, [])
pln3 = CSGNode(pl3, [])
pln4 = CSGNode(pl4, [])
pln5 = CSGNode(pl5, [])
pln6 = CSGNode(pl6, [])

tr1 = CSGNode(CSGBuilding.intersection, [pln1, pln2])
tr2 = CSGNode(CSGBuilding.intersection, [pln3, pln4])
tr3 = CSGNode(CSGBuilding.intersection, [tr1, tr2])
tr4 = CSGNode(CSGBuilding.intersection, [tr3, pln5])
tr5 = CSGNode(CSGBuilding.intersection, [tr4, pln6])

edgel = (mincorner=-2, maxcorner=2, edgelength=110);
writeparaviewformat(tr5, "ncube", edgel)
vss2, nss2 = readobj("ncube.obj", edgel);

vals = [value(evaluate(tr5, i)) for i in vss2]
lines(vals)
nors = [normal(tr5, i) for i in vss2]
vcomp15, ncomp15 = valueandnormal(tr5, vss2[15201])

for i in eachindex(vss2)
    vcomp, ncomp = valueandnormal(tr5, vss2[i])
    #@show ncomp
    #@show nss2[i]
    if acosd(dot(ncomp, nss2[i])) > 10
        println("$i normal is not approx")
    end
    if ! isapprox(vcomp, 0)
        println("$i val is not approx")
    end
end

cnodes, cvals, cnorms = cachenodes([pl1, pl2, pl3, pl4, pl5, pl6], vss2)

trc1 = CachedCSGNode(:intersection, [cnodes[1], cnodes[2]], gensym())
trc2 = CachedCSGNode(:intersection, [cnodes[3], cnodes[4]], gensym())
trc3 = CachedCSGNode(:intersection, [trc1, trc2], gensym())
trc4 = CachedCSGNode(:intersection, [trc3, cnodes[5]], gensym())
trc5 = CachedCSGNode(:intersection, [trc4, cnodes[6]], gensym())

for i in eachindex(vss2)
    norm_v = value(evaluate(tr5, vss2[i]))
    cached_v = value(evaluate(trc5, cvals, i))
    if norm_v!=cached_v
        println("$i is not OK")
    end
end

p = CSGGeneticBuildParameters{Float64}(ϵ_d=1.)

rsc = CSGB.rawscorefunc(trc5, cvals, cnorms, nss2, p, Base.Semaphore(1))

f = tree2func(trc5)

i = 1
resu = f(cvals, i)
v = value(resu)
n = normal(resu, cnorms, i)
d_i = v/p.ϵ_d
th_i = acos(dot(n, nss2[i]))/p.α
