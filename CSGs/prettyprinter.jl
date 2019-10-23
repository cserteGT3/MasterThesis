using PrettyTables
using BenchmarkTools
using Logging
const tdict = Dict(:μs=>1000, :ms=>1000000, :s=>1000000000);
const mdict = Dict(:KiB=>1024, :MiB=>1024*1024, :GiB=>1024*1024*1024);

function evalBs(B, timeres=:ms, memres=:KiB)
    result = Array{Float64}(undef,size(B,1),7)
	rest = tdict[timeres]
	memr = mdict[memres]
    for i in eachindex(B)
        result[i,:] = [i, minimum(B[i]).time/rest, BenchmarkTools.median(B[i]).time/rest, BenchmarkTools.mean(B[i]).time/rest, BenchmarkTools.maximum(B[i]).time/rest, allocs(B[i]), memory(B[i])/(memr)]
    end
    return result
end

function prettyprint(benchArr, timeres=:ms, memres=:KiB)
	headTab = ["parse" "minimum time" "median time" "mean time" "maximum time" "allocs" "memory"; "" "TIME" "TIME" "TIME" "TIME" "" String(memres)]
	ht = replace(headTab, "TIME"=>String(timeres))
	pretty_table(evalBs(benchArr, timeres, memres), ht, formatter=ft_round(3))
end
@info "Use prettyprint(benchArr) to print the results."
