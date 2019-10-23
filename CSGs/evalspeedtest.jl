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
    es = [code2func(tree2code(r)) for r in rcs_]
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
    es = [code2func(tree2code(r)) for r in rcs_]
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
        f = code2func(tree2code(rcs_[i]))
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
        f = c2f(tree2code(rcs_[i]))
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
