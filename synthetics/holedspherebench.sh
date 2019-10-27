export JULIA_NUM_THREADS=2
julia --color=yes holedspherebench.jl
export JULIA_NUM_THREADS=1
julia --color=yes holedspherebench.jl