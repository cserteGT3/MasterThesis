module RANSACBenchmark

using Dates
using Logging
using Random

using PkgBenchmark
using BenchmarkTools
using DataFrames
using CSV
using PropertyFiles
using PrettyTables

#using RANSAC: nosource_debuglogger, nosource_infologger

export runbenchmark, loadbenchmarks, savebenchmark
export printresult
export printresult, saveresult
export info
export printload

const table_header = ["date" "commit sha" "minimum time" "median time" "mean time" "maximum time" "allocs" "memory" "system"; "" "" "[s]" "[s]" "[s]" "[s]" "" "[MiB]" ""]
const md_table_header = ["date" "commit sha" "minimum time [s]" "median time [s]" "mean time [s]" "maximum time [s]" "allocs" "memory [MiB]" "system"]
const nums = :r
const table_align = [:l, :l, nums, nums, nums, nums, nums, nums, :l]

#######################
# manual benchmarking #
#######################


"""
    runbenchmark(show = true)

Run benchmark.
"""
function runbenchmark(show = true; showdebug = false)
    #glb = global_logger()
    #showdebug ? global_logger(nosource_debuglogger()) : global_logger(nosource_infologger())

	bmi_ = benchmarkpkg("RANSAC")

    bmi = bmi_.benchmarkgroup.data["RANSAC"]["smallideal"]
	benched = makedf(bmi)

    show && display(bmi)
    #global_logger(glb)
    benched, bmi
end

function makedf(bmresult)
	#TODO: melyik mappában?
	comsha = read(`git log -n 1 --pretty=format:"%H"`, String)
	#comsha = "TODOOOOOOOOOOOOOOOOOOOO"

    pc = getpc()
    mint = BenchmarkTools.minimum(bmresult).time
    maxt = BenchmarkTools.maximum(bmresult).time
    meant = BenchmarkTools.mean(bmresult).time
    mediant = BenchmarkTools.median(bmresult).time

	df = DataFrame()
	df.date = [Dates.now()]
	df.commitsha = [comsha]
	df.minimumtime = [mint]
	df.mediantime = [mediant]
	df.meantime = [meant]
	df.maximumtime = [maxt]
	df.allocated = [allocs(bmresult)]
	df.memory = [memory(bmresult)/1024]
	df.system = [pc]
	return df
end

function getpc()
    if Sys.iswindows()
        username = ENV["UserName"]
        if username == "cstamas"
            return "WorkLaptop"
        elseif username == "Ipse"
            return "HomeLaptop"
		elseif username == "Laci"
            return "HomePC"
        else
            return "unknownWin"
        end
    elseif Sys.islinux()
		if ENV["USER"] == "ubuntu"
        	return "sandbox"
		else
			return "unknownLinux"
		end
    else
		return "Apple. Really?!"
	end
end

function newfolderproperties(prop, key, message)
	println(message)
	dstr = readline()
	if isdir(dstr)
		setprop(prop, key, dstr)
	else
		println(dstr, " is not an existing directory. Nothing will change.")
	end
	nothing
end

function nicify(df)
    divisor = 1_000_000_000 # nanosec to sec
    ndf = copy(df)
    ndf.commitsha = [rr.commitsha[1:7] for rr in eachrow(df)]
    ndf.minimumtime = df.minimumtime./divisor
    ndf.mediantime = df.mediantime./divisor
    ndf.meantime = df.meantime./divisor
    ndf.maximumtime = df.maximumtime./divisor
    ndf.memory = df.memory./1024  # KiB to MiB
    ndf
end

function tablify(df)
    [df.date df.commitsha df.minimumtime df.mediantime df.meantime df.maximumtime df.allocated df.memory df.system]
end

function printresult(tb)
    hmnice = tablify(nicify(tb))
    tf = PrettyTableFormat(unicode)
    pretty_table(hmnice, table_header, tf, alignment = table_align, formatter=ft_round(3, [3,4,5,6,8]))
end

function saveresult(tb)
    hmnice = tablify(nicify(tb))
    tf = PrettyTableFormat(markdown)
    fname = "benchmark_results.md"
    open(fname, "w") do io
        pretty_table(io, hmnice, md_table_header, tf, alignment = table_align, formatter=ft_round(3, [3,4,5,6,8]))
    end
    @info "File saved."
end

function savebenchmark(bm, fname = "benchmark_results.csv")
    if !isfile(fname)
        CSV.write(fname, bm )
    else
        CSV.write(fname, bm, append = true)
    end
    @info "File saved."
end

function loadbenchmarks(fname = "benchmark_results.csv")
    return CSV.read(fname)
end

function printload()
	printresult(loadbenchmarks())
end

function info()
    @info "Runnnig one benchmark takes around 5 minutes."
    @info "`bmark, benched = runbenchmark();` to run the benchmark (and also display it)."
    @info "`savebenchmark(bmark)` to append the last benchmark to the CSV file."
    @info "`bm = loadbenchmarks();` to load the saved benchmarks."
    @info "`printresult(bmark)` to show the result of one or more benchmarks."
    @info "`saveresult(bmark)` to save the prettyprint to markdown. This will overwrite the file."
end

##################
# CI like things #
##################
end # module

using .RANSACBenchmark
info()
