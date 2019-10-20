using StaticArrays
using AbstractTrees
using Random

using CSGBuilding
const CSGB = CSGBuilding
using RANSAC

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

vs2, ns2 = sampleunitcube(25);

p = CSGGeneticBuildParameters{Float64}(itermax=5);


# not cached
surfac = [pln1,pln2,pln3,pln4,pln5,pln6];
println("genetic build")
Random.seed!(1234);
result = geneticbuildtree(surfac, vs2, ns2, p);
println("genetic build finished")

# cached
felületek = [pl1, pl2, pl3, pl4, pl5, pl6];
println("cached genetic build")
Random.seed!(1234);
res = cachedgeneticbuildtree(felületek, vs2, ns2, p);
println("cached genetic build finished")

p = CSGGeneticBuildParameters{Float64}(itermax=20);
println("itermax set to 20")
println("threaded benching genetic build")
Random.seed!(1234);
@time geneticbuildtree(surfac, vs2, ns2, p);
println("finished benching genetic build")

println("threaded benching cached genetic build")
Random.seed!(1234);
@time cachedgeneticbuildtree(felületek, vs2, ns2, p);
println("finished benching cached genetic build")
