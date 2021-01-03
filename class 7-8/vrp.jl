using CPLEX
using JuMP
import MathProgBase

#vars
m = 9
C = 10 + m

function resolve_vrp(n, depot, relax = false, log = false)
    # Lê os dados da instância
    pontos = reshape(
        parse.(Int, split(read("instancias/tsp$(n).txt", String))),
        2, n
    )
    px = pontos[1,1:n]
    py = pontos[2,1:n]
    V = [i for i in 1:n]
    _V = copy(V)
    filter!(x->x != depot, _V)
    E = [(i,j) for i in V for j in V if i < j]
    d(e) = sqrt((px[e[1]] - px[e[2]])^2 + (py[e[1]] - py[e[2]])^2)
    delta(S) = [(i,j) for (i,j) in E if (i in S) != (j in S)]
    # Monta o modelo mestre
    M = Model(solver = CplexSolver(
                                   CPX_PARAM_SCRIND= if (log) 1 else 0 end,
                                   CPX_PARAM_MIPDISPLAY=4,
                                   CPX_PARAM_MIPINTERVAL=1,
                                   CPX_PARAM_THREADS=1
                                  ))
    if relax
      @variable(M, 0 <= x[e in E] <= 1)
    else
      @variable(M, x[e in E], Bin)
    end
    @objective(M, Min, sum(d(e) * x[e] for e in E))
    @constraint(M, [i in _V], sum(x[e] for e in delta([i])) == 2)
    # Define a rotina de separação
    function separa(cb, corte)
        # se for corte, só separa com gap maior que 2%
        if corte
            gap = 1.0 - cbgetnodeobjval(cb) / MathProgBase.cbgetobj(cb)
            if gap < 0.02
                return
            end
        end
        # Pega a solução relaxada
        _x_ = getvalue(x)
        # Monta o modelo de separação e resolve
        Sep = Model(solver = CplexSolver(
            CPX_PARAM_SCRIND=0,
            CPX_PARAM_THREADS=1
        ))
        @variables(Sep, begin
            w[e in E] >= 0
            y[i in V], Bin
            z, Int
        end)
        @objective(Sep, Min, sum(_x_[e] * w[e] for e in E) - 2 * z)
        @constraints(Sep, begin
            [(i,j) in E], w[(i,j)] >= y[i] - y[j]
            [(i,j) in E], w[(i,j)] >= y[j] - y[i]
            C * z - sum(y[i] for i in V) <= C-1
            y[depot] == 0
        end)
        solve(Sep)
        # Insere a restrição se violada
        obj = getobjectivevalue(Sep)
        if obj <= - (10^-6)
            _y_ = getvalue(y)
            _z_ = getvalue(z)
            S = [i for i in V if _y_[i] > 0.5]
            if corte
                @usercut(cb, sum(x[e] for e in delta(S)) >= 2 * _z_)
                unsafe_store!(cb.userinteraction_p, convert(Cint,2), 1)
            else
                @lazyconstraint(cb, sum(x[e] for e in delta(S)) >= 2 * _z_)
            end
        end
    end
    function separa_corte(cb)
        separa(cb, true)
    end
    addcutcallback(M, separa_corte)
    function separa_restr(cb)
        separa(cb, false)
    end
    addlazycallback(M, separa_restr)
    # Resolve e pega o resultado
    JuMP.build(M)
    cpxM = getrawsolver(M)
    CPLEX.set_logfile(cpxM.env, "cvrp.log")
    start = time()
    solve(M)
    elapsed = time() - start
    _x_ = getvalue(x)
    return getobjectivevalue(M), elapsed, MathProgBase.getnodecount(M), [e for e in E if _x_[e] > 0.5]
end

function plot(n, sol, dep)
  pontos = reshape(
    parse.(Int, split(read("instancias/tsp$(n).txt", String))),
    2, n
  )
  px = pontos[1,1:n]
  py = pontos[2,1:n]
  x_plot = "x=$(px[dep])"
  y_plot = "y=$(py[dep])"
  adj = [vcat(
              [e[1] for e in sol if e[2] == i],
              [e[2] for e in sol if e[1] == i]
             ) for i in 1:n
        ]
  i = dep
  j = adj[i][1]
  visitado = zeros(Bool, n)
  while true
    k = 1
    while adj[j][k] == i || visitado[adj[j][k]]
      k += 1
      if k > length(adj[j])
        break
      end
    end
    if k > length(adj[j])
      break
    end
    if j != dep
      visitado[j] = true
    end
    i = j
    j = adj[i][k]
    x_plot *= ",$(px[i])"
    y_plot *= ",$(py[i])"
  end
  x_plot *= ",$(px[j])"
  y_plot *= ",$(py[j])"
  return "www.graphreader.com/plotter?$(x_plot)&$(y_plot)"
end

println("n;depot;relaxed;integer")
println(";;cost;time;#nodes;cost;time;#nodes;url")
for j in [30, 50]
  for i = 1:10
    cost, time, nodes, points = resolve_vrp(j, i, true)
    cost_, time_, nodes_, points = resolve_vrp(j, i)
    println(j, ";", i, ";", cost, ";", time, ";", nodes, ";", cost_, ";", time_, ";", nodes_, ";", plot(j, points, i))
  end
end
