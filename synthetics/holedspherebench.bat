set JULIA_NUM_THREADS=4
julia --color=yes holedspherebench.jl
set JULIA_NUM_THREADS=2
julia --color=yes holedspherebench.jl
set JULIA_NUM_THREADS=1
julia --color=yes holedspherebench.jl