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
               x[1] + x[7] <= 1
               x[2] + x[6] + x[7] <= 1
               x[4] + x[5] + x[6] + x[7] <= 1
               x[3] + x[5] + x[6] + x[7] <= 1
               x[1] + x[2] + x[5] + x[6] + 2 * x[7] <= 2
               x[2] + x[3] + x[4] + x[5] + 2 * x[6] + 2 * x[7] <= 2
               x[1] + x[3] + x[4] + x[5] + x[6] + 2 * x[7] <= 2
               x[1] + x[2] + 2 * x[3] + 2 * x[4] + 3 * x[5] + 3 * x[6] + 4 * x[7] <= 4
             end
             )
println(M)
optimize!(M)
getobjectivevalue(M)
print(JuMP.value.(x))
