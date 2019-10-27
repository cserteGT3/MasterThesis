using StaticArrays
using AbstractTrees
using RANSAC
using GeometryTypes
using Logging
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
edgel = (mincorner=-5, maxcorner=5, edgelength=150);

# writeparaviewformat(wtr, "wtr", edgel)

function testwtr1(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    @info "Genetic build tree with $iters iterations."
    return geneticbuildtree(surfac, p, n, pari)
end

function testwtr2(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    @info "Cached genetic build tree with $iters iterations."
    return cachedgeneticbuildtree(surfac, p, n, pari)
end

function testwtr3(p, n, surfac, iters)
    pari = CSGGeneticBuildParameters{Float64}(itermax=iters)
    @info "Cached genetic func build tree with $iters iterations."
    return cachedfuncgeneticbuildtree(surfac, p, n, pari)
end

vsw, nsw = readobj("wtr.obj", edgel);
@info "Cloud size: $(size(vsw))"

# test run
#alls, bestt = testwtr1(vsw, nsw, surfs, 2);
vsw, nsw = readobj("wtr.obj", edgel);
alls, bestt = testwtr2(vsw, nsw, surfs, 20);
vsw, nsw = readobj("wtr.obj", edgel);
alls, bestt = testwtr3(vsw, nsw, surfs, 20);
println("something useful")
# real run
#alls, bestt = testwtr(vsw, nsw, surfs, 3000);

#writeparaviewformat(bestt, "bestwtr", edgel)


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


=#
