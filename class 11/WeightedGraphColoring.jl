using CPLEX
using JuMP
#relaxation
V = collect(1:5) 
E = [(1, 2), 
     (2, 3), 
     (3, 4), 
     (4, 5), 
     (1, 5)]
K = collect(1:3)
c = transpose([[1 2 3 4 5]
               [6 5 4 3 2]
               [8 8 7 7 7]])
M = Model(solver = CplexSolver())
@variable(M, 0 <= x[1:length(V), 1:length(K)] <= 1)
@objective(M, Min, sum(x[i, k] * c[i, k] for i in V for k in K))
@constraints(M, begin
               [i in V], sum(x[i, k] for k in K) == 1
               [(i, j) in E, k in K], x[i, k] + x[j, k] <= 1
             end)
solve(M)
_x_ = getvalue(x)
obj = getobjectivevalue(M)
#integer
M = Model(solver = CplexSolver())
@variable(M, x[1:length(V), 1:length(K)], Bin)
@objective(M, Min, sum(x[i, k] * c[i, k] for i in V for k in K))
@constraints(M, begin
               [i in V], sum(x[i, k] for k in K) == 1
               [(i, j) in E, k in K], x[i, k] + x[j, k] <= 1
             end)
solve(M)
_x_ = getvalue(x)
obj = getobjectivevalue(M)

