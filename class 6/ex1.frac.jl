using CPLEX
using JuMP

n = 7
d = [
     0 1 0 3 0 5 0
    ]
M = Model()
set_optimizer(M, CPLEX.Optimizer)
@variables(M, 
           begin
           0 <= x[1:n] <= 1 
           end
           )
@objective(M, Max, sum(d[i] * x[i] for i in 1:n))
@constraints(M, 
             begin
               sum(i * x[i] for i in 1:n) <= n 
             end
             )
println(M)
optimize!(M)
getobjectivevalue(M)
print(JuMP.value.(x))
