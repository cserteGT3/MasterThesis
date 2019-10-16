using StaticArrays
using AbstractTrees

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
print_tree(tr5)

writeparaviewformat(tr5, "plan1", (-5, 5, 100))
