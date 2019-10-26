using StaticArrays
using AbstractTrees
using CSGBuilding
using RANSAC
using D3Trees

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

function testwtr(p, n, surfac, iters; kwargs...)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters; kwargs...)
    @info "cachedgeneticbuildtree with $iters iterations."
    return cachedgeneticbuildtree(surfac, p, n, pari)
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
    surface = [pl1, pl2, pl3, pl4, pl5, pl6]

    vs2, ns2 = sampleunitcube(cubesize)


    testwtr(vs2, ns2, surface, 2)
    return testwtr(vs2, ns2, surface, iterations)
end

alls, bestt = test(3000, 50);

edgel = (mincorner=-7, maxcorner=7, edgelength=150);

writeparaviewformat(bestt, "bestcube", edgel)

tofile(D3Tree(alls[1]), "csgcube.html")

println("fully finished")
