# issue: https://github.com/JuliaLang/julia/issues/33183

using Base.Threads
using Base: Semaphore, acquire, release

function work(v)
   a = gensym()
   expr = Expr(:function,
      Expr(:tuple, a),
      Expr(:block, Expr(:call, *, a, v)))
   mul = eval(expr)
   out = Base.invokelatest(mul, v)
   return out
end

function main(nqueries)
   @threads for i in 1:nqueries
       work(i)
   end
end

function work2(v, sem)
   a = gensym()
   expr = Expr(:function,
      Expr(:tuple, a),
      Expr(:block, Expr(:call, *, a, v)))
   acquire(sem)
   mul = eval(expr)
   release(sem)
   out = Base.invokelatest(mul, v)
   return out
end

function main2(nqueries)
   s = Semaphore(1)
   @threads for i in 1:nqueries
       work2(i, s)
   end
end

#=
> I actually forgot I'd reported this issue a month ago, and I had spent a day already trying to track it down again! 😂 Haha thanks so much for the _timely_ ping, @cserteGT3! 😂

you're welcome 😂

> In the much shorter term, since #33553 looks like a large refactoring PR, of the sort that makes backporting unlikely, is it possible we can fix this issue by just adding some more locks? I'd happily trade more contention for not erroring.

I had the same idea for workaround, and created an MWE based on my use case.

test.jl:
```julia
using Base.Threads
using Base: Semaphore, acquire, release

function work(v)
   a = gensym()
   expr = Expr(:function,
      Expr(:tuple, a),
      Expr(:block, Expr(:call, *, a, v)))
   mul = eval(expr)
   out = Base.invokelatest(mul, v)
   return out
end

function main(nqueries)
   @threads for i in 1:nqueries
       work(i)
   end
end

function work2(v, sem)
   a = gensym()
   expr = Expr(:function,
      Expr(:tuple, a),
      Expr(:block, Expr(:call, *, a, v)))
   acquire(sem)
   mul = eval(expr)
   release(sem)
   out = Base.invokelatest(mul, v)
   return out
end

function main2(nqueries)
   s = Semaphore(1)
   @threads for i in 1:nqueries
       work2(i, s)
   end
end
```

results:
```julia

julia> using Base.Threads

julia> nthreads()
4

julia> include("test.jl")
main2 (generic function with 1 method)

julia> main(10)

julia> main(100_000)
ERROR: TaskFailedException:
cannot eval a new struct type definition while defining another type
Stacktrace:
 [1] top-level scope at none:0
 [2] top-level scope at REPL[5]:1
 [3] eval at .\boot.jl:330 [inlined]
 [4] eval(::Expr) at .\client.jl:433
 [5] work(::Int64) at C:\Users\cstamas\Documents\GIT\MasterThesis\racecondition.jl:11
 [6] macro expansion at C:\Users\cstamas\Documents\GIT\MasterThesis\racecondition.jl:18 [inlined]
 [7] (::var"#2#threadsfor_fun#3"{UnitRange{Int64}})(::Bool) at .\threadingconstructs.jl:61
 [8] (::var"#2#threadsfor_fun#3"{UnitRange{Int64}})() at .\threadingconstructs.jl:28
Stacktrace:
 [1] wait(::Task) at .\task.jl:251
 [2] macro expansion at .\threadingconstructs.jl:69 [inlined]
 [3] main(::Int64) at C:\Users\cstamas\Documents\GIT\MasterThesis\racecondition.jl:17
 [4] top-level scope at REPL[5]:1

julia> main2(10)

julia> main2(100_000)

julia> @time main(100)
  0.440021 seconds (53.01 k allocations: 3.235 MiB)

julia> @time main2(100)
  0.454643 seconds (58.63 k allocations: 3.557 MiB)
```
This works for me on `v1.3.0-rc4.1`. Tried `main2(400_000)` which also worked, so I guess this could be used as (one) workaround until the proper solution.

=#
