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
    sp = ImplicitSphere([0.0,0,0], 4.5)
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
edgel = (mincorner=-5, maxcorner=5, edgelength=110);

# writeparaviewformat(wtr, "wtr", edgel)

function testwtr(p, n, surfac, iters; kwargs...)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters; kwargs...)
    @info "cachedfuncgeneticbuildtree with $iters iterations."
    return cachedfuncgeneticbuildtree(surfac, p, n, pari)
end

vsw, nsw = readobj("wtr.obj", edgel);

#=
sc = plotimplshape(surfs[1])
plotimplshape!(sc, surfs[2], color=(:red, 0.2), scale = (10., 10.))
plotimplshape!(sc, surfs[3], color=(:green, 0.2), scale=10)
scatter!(sc, vsw[1:8:end])
=#

#global_logger(RANSAC.nosource_debuglogger())
# test run
alls, bestt = testwtr(vsw, nsw, surfs, 2, maxdepth=5);

# real run
alls, bestt = testwtr(vsw, nsw, surfs, 1100, maxdepth=5);

writeparaviewformat(bestt, "bestwtr", edgel)

tofile(D3Tree(alls[1]), "holedsphere.html")

println("fully finished")
