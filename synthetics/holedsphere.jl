using StaticArrays
using AbstractTrees
using RANSAC
using D3Trees
using Revise
using CSGBuilding
const CSGB = CSGBuilding
using Logging

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

# writeparaviewformat(wtr, "wtr", edgel)

function testwtr(p, n, surfac, iters; kwargs...)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters; kwargs...)
    @info "cachedgeneticbuildtree with $iters iterations."
    return cachedgeneticbuildtree(surfac, p, n, pari)
end

vsw, nsw = readobj("wtr.obj", edgel);

#global_logger(RANSAC.nosource_debuglogger())
# test run
alls, bestt = testwtr(vsw, nsw, surfs, 2, maxdepth=10);

# real run
alls, bestt = testwtr(vsw, nsw, surfs, 200, maxdepth=10);

writeparaviewformat(besttr, "bestwtr", edgel)

tofile(D3Tree(alls[1]), "holedsphere.html")

println("fully finished")
