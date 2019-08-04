using Pkg
Pkg.activate("RANSACBenchmark")


using Revise
includet("RANSACBenchmark.jl")
using .RANSACBenchmark

using Dates

using BenchmarkTools
using DataFrames

mb = @benchmark(sin.([1.0, 0.0]))
bmka = makedf(mb)
