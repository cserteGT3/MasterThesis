export JULIA_NUM_THREADS=2
julia --project --color=yes holedspherebench.jl
export JULIA_NUM_THREADS=1
julia --project --color=yes holedspherebench.jl
