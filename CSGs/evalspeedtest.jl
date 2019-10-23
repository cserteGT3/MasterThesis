using StaticArrays
using AbstractTrees
using Random
using BenchmarkTools
using Revise
using CSGBuilding
const CSGB = CSGBuilding
cd(@__DIR__)
include("prettyprinter.jl")

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

function b1(surfaces, rpoints, treenum=10, treedepth=10)
    nodes = [CSGNode(n, []) for n in surfaces];
    Random.seed!(1234);
    rs = [randomtree(nodes, treedepth) for i in 1:treenum]
    sp = 0.
    for i in eachindex(rs)
        for j in eachindex(rpoints)
            sp += value(evaluate(rs[i], rpoints[j]))
        end
    end
    return sp
end

function b2(surfaces, rpoints, treenum=10, treedepth=10)
    cnodes, cvals, _ = cachenodes(surfaces, rpoints);
    Random.seed!(1234);
    rcs_ = [randomcachedtree(cnodes, treedepth) for i in 1:treenum]
    sp = 0.
    for i in eachindex(rcs_)
        for j in eachindex(cvals)
            sp += value(evaluate(rcs_[i], cvals, j))
        end
    end
    return sp
end

function b3(surfaces, rpoints, treenum=10, treedepth=10)
    cnodes, cvals, _ = cachenodes(surfaces, rpoints);
    Random.seed!(1234);
    rcs_ = [randomcachedtree(cnodes, treedepth) for i in 1:treenum]
    sp = 0.
    es = [CSGB.code2func(CSGB.tree2code(r)) for r in rcs_]
    for i in eachindex(es)
        f = es[i]
        for j in eachindex(cvals)
            sp += value(Base.invokelatest(f, cvals, j))
        end
    end
    return sp
end

function b4(surfaces, rpoints, treenum=10, treedepth=10)
    cnodes, cvals, _ = cachenodes(surfaces, rpoints);
    Random.seed!(1234);
    rcs_ = [randomcachedtree(cnodes, treedepth) for i in 1:treenum]
    sp = 0.
    es = [CSGB.code2func(CSGB.tree2code(r)) for r in rcs_]
    for i in eachindex(es)
        f = es[i]
        for j in eachindex(cvals)
            sp += value(Base.invokelatest(f, cvals, j)::CachedResult)
        end
    end
    return sp
end

function b5(surfaces, rpoints, treenum=10, treedepth=10)
    cnodes, cvals, _ = cachenodes(surfaces, rpoints);
    Random.seed!(1234);
    rcs_ = [randomcachedtree(cnodes, treedepth) for i in 1:treenum]
    sp = 0.
    for i in eachindex(rcs_)
        f = CSGB.code2func(CSGB.tree2code(rcs_[i]))
        for j in eachindex(cvals)
            ev = Base.invokelatest(f, cvals, j)::CachedResult
            sp += value(ev)
        end
    end
    return sp
end

function c2f(cwrap)
    expr = Expr(:function,
        Expr(:tuple,
        cwrap.Params[1],
        cwrap.Params[2]),
        Expr(:block,cwrap.Core...))
    return eval(expr)
end

function b6(surfaces, rpoints, treenum=10, treedepth=10)
    cnodes, cvals, _ = cachenodes(surfaces, rpoints);
    Random.seed!(1234);
    rcs_ = [randomcachedtree(cnodes, treedepth) for i in 1:treenum]
    sp = 0.
    for i in eachindex(rcs_)
        f = c2f(CSGB.tree2code(rcs_[i]))
        for j in eachindex(cvals)
            ev = Base.invokelatest(f, cvals, j)::CachedResult
            sp += value(ev)
        end
    end
    return sp
end

function b7(surfaces, rpoints, treenum=10, treedepth=10)
    cnodes, cvals, _ = cachenodes(surfaces, rpoints);
    Random.seed!(1234);
    rcs_ = [randomcachedtree(cnodes, treedepth) for i in 1:treenum]
    sp = 0.
    for i in eachindex(rcs_)
        f = tree2func(rcs_[i])
        for j in eachindex(cvals)
            ev = Base.invokelatest(f, cvals, j)::CachedResult
            sp += value(ev)
        end
    end
    return sp
end

function b8(surfaces, rpoints, treenum=10, treedepth=10)
    cnodes, cvals, _ = cachenodes(surfaces, rpoints);
    Random.seed!(1234);
    rcs_ = [randomcachedtree(cnodes, treedepth) for i in 1:treenum]
    sp = 0.
    es = [tree2func(r) for r in rcs_]
    for i in eachindex(es)
        f = es[i]
        for j in eachindex(cvals)
            sp += value(Base.invokelatest(f, cvals, j)::CachedResult)
        end
    end
    return sp
end

function b9(surfaces, rpoints, treenum=10, treedepth=10)
    cnodes, cvals, _ = cachenodes(surfaces, rpoints);
    Random.seed!(1234);
    rcs_ = [randomcachedtree(cnodes, treedepth) for i in 1:treenum]
    sp = 0.
    es = [tree2func(r) for r in rcs_]
    for i in eachindex(es)
        f = es[i]
        for j in eachindex(cvals)
            ev = Base.invokelatest(f, cvals, j)::CachedResult
            sp += value(ev)
        end
    end
    return sp
end

surfac = makeit();
Random.seed!(1234)
points = [rand(3) for i in 1:100000];

evaltupl = (surfac, points, 30, 10)

b1(evaltupl...)
b2(evaltupl...)
b3(evaltupl...)
b4(evaltupl...)
b5(evaltupl...)
b6(evaltupl...)
b7(evaltupl...)
b8(evaltupl...)
b9(evaltupl...)

res1 = @benchmark b1($evaltupl...)
res2 = @benchmark b2($evaltupl...)
res3 = @benchmark b3($evaltupl...)
res4 = @benchmark b4($evaltupl...)
res5 = @benchmark b5($evaltupl...)
res6 = @benchmark b6($evaltupl...)
res7 = @benchmark b7($evaltupl...)
res8 = @benchmark b8($evaltupl...)
res9 = @benchmark b9($evaltupl...)

bm = [res1, res2, res3, res4, res5, res6, res7, res8, res9];
prettyprint(bm, :ms, :KiB)

#=
points = [rand(3) for i in 1:10000];
evaltupl = (surfac, points, 30, 10)
┌───────┬──────────────┬─────────────┬───────────┬──────────────┬─────────────┬────────┐
│ parse │ minimum time │ median time │ mean time │ maximum time │      allocs │ memory │
│       │            s │           s │         s │            s │             │    GiB │
├───────┼──────────────┼─────────────┼───────────┼──────────────┼─────────────┼────────┤
│   1.0 │        4.077 │       4.162 │     4.162 │        4.248 │ 2.7851485e7 │  0.762 │
│   2.0 │         1.46 │        1.48 │     1.479 │        1.497 │ 2.8364701e7 │  0.731 │
│   3.0 │        2.049 │       2.092 │     2.082 │        2.105 │  4.620365e6 │  0.179 │
│   4.0 │        2.058 │       2.074 │     2.074 │        2.089 │  4.020364e6 │   0.17 │
│   6.0 │        2.062 │       2.064 │     2.074 │        2.095 │  3.874972e6 │  0.163 │
│   7.0 │        2.016 │        2.03 │     2.051 │        2.108 │  3.874968e6 │  0.163 │
│   8.0 │        2.164 │       2.247 │     2.258 │        2.362 │    4.0203e6 │   0.17 │
│   9.0 │        2.217 │       2.332 │     2.347 │        2.492 │    4.0203e6 │   0.17 │
└───────┴──────────────┴─────────────┴───────────┴──────────────┴─────────────┴────────┘
┌───────┬──────────────┬─────────────┬───────────┬──────────────┬─────────────┬────────────┐
│ parse │ minimum time │ median time │ mean time │ maximum time │      allocs │     memory │
│       │           ms │          ms │        ms │           ms │             │        KiB │
├───────┼──────────────┼─────────────┼───────────┼──────────────┼─────────────┼────────────┤
│   1.0 │      4077.03 │     4162.44 │   4162.44 │      4247.85 │ 2.7851485e7 │ 798999.281 │
│   2.0 │     1460.106 │    1480.432 │  1479.431 │     1496.753 │ 2.8364701e7 │ 766863.047 │
│   3.0 │     2049.275 │    2091.997 │  2082.078 │      2104.96 │  4.620365e6 │ 187828.959 │
│   4.0 │     2058.043 │    2074.288 │  2073.879 │     2089.304 │  4.020364e6 │ 178453.821 │
│   5.0 │     2051.798 │    2082.938 │   2133.52 │     2265.823 │  3.874968e6 │ 170764.343 │
│   6.0 │     2061.998 │    2064.287 │  2073.885 │     2095.371 │  3.874972e6 │ 170768.396 │
│   7.0 │     2015.956 │    2029.922 │  2051.206 │     2107.738 │  3.874968e6 │ 170764.343 │
│   8.0 │     2163.749 │    2246.557 │  2257.594 │     2362.476 │    4.0203e6 │ 178451.083 │
│   9.0 │     2217.413 │    2331.571 │  2346.892 │     2491.693 │    4.0203e6 │ 178451.083 │
└───────┴──────────────┴─────────────┴───────────┴──────────────┴─────────────┴────────────┘
=#
