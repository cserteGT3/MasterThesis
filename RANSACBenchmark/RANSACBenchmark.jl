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
using JuDoc

#using RANSAC: nosource_debuglogger, nosource_infologger

export runbenchmark, loadbenchmarks, savebenchmark
export printresult, saveresult
export info
export printload
export resetcommitsha, setpropfile, lastbenchmarkedcommit!

export callmeCI

const table_header = ["benchmark date" "commit date" "commit sha" "minimum time" "median time" "mean time" "maximum time" "allocs" "memory" "benchmark v." "system" "julia v.";
 						"" "" "" "[s]" "[s]" "[s]" "[s]" "" "[MiB]" "" "" ""]
const md_table_header = ["benchmark date" "commit date" "commit sha" "minimum time [s]" "median time [s]" "mean time [s]" "maximum time [s]" "allocs" "memory [MiB]" "benchmark v." "system" "julia v."]
const nums = :r
const table_align = [:l, :l, :l, nums, nums, nums, nums, nums, nums, :l, :l, :l]

const RPropsfile = "ransacbenchmarkprops.jlprop"
const commitkey = "lastbenchmarkedcommit"

const BENCHMARK_VERSION = v"1.1.0"

"""First commit where it's possible to benchmark."""
const FIRST_COMMIT = "fe1fefceed88508b08dc26fc4835e95ab367e12a"

"""This should be used as last benchmarked commit sha for benchmarking every possible commit."""
const LAST_BENCHMARKED = "ca6a8548cb5b746dbbeb6208f4e2a55c7ab8e0dc"

#######################
# manual benchmarking #
#######################

"""
    runbenchmark(show = true)

Run benchmark.
"""
function runbenchmark(show = true; showdebug = false)
	showdebug && @warn "keyword showdebug doesn't have effect currently."
    #glb = global_logger()
    #showdebug ? global_logger(nosource_debuglogger()) : global_logger(nosource_infologger())

	bmresult = benchmarkpkg("RANSAC")

    bmtrial = bmresult.benchmarkgroup.data["RANSAC"]["smallideal"]
	benched = makedf(bmtrial)

    show && display(bmtrial)
    #global_logger(glb)
    bmresult, bmtrial, benched
end

function makedf(bmresult)
	current_dir = pwd()
	RBProp = loadp()
	ransacdir = getdirfromprop(RBProp, "ransacdir", "Please give path to the RANSAC repo!")

	# get git info
	cd(ransacdir)
	comsha = read(`git log -n 1 --pretty=format:"%H"`, String)
	comdate = read(`git log -n 1 --pretty=format:"%ct"`, String)
	cd(ransacdir)

    pc = getpc()
    mint = BenchmarkTools.minimum(bmresult).time
    maxt = BenchmarkTools.maximum(bmresult).time
    meant = BenchmarkTools.mean(bmresult).time
    mediant = BenchmarkTools.median(bmresult).time

	df = DataFrame()
	df.benchmarkdate = [Dates.now()]
	df.commitdate = [unix2datetime(parse(Int, comdate))]
	df.commitsha = [comsha]
	df.minimumtime = [mint]
	df.mediantime = [mediant]
	df.meantime = [meant]
	df.maximumtime = [maxt]
	df.allocated = [allocs(bmresult)]
	df.memory = [memory(bmresult)/1024]
	df.bversion = [BENCHMARK_VERSION]
	df.system = [pc]
	df.jversion = [Base.VERSION]
	return df
end

function makedf(bmresult, commitsha, commitdate)
    pc = getpc()
    mint = BenchmarkTools.minimum(bmresult).time
    maxt = BenchmarkTools.maximum(bmresult).time
    meant = BenchmarkTools.mean(bmresult).time
    mediant = BenchmarkTools.median(bmresult).time

	df = DataFrame()
	df.benchmarkdate = [Dates.now()]
	df.commitdate = [commitdate]
	df.commitsha = [commitsha]
	df.minimumtime = [mint]
	df.mediantime = [mediant]
	df.meantime = [meant]
	df.maximumtime = [maxt]
	df.allocated = [allocs(bmresult)]
	df.memory = [memory(bmresult)/1024]
	df.bversion = [BENCHMARK_VERSION]
	df.system = [pc]
	df.jversion = [Base.VERSION]
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
    [df.benchmarkdate df.commitdate df.commitsha df.minimumtime df.mediantime df.meantime df.maximumtime df.allocated df.memory df.bversion df.system df.jversion]
end

function printresult(tb)
    hmnice = tablify(nicify(tb))
    tf = PrettyTableFormat(unicode)
    pretty_table(hmnice, table_header, tf, alignment = table_align, formatter=ft_round(3, [4,5,6,7,9]))
end

function saveresult(tb, fname = "benchmark_results.md")
    hmnice = tablify(nicify(tb))
    tf = PrettyTableFormat(markdown)
    open(fname, "w") do io
        pretty_table(io, hmnice, md_table_header, tf, alignment = table_align, formatter=ft_round(3, [4,5,6,7,9]))
    end
    @info "Pretty markdown saved."
end

function savebenchmark(bm, fname::AbstractString)
    if !isfile(fname)
        CSV.write(fname, bm )
    else
        CSV.write(fname, bm, append = true)
    end
    @info "CSV file saved."
end

function savebenchmark(bmarkresult, benchedtable)
	current_dir = pwd()

	RBProp = loadp()
	resultdir = getdirfromprop(RBProp, "resultdir", "Please give path to the RANSACBenchmarkResults repo!")

	# pull result repo
	cd(resultdir)
	cleanpull()
	cd(current_dir)

    savefull_benchmark(benchedtable, bmarkresult, resultdir)
end

function loadbenchmarks(fname::AbstractString)
    return CSV.read(fname)
end

function loadbenchmarks()
	current_dir = pwd()

	RBProp = loadp()
	resultdir = getdirfromprop(RBProp, "resultdir", "Please give path to the RANSACBenchmarkResults repo!")

	# pull result repo
	cd(resultdir)
	cleanpull()
	cd(current_dir)

    return loadbenchmarks(joinpath(resultdir, "assets", "private", "benchmark_results.csv"))
end

function printload()
	printresult(loadbenchmarks())
end

function setpropfile()
	RBProp = loadp()
	ransacdir = getdirfromprop(RBProp, "ransacdir", "Please give path to the RANSAC repo!")
	APIdir = getdirfromprop(RBProp, "apidir", "Please give path to the MasterThesis repo!")
	resultdir = getdirfromprop(RBProp, "resultdir", "Please give path to the RANSACBenchmarkResults repo!")
	resetcommitsha()
end

function info()
    @info "Runnnig one benchmark takes around 5 minutes."
    @info "`bmresult, bmtrial, benched = runbenchmark();` to run the benchmark at the current state of the repo."
    @info "`savebenchmark(bmresult, benched)` to append the last benchmark to the CSV file."
    @info "`bm = loadbenchmarks();` to load the saved benchmarks."
    @info "`printresult(bmark)` to show the result of one or more benchmarks."
    @info "Use `printload()` instead of `printresult(loadbenchmarks())`."
    @info "Use `resetcommitsha()` to reset the last benchmarked commit sha to the first commit, where benchmark possible."
    @info "Use `lastbenchmarkedcommit!(commitsha)` to reset last benchmark to a given commit (and store it)."
    @info "Use `callmeCI(;dopublish=true, commitnumb = 100, skipcommits=nothing)` to run a CI like benchmark round."
	@info "Use `setpropfile()` to set not-yet-set Properties."
end

##################
# CI like things #
##################

function loadp()
	if ! isfile(RPropsfile)
		store(Properties(), RPropsfile)
	end
	return load(RPropsfile)
end

function newfolderproperties(prop, key, message)
	println(message)
	dstr = readline()
	if isdir(dstr)
		setprop(prop, key, dstr)
		store(prop, RPropsfile)
	else
		println(dstr, " is not an existing directory. Nothing will change.")
	end
	nothing
end

function getdirfromprop(prop, key, question)
	dirn = getprop(prop, key, nothing)
	if dirn == nothing
		newfolderproperties(prop, key, question)
		dirn = getprop(prop, key)
		if dirn == nothing
			error("Could not find $key in $prop")
		end
	end
	return dirn
end

function lastbenchmarkedcommit(prop, key)
	getprop!(prop, key, LAST_BENCHMARKED)
end

function lastbenchmarkedcommit!(prop, key, commitsha)
	setprop(prop, key, commitsha)
	store(prop, RPropsfile)
end

function lastbenchmarkedcommit!(commitsha::AbstractString)
	prop = loadp()
	setprop(prop, commitkey, commitsha)
	store(prop, RPropsfile)
end

"""
    resetcommitsha(prop, key, commsha = LAST_BENCHMARKED)

Resets the commit sha, but doesn't calls `store()`.
"""
function resetcommitsha(prop, key, commsha = LAST_BENCHMARKED)
	setprop(prop, key, commsha)
end

function resetcommitsha()
	p = loadp()
	resetcommitsha(p, commitkey)
	store(p, RPropsfile)
end

function savefull_benchmark(df, bmresult, gitfolder)
	dirn = joinpath(gitfolder, "assets", "private")
	savebenchmark(df, joinpath(dirn, "benchmark_results.csv"))
	dform = DateFormat("Y-mm-ddTH-M-S.s")
	export_markdown(joinpath(dirn, "pkgbenchmark", getpc() *"_"* Dates.format(Dates.now(), dform)) * ".md", bmresult)
	@info "PkgBenchmark markdown saved."
end

function callmeCI(;dopublish=true, commitnumb = 100, skipcommits::Union{Array{String,1},Nothing}=nothing)
	current_dir = pwd()

	RBProp = loadp()
	ransacdir = getdirfromprop(RBProp, "ransacdir", "Please give path to the RANSAC repo!")
	APIdir = getdirfromprop(RBProp, "apidir", "Please give path to the MasterThesis repo!")
	resultdir = getdirfromprop(RBProp, "resultdir", "Please give path to the RANSACBenchmarkResults repo!")

	# Pull ransac repo
	cd(ransacdir)
	run(`git pull`)
	rshas = read(`git log -n $commitnumb --pretty=format:"%H"`, String)
	rdates = read(`git log -n $commitnumb --pretty=format:"%ct"`, String)

	# pull result repo
	cd(resultdir)
	cleanpull()
	cd(current_dir)

	commitshas = split(rshas, "\n")
	commitdates_ = (split(rdates, "\n"))
	commitdates = [unix2datetime(parse(Int, i)) for i in commitdates_]

	lastnum = findfirst(x->x==lastbenchmarkedcommit(RBProp, commitkey), commitshas)
	endnum = size(commitshas, 1)
	deleteat!(commitshas, lastnum:endnum)
	deleteat!(commitdates, lastnum:endnum)

	reverse!(commitshas)
	reverse!(commitdates)

	tunef = joinpath(ransacdir, "benchmark", "tune.json")
	benched = false
	for i in eachindex(commitshas)
		# skip commit if in skipcommits
		if vectequal(commitshas[i], skipcommits)
			@info "Skipping $(commitshas[i])"
			continue
		end

	# loop over commits
		nextcommitsha = commitshas[i]
		@info "Current commit: $nextcommitsha"
		bmres = benchmarkpkg("RANSAC", string(nextcommitsha))

		bm_trial = bmres.benchmarkgroup.data["RANSAC"]["smallideal"]
		benched = makedf(bm_trial, nextcommitsha, commitdates[i])
		savefull_benchmark(benched, bmres, resultdir)

		# remove tune file
		if isfile(tunef)
			rm(tunef)
			@info "Removed tune file."
		else
			@info "Didn't find tune file."
		end

		# store commit sha
		lastbenchmarkedcommit!(RBProp, commitkey, nextcommitsha)

		benched = true
	end

	if !benched
		@info "Didn't ran any benchmark."
		@info "Time is now: $(Dates.now())"
		return nothing
	end


	if dopublish
		# publish results without pulling
		publishresults(false)
	end
	@info "Finished benchmarking, latest: $(commitshas[1])."
	@info "Time is now: $(Dates.now())"
	return nothing
end

function vectequal(ref, strings)
	for s in strings
		if ref == s
			return true
		end
	end
	return false
end

vectequal(ref, strings::Nothing) = false

function publishresults(dopull=true)
	current_dir = pwd()

	RBProp = loadp()
	resultdir = getdirfromprop(RBProp, "resultdir", "Please give path to the RANSACBenchmarkResults repo!")

	if dopull
		# pull result repo
		cd(resultdir)
		cleanpull()
		cd(current_dir)
	end

	bmresultf = joinpath(resultdir, "assets", "private")
	alldf = loadbenchmarks(joinpath(bmresultf, "benchmark_results.csv"))
	saveresult(alldf, joinpath(bmresultf, "benchmark_results_all.md"))

	# pushing updates
	cd(resultdir)
	publish()
	cd(current_dir)
end

end # module

using .RANSACBenchmark
info()
