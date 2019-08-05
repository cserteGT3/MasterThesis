using Revise
includet("RANSACBenchmark.jl")
using .RANSACBenchmark

using Dates

using BenchmarkTools
using DataFrames

mb = @benchmark(sin.([1.0, 0.0]))
bmka = makedf(mb)
using PropertyFiles

p = Properties()

setprop(p, "key", "val")
const p2 = Properties()
setprop(p2, "ke", "ka")

pre_cd = pwd()

tdir = abspath(joinpath(pwd(), "RANSACBenchmark"))
isdir(tdir)
cd(tdir)
cd(pre_cd)

rshas = read(`git log -n 10 --pretty=format:"%H"`, String)
splitted = split(rshas, "\n")
ns = findfirst(x->x == "146e2f39a79b252cce4cafe28b139339bee35c27", splitted)
deleteat!(splitted, ns:length(splitted))


Dates.format(Dates.now(), DateFormat("Y-mm-ddTH-M-S.s"))
