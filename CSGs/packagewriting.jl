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

## Demo
using StaticArrays, AbstractTrees, CSGBuilding
const v0 = SVector(0.0,0,0);
const v01 = SVector(1.0,0,0);

# surfaces
sf1 = ImplicitSphere(v1, 0.5)
sf2 = ImplicitSphere(v1, 1.0)
# csg nodes
subnode1 = CSGNode(sf1, ())
subnode2 = CSGNode(sf2, ())

# trees
n1 = CSGNode(CSGBuilding.union, (subnode1, subnode2))
n2 = CSGNode(CSGBuilding.union, (n1, CSGNode(CSGBuilding.complement, (subnode1, ))))
n3 = CSGNode(CSGBuilding.subtraction, (n1, CSGNode(CSGBuilding.complement, (subnode1, ))))

print_tree(n1)
evaluate(n1, v1)

collect(StatelessBFS(n2))

## Write to paraview
sf0 = ImplicitSphere(SVector(0,0,0), 5)
nd0 = CSGNode(sf0, ())

writeparaviewformat(sf0, "sphere5", (-10, 10, 100))

sf01 = ImplicitSphere(SVector(2.5,2.5,2.5), 5.)
nd01 = CSGNode(sf01, ())
compnd01 = CSGNode(CSGBuilding.complement, (nd01, ))
tree01 = CSGNode(CSGBuilding.union, (nd0, compnd01))
tree01 = CSGNode(CSGBuilding.subtraction, (nd0, nd01))

writeparaviewformat(tree01, "sphere5", (-10, 10, 100))
