using StaticArrays
using AbstractTrees
using Random

using RANSAC
using Revise
using CSGBuilding
const CSGB = CSGBuilding
cd(@__DIR__)


n1 = SVector(1,0,0.0);
n2 = SVector(0,1,0.0);
n3 = SVector(0,0,1.0);


pl1 = ImplicitPlane(n1, n1)
pln1 = CSGNode(pl1, [])

pl2 = ImplicitPlane(n2, n2)
pln2 = CSGNode(pl2, [])

pl3 = ImplicitPlane(n3, n3)
pln3 = CSGNode(pl3, [])

pl4 = ImplicitPlane(-n1, -n1)
pln4 = CSGNode(pl4, [])

pl5 = ImplicitPlane(-n2, -n2)
pln5 = CSGNode(pl5, [])

pl6= ImplicitPlane(-n3, -n3)
pln6 = CSGNode(pl6, [])

tr1 = CSGNode(CSGBuilding.intersection, [pln1, pln2])
tr2 = CSGNode(CSGBuilding.intersection, [pln3, pln4])
tr3 = CSGNode(CSGBuilding.intersection, [tr1, tr2])
tr4 = CSGNode(CSGBuilding.intersection, [tr3, pln5])
tr5 = CSGNode(CSGBuilding.intersection, [tr4, pln6])

function sampleunitcube(ranges)
    # it's not a unit cube, but every coordinate is -1, 0 or 1
    l = (2,2)
    v1, n1 = sampleplanefromcorner([-1,-1,-1], [0,1,0], [1,0,0], l, (ranges,ranges))
    v2, n2 = sampleplanefromcorner([-1,-1,-1], [0,0,1], [0,1,0], l, (ranges,ranges))
    v3, n3 = sampleplanefromcorner([-1,-1,-1], [1,0,0], [0,0,1], l, (ranges,ranges))

    v4, n4 = sampleplanefromcorner([1,1,1], [-1,0,0], [0,-1,0], l, (ranges,ranges))
    v5, n5 = sampleplanefromcorner([1,1,1], [0,-1,0], [0,0,-1], l, (ranges,ranges))
    v6, n6 = sampleplanefromcorner([1,1,1], [0,0,-1], [-1,0,0], l, (ranges,ranges))

    return (vcat(v1,v2,v3,v4,v5,v6), vcat(n1,n2,n3,n4,n5,n6))
end

vs2, ns2 = sampleunitcube(50);


## cached-tree
felületek = [pl1, pl2, pl3, pl4, pl5, pl6]
pontok = [[0.,0,0], [1,1,1], [2,2,2]]

cnodes, cvals, cnorms = buildcache(felületek, pontok)

trc1 = CachedCSGNode(CSGBuilding.intersection, [cnodes[1], cnodes[2]])
trc2 = CachedCSGNode(CSGBuilding.intersection, [cnodes[3], cnodes[4]])
trc3 = CachedCSGNode(CSGBuilding.intersection, [trc1, trc2])
trc4 = CachedCSGNode(CSGBuilding.intersection, [trc3, cnodes[5]])
trc5 = CachedCSGNode(CSGBuilding.intersection, [trc4, cnodes[6]])
