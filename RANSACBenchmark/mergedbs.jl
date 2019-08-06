using DataFrames
using CSV
using Dates

## Load current databases

olddbf = abspath(raw"C:\Users\cstamas\.julia\dev\RANSAC\benchmark\benchmark_results.csv")
newdbf = abspath(raw"C:\Users\cstamas\Documents\GIT\RANSACBenchmarkResults\assets\private\benchmark_results.csv")

olddb = CSV.read(olddbf)
newdb = CSV.read(newdbf)

# Read git log

curr_dir = pwd()
cd(dirname(olddbf))
rshas = read(`git log -n 150 --pretty=format:"%H"`, String);
rdates = read(`git log -n 150 --pretty=format:"%ct"`, String);
cd(curr_dir)

commitshas = split(rshas, "\n");
commitdates_ = (split(rdates, "\n"));
commitdates = [unix2datetime(parse(Int, i)) for i in commitdates_]

commitdb = DataFrame();
commitdb.commitdate = commitdates;
commitdb.commitsha = [string(c) for c in commitshas]
joineccomm = join(olddb, commitdb, on=:commitsha)

compl = DataFrame()
compl.benchmarkdate = olddb.date;
compl.commitdate = joineccomm.commitdate;
compl.commitsha = olddb.commitsha;
compl.minimumtime = olddb.minimumtime;
compl.mediantime = olddb.mediantime;
compl.meantime = olddb.meantime;
compl.maximumtime = olddb.maximumtime;
compl.allocated = olddb.allocated;
compl.memory = olddb.memory;
compl.bversion = [v"1.0.0" for i in 1:9]
compl.system = olddb.system;
compl.jversion = [missing for i in 1:9]

CSV.write("merged.csv", compl)
CSV.write("joined.csv", joineccomm)
