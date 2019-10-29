using StaticArrays
using AbstractTrees
using RANSAC
using Logging
using D3Trees
using Revise
using CSGBuilding
const CSGB = CSGBuilding

cd(@__DIR__)

function makeit()
    n1 = SVector(1,0,0.0);
    n2 = SVector(0,1,0.0);
    n3 = SVector(0,0,1.0);

    pl1 = ImplicitPlane(n1, n1)
    pl2 = ImplicitPlane(n2, n2)
    pl3 = ImplicitPlane(n3, n3)
    pl4 = ImplicitPlane(-n1, -n1)
    pl5 = ImplicitPlane(-n2, -n2)
    pl6= ImplicitPlane(-n3, -n3)

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

    mpl = ImplicitPlane([4,4,0.25], -n3)
    midpl = CSGNode(mpl, [])

    cyl = ImplicitCylinder([0,0,1], [0,0,0], .25)
    cyln = CSGNode(cyl, [])

    cyld = CSGNode(CSGB.intersection, [midpl, cyln])

    tr = CSGNode(CSGB.subtraction, [tr5, cyld])
    return tr, [pl1, pl2, pl3, pl4, pl5, pl6, cyl, mpl]
end

hcube, surfs = makeit();

edgel = (mincorner=-2, maxcorner=2, edgelength=110);

#writeparaviewformat(hcube, "hcube", edgel)

function testwtr(p, n, surfac, iters; kwargs...)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters; kwargs...)
    return cachedfuncgeneticbuildtree(surfac, p, n, pari)
end

vhc, nhc = readobj("hcube.obj", edgel);

# test run
alls, bestt = testwtr(vhc, nhc, surfs, 2);

global_logger(RANSAC.nosource_debuglogger())
# real run
alls, bestt = testwtr(vhc, nhc, surfs, 3500);
# write to be able to check
writeparaviewformat(bestt, "besthcube", edgel)

tofile(D3Tree(alls[1]), "holedcube.html")

println("fully finished")
