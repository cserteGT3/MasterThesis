using PrettyTables
using BenchmarkTools
using Logging
const tdict = Dict(:μs=>1000, :ms=>1000000, :s=>1000000000);

function evalBs(B, timeres=:ms)
    result = Array{Float64}(undef,size(B,1),7)
	rest = tdict[timeres]

    for i in eachindex(B)
        result[i,:] = [i, minimum(B[i]).time/rest, BenchmarkTools.median(B[i]).time/rest, BenchmarkTools.mean(B[i]).time/rest, BenchmarkTools.maximum(B[i]).time/rest, allocs(B[i]), memory(B[i])/1024]
    end
    return result
end

function prettyprint(benchArr, timeres=:ms)
	headTab = ["parse" "minimum time" "median time" "mean time" "maximum time" "allocs" "memory"; "" "TIME" "TIME" "TIME" "TIME" "" "KiB"]
	ht = replace(headTab, "TIME"=>String(timeres))
	pretty_table(evalBs(benchArr, timeres), ht, formatter=ft_round(3))
end
@info "Use prettyprint(benchArr) to print the results."
