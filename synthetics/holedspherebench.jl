using StaticArrays
using AbstractTrees
using RANSAC
using GeometryTypes
using Logging
using Random
#using Revise
using CSGBuilding
const CSGB = CSGBuilding

cd(@__DIR__)

function makeit()
    sp = ImplicitSphere([0.0,0,0], 5)
    pl = ImplicitPlane([0.0,0,0], [0,1,0])
    cyl = ImplicitCylinder([0,0,1], [0,-2.5,0], 1.5)

    spn = CSGNode(sp, [])
    pln = CSGNode(pl, [])
    cyln = CSGNode(cyl, [])
    tr1 = CSGNode(CSGB.intersection, [spn, pln])
    tr = CSGNode(CSGB.subtraction, [tr1, cyln])
    return tr, [sp, pl, cyl]
end

@info "Number of threads: $(Base.Threads.nthreads())"

wtr, surfs = makeit();
edgel = (mincorner=-5, maxcorner=5, edgelength=110);

# writeparaviewformat(wtr, "wtr", edgel)

function testwtr1(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    @info "Genetic build tree with $iters iterations."
    Random.seed!(9876)
    return geneticbuildtree(surfac, p, n, pari)
end

function testwtr2(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    @info "Cached genetic build tree with $iters iterations."
    Random.seed!(9876)
    return cachedgeneticbuildtree(surfac, p, n, pari)
end

function testwtr3(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    @info "Cached genetic func build tree with $iters iterations."
    Random.seed!(9876)
    return cachedfuncgeneticbuildtree(surfac, p, n, pari)
end

vsw, nsw = readobj("wtr.obj", edgel);
@info "Cloud size: $(size(vsw))"

# benchmark run
#alls, bestt = testwtr1(vsw, nsw, surfs, 2);
alls, bestt = testwtr2(vsw, nsw, surfs, 32);
alls, bestt = testwtr3(vsw, nsw, surfs, 32);
println("This is the end")


#=
Result on work laptop:
C:\Users\cstamas\Documents\GIT\MasterThesis\synthetics>set JULIA_NUM_THREADS=4

C:\Users\cstamas\Documents\GIT\MasterThesis\synthetics>julia holedspherebench.jl
[ Info: Genetic build tree with 2 iterations.
[ Info: 1-th iteration
[ Info: 2-th iteration
[ Info: Finished: 2 iteration in 443.16 seconds.
[ Info: Cached genetic build tree with 50 iterations.
[ Info: Iteration in progress...
[ Info: 5-th iteration
[ Info: 10-th iteration
[ Info: 15-th iteration
[ Info: 20-th iteration
[ Info: 25-th iteration
[ Info: 30-th iteration
[ Info: 35-th iteration
[ Info: 40-th iteration
[ Info: 45-th iteration
[ Info: 50-th iteration
[ Info: Finished: 50 iteration in 4453.97 seconds.
[ Info: Cached genetic func build tree with 50 iterations.
[ Info: Iteration in progress...
[ Info: 5-th iteration
[ Info: 10-th iteration
[ Info: 15-th iteration
[ Info: 20-th iteration
[ Info: 25-th iteration
[ Info: 30-th iteration
[ Info: 35-th iteration
[ Info: 40-th iteration
[ Info: 45-th iteration
[ Info: 50-th iteration
[ Info: Finished: 50 iteration in 2523.42 seconds.
something useful

C:\Users\cstamas\Documents\GIT\MasterThesis\synthetics>

Emi compute

[ Info: Number of threads: 16
[ Info: Cloud size: (85180,)
[ Info: Cached genetic build tree with 32 iterations.
[ Info: Iteration in progress...
[ Info: 3-th iteration
[ Info: 6-th iteration
[ Info: 9-th iteration
[ Info: 12-th iteration
[ Info: 15-th iteration
[ Info: 18-th iteration
[ Info: 21-th iteration
[ Info: 24-th iteration
[ Info: 27-th iteration
[ Info: 30-th iteration
[ Info: Finished: 32 iteration in 1150.43 seconds.
[ Info: Cached genetic func build tree with 32 iterations.
[ Info: Iteration in progress...
[ Info: 3-th iteration
[ Info: 6-th iteration
[ Info: 9-th iteration
[ Info: 12-th iteration
[ Info: 15-th iteration
[ Info: 18-th iteration
[ Info: 21-th iteration
[ Info: 24-th iteration
[ Info: 27-th iteration
[ Info: 30-th iteration
[ Info: Finished: 32 iteration in 795.23 seconds.
This is the end
[ Info: Number of threads: 8
[ Info: Cloud size: (85180,)
[ Info: Cached genetic build tree with 32 iterations.
[ Info: Iteration in progress...
[ Info: 3-th iteration
[ Info: 6-th iteration
[ Info: 9-th iteration
[ Info: 12-th iteration
[ Info: 15-th iteration
[ Info: 18-th iteration
[ Info: 21-th iteration
[ Info: 24-th iteration
[ Info: 27-th iteration
[ Info: 30-th iteration
[ Info: Finished: 32 iteration in 1130.76 seconds.
[ Info: Cached genetic func build tree with 32 iterations.
[ Info: Iteration in progress...
[ Info: 3-th iteration
[ Info: 6-th iteration
[ Info: 9-th iteration
[ Info: 12-th iteration
[ Info: 15-th iteration
[ Info: 18-th iteration
[ Info: 21-th iteration
[ Info: 24-th iteration
[ Info: 27-th iteration
[ Info: 30-th iteration
[ Info: Finished: 32 iteration in 579.42 seconds.
This is the end
[ Info: Number of threads: 4
[ Info: Cloud size: (85180,)
[ Info: Cached genetic build tree with 32 iterations.
[ Info: Iteration in progress...
[ Info: 3-th iteration
[ Info: 6-th iteration
[ Info: 9-th iteration
[ Info: 12-th iteration
[ Info: 15-th iteration
[ Info: 18-th iteration
[ Info: 21-th iteration
[ Info: 24-th iteration
[ Info: 27-th iteration
[ Info: 30-th iteration
[ Info: Finished: 32 iteration in 2047.51 seconds.
[ Info: Cached genetic func build tree with 32 iterations.
[ Info: Iteration in progress...
[ Info: 3-th iteration
[ Info: 6-th iteration
[ Info: 9-th iteration
[ Info: 12-th iteration
[ Info: 15-th iteration
[ Info: 18-th iteration
[ Info: 21-th iteration
[ Info: 24-th iteration
[ Info: 27-th iteration
[ Info: 30-th iteration
[ Info: Finished: 32 iteration in 785.4 seconds.
This is the end
[ Info: Number of threads: 2
[ Info: Cloud size: (85180,)
[ Info: Cached genetic build tree with 32 iterations.
[ Info: Iteration in progress...
[ Info: 3-th iteration
[ Info: 6-th iteration
[ Info: 9-th iteration
[ Info: 12-th iteration
[ Info: 15-th iteration
[ Info: 18-th iteration
[ Info: 21-th iteration
[ Info: 24-th iteration
[ Info: 27-th iteration
[ Info: 30-th iteration
[ Info: Finished: 32 iteration in 2431.6 seconds.
[ Info: Cached genetic func build tree with 32 iterations.
[ Info: Iteration in progress...
[ Info: 3-th iteration
[ Info: 6-th iteration
[ Info: 9-th iteration
[ Info: 12-th iteration
[ Info: 15-th iteration
[ Info: 18-th iteration
[ Info: 21-th iteration
[ Info: 24-th iteration
[ Info: 27-th iteration
[ Info: 30-th iteration
[ Info: Finished: 32 iteration in 280.57 seconds.
This is the end
[ Info: Number of threads: 1
[ Info: Cloud size: (85180,)
[ Info: Cached genetic build tree with 32 iterations.
[ Info: Iteration in progress...
[ Info: 3-th iteration
[ Info: 6-th iteration
[ Info: 9-th iteration
[ Info: 12-th iteration
[ Info: 15-th iteration
[ Info: 18-th iteration
[ Info: 21-th iteration
[ Info: 24-th iteration
[ Info: 27-th iteration
[ Info: 30-th iteration
[ Info: Finished: 32 iteration in 1810.24 seconds.
[ Info: Cached genetic func build tree with 32 iterations.
[ Info: Iteration in progress...
[ Info: 3-th iteration
[ Info: 6-th iteration
[ Info: 9-th iteration
[ Info: 12-th iteration
[ Info: 15-th iteration
[ Info: 18-th iteration
[ Info: 21-th iteration
[ Info: 24-th iteration
[ Info: 27-th iteration
[ Info: 30-th iteration
[ Info: Finished: 32 iteration in 209.23 seconds.
This is the end

=#
