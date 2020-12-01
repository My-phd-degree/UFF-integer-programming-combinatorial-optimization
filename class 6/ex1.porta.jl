using Combinatorics

n = 7

function gera_pontos()
  pontos = " 0 0 0 0 0 0 0"
  for S in combinations(collect(1:n))
    x = [(i in S) ? 1 : 0 for i in collect(1:n)]
    sum = 0
    for i in collect(1:n)
      sum += i * x[i]
    end
    if sum <= n 
      pontos = string(pontos, "\n")
      for i in collect(1:n)
        pontos = string(pontos, " $(x[i])")
      end
    end
  end
  return pontos
end

write("ex1.poi", "DIM = $(n)
CONV_SECTION
$(gera_pontos())
END\n")
