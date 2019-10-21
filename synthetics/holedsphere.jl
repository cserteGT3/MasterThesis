using StaticArrays
using AbstractTrees
using CSGBuilding
using RANSAC
const CSGB = CSGBuilding
using FileIO
using GeometryTypes
using LinearAlgebra: normalize
using FileIO: load

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

wtr, surfs = makeit();
edgel = (mincorner=-5, maxcorner=5, edgelength=150);

writeparaviewformat(wtr, "wtr", edgel)

function testwtr(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    return cachedgeneticbuildtree(surfac, p, n, pari)
end

vsw, nsw = readobj("wtr.obj", edgel);

alls, bestt = testwtr(vsw, nsw, surfs, 10);

writeparaviewformat(bestt, "bestwtr", (-7,7,100))
