function branch_and_bound_GAP(m, n, a, C, c)
    best_sol = Array{Float64}[]
    best_cost = Inf

    # node = (parent node index, branches array (i,j,x̄))
    root = (0, Tuple{Int,Int,Float64}[])
    tree = [root]

    # solve every B&B tree node
    k = 1
    println("  Node   Parent  Relaxation    Solution  Branch")
    while k <= length(tree)
        # solve node k
        (parent, B) = tree[k]
        limit, x̄ = solve_GAP_relaxation(m, n, a, C, c, B)

        # print node k info 
        @printf("% 4d  % 4d  % 9.2f  %9.2f  ",
            k - 1, parent - 1, limit, best_cost)
        if isempty(B)
            @printf("root\n")
        else
            i, j, ξ = B[end]
            @printf("x[%d,%d] = %g\n", i, j, ξ)
        end

        # if not limit prune...
        if limit < best_cost - 0.001
            # most fractional variable 
            i_frac = 0
            j_frac = 0
            maior_dist_int = 0.0
            for i in 1:m
                for j in 1:n
                    dist_int = min(x̄[i][j], 1.0 - x̄[i][j])
                    if dist_int > maior_dist_int
                        maior_dist_int = dist_int
                        i_frac = i
                        j_frac = j
                    end
                end
            end

            # if integer solution, update the cost 
            if maior_dist_int < 0.001
                best_cost = limit
                best_sol = x̄

            # else, branch 
            else
                # child node with x[i_frac, j_frac] = 0.0
                B0 = copy(B)
                push!(B0, (i_frac, j_frac, 0.0))
                push!(tree, (k, B0))

                # child node with x[i_frac, j_frac] = 1.0
                B1 = copy(B)
                push!(B1, (i_frac, j_frac, 1.0))
                push!(tree, (k, B1))
            end
        end

        # next node 
        k += 1
        if k == 10001
            println("Nodes limit excedeed: aborted!")
            return best_cost, best_sol
        end
    end

    return best_cost, best_sol
end

function branch_and_bound_cg_GAP(m, n, a, C, c)
    best_sol = Array{Float64}[]
    best_cost = Inf

    # node = (parent node index, branches array (i,j,x̄))
    root = (0, Tuple{Int,Int,Float64}[])
    tree = [root]

    # solve every B&B tree node
    k = 1
    println("  nó   parent  relaxação    solução  branch")
    while k <= length(tree)
        # solve node k
        (parent, B) = tree[k]
        limit, x̄ = column_generation_branch_GAP(m, n, a, C, c, B)

        # print node k info 
        @printf("% 4d  % 4d  % 9.2f  %9.2f  ",
            k - 1, parent - 1, limit, best_cost)
        if isempty(B)
            @printf("root\n")
        else
            i, j, ξ = B[end]
            @printf("x[%d,%d] = %g\n", i, j, ξ)
        end

        # if not limit prune...
        if limit < best_cost - 0.001
            # most fractional variable 
            i_frac = 0
            j_frac = 0
            maior_dist_int = 0.0
            for i in 1:m
                for j in 1:n
                    dist_int = min(x̄[i][j], 1.0 - x̄[i][j])
                    if dist_int > maior_dist_int
                        maior_dist_int = dist_int
                        i_frac = i
                        j_frac = j
                    end
                end
            end

            # if integer solution, update the cost 
            if maior_dist_int < 0.001
                best_cost = limit
                best_sol = x̄

            # else, branch 
            else
                # child node with x[i_frac, j_frac] = 0.0
                B0 = copy(B)
                push!(B0, (i_frac, j_frac, 0.0))
                push!(tree, (k, B0))

                # child node with x[i_frac, j_frac] = 1.0
                B1 = copy(B)
                push!(B1, (i_frac, j_frac, 1.0))
                push!(tree, (k, B1))
            end
        end

        # next node 
        k += 1
        if k == 10001
            println("Nodes limit exceeded: aborted!")
            return best_cost, best_sol
        end
    end

    return best_cost, best_sol
end
