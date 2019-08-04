module RANSACBenchmark

using Dates
using Logging
using Random

using PkgBenchmark
using BenchmarkTools
using DataFrames
using CSV

using RANSAC: nosource_debuglogger, nosource_infologger

export runbenchmark
export makedf

"""
    runbenchmark(show = true)

Run benchmark.
"""
function runbenchmark(show = true; showdebug = false)
    glb = global_logger()
    showdebug ? global_logger(nosource_debuglogger()) : global_logger(nosource_infologger())

	bmi_ = benchmarkpkg("RANSAC")

    bmi = bmi_.benchmarkgroup.data["RANSAC"]["smallideal"]
	benched = makedf(bmi)

    show && display(bmi)
    global_logger(glb)
    benched, bmi
end

function makedf(bmresult)
	#TODO: melyik mappában?
	#comsha = read(`git log -n 1 --pretty=format:"%H"`, String)
	comsha = "TODOOOOOOOOOOOOOOOOOOOO"

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

end # module
