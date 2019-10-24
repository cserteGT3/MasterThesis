using StaticArrays
using AbstractTrees
using RANSAC
using GeometryTypes
using Logging
#using Revise
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

wtr, surfs = makeit();
edgel = (mincorner=-5, maxcorner=5, edgelength=150);

# writeparaviewformat(wtr, "wtr", edgel)

function testwtr1(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    @info "Genetic build tree with $iters iterations."
    return geneticbuildtree(surfac, p, n, pari)
end

function testwtr2(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    @info "Cached genetic build tree with $iters iterations."
    return cachedgeneticbuildtree(surfac, p, n, pari)
end

function testwtr3(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    @info "Cached genetic func build tree with $iters iterations."
    return cachedfuncgeneticbuildtree(surfac, p, n, pari)
end

vsw, nsw = readobj("wtr.obj", edgel);
size(vsw)

# test run
alls, bestt = testwtr1(vsw, nsw, surfs, 10);
vsw, nsw = readobj("wtr.obj", edgel);
alls, bestt = testwtr2(vsw, nsw, surfs, 100);
vsw, nsw = readobj("wtr.obj", edgel);
alls, bestt = testwtr3(vsw, nsw, surfs, 100);
println("something useful")
# real run
#alls, bestt = testwtr(vsw, nsw, surfs, 3000);

#writeparaviewformat(bestt, "bestwtr", edgel)
