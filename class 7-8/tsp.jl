using CPLEX
using JuMP

n = 6

pontos = reshape(
    parse.(Int, split(read("instancias/tsp$(n).txt", String))),
    2, n
)

px = pontos[1,1:n]

py = pontos[2,1:n]

V = [i for i in 1:n]

E = [(i,j) for i in V for j in V if i < j]

d(e) = sqrt((px[e[1]] - px[e[2]])^2 + (py[e[1]] - py[e[2]])^2)


delta(S) = [(i,j) for (i,j) in E if (i in S) != (j in S)]


# ==========================================

M = Model(solver = CplexSolver())

@variable(M, 0 <= x[e in E] <= 1)

@objective(M, Min, sum(d(e) * x[e] for e in E))

@constraint(M, [i in V], sum(x[e] for e in delta([i])) == 2)

solve(M)

_x_ = getvalue(x)

sol = [e for e in E if _x_[e] > 0.5]

# ==========================================

S = [1, 2, 3]

@constraint(M, sum(x[e] for e in delta(S)) >= 2)

solve(M)

_x′_ = getvalue(x)

sol = [e for e in E if _x′_[e] > 0.5]

# ==========================================

Sep = Model(solver = CplexSolver())

@variables(Sep, begin
    w[e in E] >= 0
    y[i in V], Bin
end)

@objective(Sep, Min, sum(_x_[e] * w[e] for e in E))

@constraints(Sep, begin
    [(i,j) in E], w[(i,j)] >= y[i] - y[j]
    [(i,j) in E], w[(i,j)] >= y[j] - y[i]
    sum(y[i] for i in V) <= n-1
    y[1] == 1
end)

solve(Sep)

obj = getobjectivevalue(Sep)

_y_ = getvalue(y)

S = [i for i in V if _y_[i] > 0.5]

# ==========================================

M = Model(solver = CplexSolver())

@variable(M, x[e in E], Bin)

@objective(M, Min, sum(d(e) * x[e] for e in E))

@constraint(M, [i in V], sum(x[e] for e in delta([i])) == 2)

function separa(cb)
    _x_ = getvalue(x)
    Sep = Model(solver = CplexSolver())
    @variables(Sep, begin
        w[e in E] >= 0
        y[i in V], Bin
    end)
    @objective(Sep, Min, sum(_x_[e] * w[e] for e in E))
    @constraints(Sep, begin
        [(i,j) in E], w[(i,j)] >= y[i] - y[j]
        [(i,j) in E], w[(i,j)] >= y[j] - y[i]
        sum(y[i] for i in V) <= n-1
        y[1] == 1
    end)
    solve(Sep)
    obj = getobjectivevalue(Sep)
    if obj < 1.9
        _y_ = getvalue(y)
        S = [i for i in V if _y_[i] > 0.5]
        println("S = $S, obj = $(obj)")
        @lazyconstraint(cb, sum(x[e] for e in delta(S)) >= 2)
    end
end

addlazycallback(M, separa)

solve(M)

getobjectivevalue(M)

_x_ = getvalue(x)

sol = [e for e in E if _x_[e] > 0.5]

# ==========================================

function resolve_tsp(n)
    # Lê os dados da instância
    pontos = reshape(
        parse.(Int, split(read("instancias/tsp$(n).txt", String))),
        2, n
    )
    px = pontos[1,1:n]
    py = pontos[2,1:n]
    V = [i for i in 1:n]
    E = [(i,j) for i in V for j in V if i < j]
    d(e) = sqrt((px[e[1]] - px[e[2]])^2 + (py[e[1]] - py[e[2]])^2)
    delta(S) = [(i,j) for (i,j) in E if (i in S) != (j in S)]

    # Monta o modelo mestre
    M = Model(solver = CplexSolver(
        CPX_PARAM_MIPDISPLAY=4,
        CPX_PARAM_MIPINTERVAL=1,
        CPX_PARAM_THREADS=1
    ))
    @variable(M, x[e in E], Bin)
    @objective(M, Min, sum(d(e) * x[e] for e in E))
    @constraint(M, [i in V], sum(x[e] for e in delta([i])) == 2)

    # Define a rotina de separação
    function separa(cb)
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
        end)
        @objective(Sep, Min, sum(_x_[e] * w[e] for e in E))
        @constraints(Sep, begin
            [(i,j) in E], w[(i,j)] >= y[i] - y[j]
            [(i,j) in E], w[(i,j)] >= y[j] - y[i]
            sum(y[i] for i in V) <= n-1
            y[1] == 1
        end)
        solve(Sep)

        # Insere a restrição se violada
        obj = getobjectivevalue(Sep)
        if obj < 1.9
            _y_ = getvalue(y)
            S = [i for i in V if _y_[i] > 0.5]
            @lazyconstraint(cb, sum(x[e] for e in delta(S)) >= 2)
        end
    end
    addlazycallback(M, separa)

    # Resolve e pega o resultado
    solve(M)
    _x_ = getvalue(x)
    return getobjectivevalue(M), [e for e in E if _x_[e] > 0.5]
end

resolve_tsp(6)

# ==========================================

resolve_tsp(30)

# ==========================================

import MathProgBase

function resolve_tsp_v2(n)
    # Lê os dados da instância
    pontos = reshape(
        parse.(Int, split(read("instancias/tsp$(n).txt", String))),
        2, n
    )
    px = pontos[1,1:n]
    py = pontos[2,1:n]
    V = [i for i in 1:n]
    E = [(i,j) for i in V for j in V if i < j]
    d(e) = sqrt((px[e[1]] - px[e[2]])^2 + (py[e[1]] - py[e[2]])^2)
    delta(S) = [(i,j) for (i,j) in E if (i in S) != (j in S)]

    # Monta o modelo mestre
    M = Model(solver = CplexSolver(
        CPX_PARAM_MIPDISPLAY=4,
        CPX_PARAM_MIPINTERVAL=1,
        CPX_PARAM_THREADS=1
    ))
    @variable(M, x[e in E], Bin)
    @objective(M, Min, sum(d(e) * x[e] for e in E))
    @constraint(M, [i in V], sum(x[e] for e in delta([i])) == 2)

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
        end)
        @objective(Sep, Min, sum(_x_[e] * w[e] for e in E))
        @constraints(Sep, begin
            [(i,j) in E], w[(i,j)] >= y[i] - y[j]
            [(i,j) in E], w[(i,j)] >= y[j] - y[i]
            sum(y[i] for i in V) <= n-1
            y[1] == 1
        end)
        solve(Sep)

        # Insere a restrição se violada
        obj = getobjectivevalue(Sep)
        if obj < 1.9
            _y_ = getvalue(y)
            S = [i for i in V if _y_[i] > 0.5]
            if corte
                @usercut(cb, sum(x[e] for e in delta(S)) >= 2)
                unsafe_store!(cb.userinteraction_p, convert(Cint,2), 1)
            else
                @lazyconstraint(cb, sum(x[e] for e in delta(S)) >= 2)
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
    solve(M)
    _x_ = getvalue(x)
    return getobjectivevalue(M), [e for e in E if _x_[e] > 0.5]
end

# ==========================================

resolve_tsp(30)

resolve_tsp_v2(30)

# ==========================================

resolve_tsp(100)

resolve_tsp_v2(100)

# ==========================================

resolve_tsp(200)

# ==========================================

custo, sol = resolve_tsp_v2(200)

function plot(n, sol)
    pontos = reshape(
        parse.(Int, split(read("instancias/tsp$(n).txt", String))),
        2, n
    )
    px = pontos[1,1:n]
    py = pontos[2,1:n]
    x_plot = "x=$(px[1])"
    y_plot = "y=$(py[1])"
    adj = [vcat(
            [e[1] for e in sol if e[2] == i],
            [e[2] for e in sol if e[1] == i]
        ) for i in 1:n
    ]
    i = 1
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
        if j != 1
            visitado[j] = 1
        end
        i = j
        j = adj[i][k]
        x_plot *= ",$(px[i])"
        y_plot *= ",$(py[i])"
    end
    x_plot *= ",$(px[j])"
    y_plot *= ",$(py[j])"
    println("graphreader.com/plotter?$(x_plot)&$(y_plot)")
end

plot(200, sol)
