using StaticArrays
using AbstractTrees

using Revise
using CSGBuilding

## Tree
v1 = SVector(0,0,0.0)

sf1 = ImplicitSphere(v1, 0.5)
sf2 = ImplicitSphere(v1, 1.0)

subnode1 = CSGNode(sf1, ())
subnode2 = CSGNode(sf2, ())


n1 = CSGNode(CSGBuilding.union, (subnode1, subnode2))

n2 = CSGNode(CSGBuilding.union, (n1, CSGNode(CSGBuilding.complement, (subnode1, ))))

n3 = CSGNode(CSGBuilding.subtraction, (n1, CSGNode(CSGBuilding.complement, (subnode1, ))))

n4 = CSGNode(CSGBuilding.subtraction, (subnode1, subnode2))
