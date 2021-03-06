using CPLEX
using JuMP
#relaxation
M = Model(solver = CplexSolver())
@variable(M, 0 <= x[1:3] <= 1)
@objective(M, Min, x[1] + 2 * x[2] + x[3])
@constraints(M, begin
               x[1] + 2 * x[2] + 3 * x[3] >= 4
               3 * x[1] + x[2] + 3 * x[3] <= 5
             end)
solve(M)
obj = getobjectivevalue(M)
#relaxation with column generation
M = Model(solver = CplexSolver())
@variable(M, 0 <= λ[1:5] <= 1)
@objective(M, Min, 3 * λ[1] + 3 * λ[2] + λ[3] + 2 * λ[4] + λ[5])
@constraints(M, begin
               3 * λ[1] + 5 * λ[2] + λ[3] + 2 * λ[4] + 3 * λ[5] >= 4
               sum(λ[i] for i=1:5) == 1
               [i=1:5], λ[i] >= 0
             end)
solve(M)
obj = getobjectivevalue(M)

