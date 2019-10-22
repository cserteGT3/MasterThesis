using StaticArrays
using AbstractTrees
using CSGBuilding
using RANSAC

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

function test(iterations, cubesize)
    n1 = SVector(1,0,0.0);
    n2 = SVector(0,1,0.0);
    n3 = SVector(0,0,1.0);

    pl1 = ImplicitPlane(n1, n1)
    pl2 = ImplicitPlane(n2, n2)
    pl3 = ImplicitPlane(n3, n3)
    pl4 = ImplicitPlane(-n1, -n1)
    pl5 = ImplicitPlane(-n2, -n2)
    pl6= ImplicitPlane(-n3, -n3)
    surfac = [pl1, pl2, pl3, pl4, pl5, pl6]

    vs2, ns2 = sampleunitcube(cubesize)
    p = CSGGeneticBuildParameters{Float64}(itermax=iterations)
    return cachedgeneticbuildtree(surfac, vs2, ns2, p)
end