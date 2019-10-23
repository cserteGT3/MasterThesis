using StaticArrays
using AbstractTrees

using Revise
using CSGBuilding
const CSGB = CSGBuilding
cd(@__DIR__)

## Tree
v1 = SVector(0,0,0.0)

sf1 = ImplicitSphere(v1, 0.5)
sf2 = ImplicitSphere(v1, 1.0)

subnode1 = CSGNode(sf1, [])
subnode2 = CSGNode(sf2, [])


nd1 = CSGNode(CSGB.union, [subnode1, subnode2])

nd2 = CSGNode(CSGB.union, [nd1, CSGNode(CSGB.complement, [subnode1])])

nd3 = CSGNode(CSGB.subtraction, [deepcopy(nd1), CSGNode(CSGB.complement, [subnode1])])

nd4 = CSGNode(CSGB.subtraction, [subnode1, subnode2])

## Demo
using StaticArrays, AbstractTrees, CSGBuilding
const v0 = SVector(0.0,0,0);
const v01 = SVector(1.0,0,0);

# surfaces
sf1 = ImplicitSphere(v1, 0.5)
sf2 = ImplicitSphere(v1, 1.0)
# csg nodes
subnode1 = CSGNode(sf1, [])
subnode2 = CSGNode(sf2, [])

# trees
n1 = CSGNode(CSGB.union, [subnode1, subnode2])
n2 = CSGNode(CSGB.union, [n1, CSGNode(CSGB.complement, [subnode1])])
n3 = CSGNode(CSGB.subtraction, [n1, CSGNode(CSGB.complement, [subnode1])])

print_tree(n1)
evaluate(n1, v1)

collect(StatelessBFS(n2))

## Write to paraview
sf0 = ImplicitSphere(SVector(0,0,0), 5)
nd0 = CSGNode(sf0, [])

writeparaviewformat(sf0, "sphere5", (-10, 10, 100))

sf01 = ImplicitSphere(SVector(2.5,2.5,2.5), 5.)
nd01 = CSGNode(sf01, [])
compnd01 = CSGNode(CSGB.complement, [nd01])
tree01 = CSGNode(CSGB.union, [nd0, compnd01])
tree01 = CSGNode(CSGB.subtraction, [nd0, nd01])

writeparaviewformat(tree01, "sphere5", (-10, 10, 100))


## Cylinder

cyn =  ImplicitCylinder(SVector(0,0,1), SVector(0,0,0),1)
writeparaviewformat(CSGNode(cyn, []), "cyn", (-10, 10, 100))

evaluate(cyn, SVector(-1,0,10))

p = [0,0,0];
d = [0,0,1];
q = [1,0,1];

CSGB.vectorfromline(p, d, [1,0,0])


## Random trees
n1 = SVector(1,0,0.0);
n2 = SVector(0,1,0.0);
n3 = SVector(0,0,1.0);
v1 = SVector(0,0,0.0);

cyn = ImplicitCylinder(SVector(0,0,1), SVector(0,0,0),1)
sf1 = ImplicitSphere(v1, 0.5)
sf2 = ImplicitSphere(v1, 1.0)
pl1 = ImplicitPlane(n1, n1)
pl2 = ImplicitPlane(n2, n2)
pl3 = ImplicitPlane(n3, n3)
pl4 = ImplicitPlane(-n1, -n1)
pl5 = ImplicitPlane(-n2, -n2)
pl6= ImplicitPlane(-n3, -n3)

surfac = [cyn, sf1, sf2, pl1, pl2, pl3, pl4, pl5, pl6]

tr = randomtree(surfac, 10)

## Crossover

nd1 = CSGNode(CSGB.union, [subnode1, subnode2])

nd2 = CSGNode(CSGB.union, [nd1, CSGNode(CSGB.complement, [subnode1])])

nd31 = CSGNode(CSGB.subtraction, [subnode1, subnode2])
nd3 = CSGNode(CSGB.subtraction, [nd31, CSGNode(CSGB.complement, [subnode1])])

ansi = crossover(news, p);

## syntax tree

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
    mpl = ImplicitPlane([4,4,0.25], -n3)
    cyl = ImplicitCylinder([0,0,1], [0,0,0], .25)
    return [pl1, pl2, pl3, pl4, pl5, pl6, cyl, mpl]
end

surfac = makeit()
pontok = [[0.,0,0], [1,1,1], [2,2,2]]
cnodes, cvals, cnorms = cachenodes(surfac, pontok)


mutable struct CodeWrap
    Core::Array{Expr,1}
    Params::Array{Symbol,1}
end

tr = Expr(:call, CSGB.union, surfac[1], surfac[2])

eval1 = Expr(:call, evaluate, cnodes[1], pontok, 1)

function to_code(surfac::CachedSurface)
    cvals_ = gensym()
    ind_ = gensym()
    a = Expr(:call, evaluate, surfac, cvals_, ind_)
    CodeWrap([a], [cvals_, ind_])
end

function func(cwrap)
    expr = Expr(:function,
        Expr(:tuple,
        cwrap.Params[1],
        cwrap.Params[2]),
        Expr(:block,cwrap.Core...))
    eval(expr), expr
end

code1 = to_code(cnodes[1])
code2 = to_code(cnodes[2])

f1, funcode = func(code1)
f1(cvals, 1)


codeun = :(:call, CSGB.union, $code1, $code2)

function func2(expr)



end


z = to_code(
    SUnion(
    (Trans(Sphere(5*sqrt(2),4),space(0.0,-10.0,0.0)),
    Trans(Ball(5*sqrt(2),5,1),space(0.0,5.0,8.66)),
    Trans(Ball(5*sqrt(2),6,0.5),space(0.0,5.0,-8.66)),
    Plane(space(1.0,0.0,0.0),2),
    RepQ(Trans(Ball(0.5,1,3.5),space(2.5,2.5,2.5)),5.0),
    Trans(Ball(5,3,2.5),space(0.0,0.0,0.0)))
    ))
