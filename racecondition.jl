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

main(100_000)

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

work2(5, Semaphore(1))

@time main(1000)
@time main2(1000)
