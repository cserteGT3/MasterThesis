using StaticArrays
using AbstractTrees

using Revise
using CSGBuilding
cd(@__DIR__)

## Tree
v1 = SVector(0,0,0.0)

sf1 = ImplicitSphere(v1, 0.5)
sf2 = ImplicitSphere(v1, 1.0)

subnode1 = CSGNode(sf1, ())
subnode2 = CSGNode(sf2, ())


nd1 = CSGNode(CSGB.union, (subnode1, subnode2))

nd2 = CSGNode(CSGB.union, (nd1, CSGNode(CSGB.complement, (subnode1, ))))

nd3 = CSGNode(CSGB.subtraction, (nd1, CSGNode(CSGB.complement, (subnode1, ))))

nd4 = CSGNode(CSGB.subtraction, (subnode1, subnode2))

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
n1 = CSGNode(CSGB.union, (subnode1, subnode2))
n2 = CSGNode(CSGB.union, (n1, CSGNode(CSGB.complement, (subnode1, ))))
n3 = CSGNode(CSGB.subtraction, (n1, CSGNode(CSGB.complement, (subnode1, ))))

print_tree(n1)
evaluate(n1, v1)

collect(StatelessBFS(n2))

## Write to paraview
sf0 = ImplicitSphere(SVector(0,0,0), 5)
nd0 = CSGNode(sf0, ())

writeparaviewformat(sf0, "sphere5", (-10, 10, 100))

sf01 = ImplicitSphere(SVector(2.5,2.5,2.5), 5.)
nd01 = CSGNode(sf01, ())
compnd01 = CSGNode(CSGB.complement, (nd01, ))
tree01 = CSGNode(CSGB.union, (nd0, compnd01))
tree01 = CSGNode(CSGB.subtraction, (nd0, nd01))

writeparaviewformat(tree01, "sphere5", (-10, 10, 100))


## Cylinder

cyn =  ImplicitCylinder(SVector(0,0,1), SVector(0,0,0),1)
writeparaviewformat(CSGNode(cyn, ()), "cyn", (-10, 10, 100))

evaluate(cyn, SVector(-1,0,10))

p = [0,0,0];
d = [0,0,1];
q = [1,0,1];

CSGB.vectorfromline(p, d, [1,0,0])
