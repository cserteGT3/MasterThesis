using StaticArrays
using AbstractTrees
using CSGBuilding
using RANSAC
const CSGB = CSGBuilding
using FileIO
using GeometryTypes
using LinearAlgebra: normalize

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

writeparaviewformat(wtr, "wtr", (-5, 5, 150))

function loaddata()
    wtrm = load("wtr.obj")
    vs = vertices(wtrm)
    ns = normalize.(normals(wtrm))
    return vs, ns
end

function testwtr(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    return cachedgeneticbuildtree(surfac, p, n, pari)
end

vsw, nsw = loaddata();

alls, bestt = testwtr(vsw, nsw, surfs, 10);
