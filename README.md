# Exercises of the course Special Topics II: Integer Programming and Combinatorial Optimization from the Fluminense Federal University (UFF)

This repository contains the implementation using Julia v1.3.1 and JuMP v0.18 (exception class 6) of several exercises.
The project file structure works as follows:

* class 6: This folder contains the implementation of integer and linear programming formulations in Julia v1.5.3 using JuMP v0.21.5. The formulation is presented bellow:
min <img src="https://render.githubusercontent.com/render/math?math=\sum_{i = 1}^n d_i x_i \quad (1)">
<img src="https://render.githubusercontent.com/render/math?math=\sum_{i = 1}^n i x_i \leqslant n \quad (2)">
<img src="https://render.githubusercontent.com/render/math?math=0 \leqslant x_i \leqslant 1 \quad \forall i in \{1, ..., n\} \quad (3)">
  * ```ex1.frac.jl```: Given a linear programming formulation, this file finds the optimal solution for the linear program;
  * ```ex1.int.jl```: Given an integer programming formulation for the linear program from the file above, this file find the optimal solution for the integer program;
  * ```ex1.porta.jl```: Given a set of integer points from a polyhedron, this file uses the PORTA (POlyhedron Representation Transformation Algorithm http://porta.zib.de/) to derive the inequalities that define the polyhedron convex hull;
  * ```ex1.conv.jl```: Given the linear programming formulation derived from the inequalities obtained from ```ex1.conv.jl```, this file finds the optimal solution for this linear program, which also will be an integer solution since the inequalities given by PORTA forms a convex hull. 
* class 7-8: This folder contains the implementation of the well-known TSP and CVRP formulations (both with an exponential number of constraints):  
  * ```tsp.jl```: The TSP formulation in three different versions, the version with lazy constraints, user cuts, and both;
  * ```vrp.jl```: The CVRP formulation with lazy constraints and user cuts.
* class 10: This folder contains the implementation of a column generation solution for the formulation presented bellow:
min <img src="https://render.githubusercontent.com/render/math?math=x_1 + 2 x_2 \quad (1)">
<img src="https://render.githubusercontent.com/render/math?math=x_1 + 2 x_2 + 3 x_3 \geqslant 4 \quad (2)">
<img src="https://render.githubusercontent.com/render/math?math=3 x_1 + x_2 + 3 x_3 \leqslant 5 \quad (3)">
<img src="https://render.githubusercontent.com/render/math?math=0 \leqslant x_i \leqslant 1 \quad \forall i \in \{1, ..., 3\} \quad (4)">
* class 11: This folder contains the implementation of a LP and IP formulation for the [Weighted Graph Coloring](https://arxiv.org/abs/0908.2375).
* class 12: This folder contains the implementation of a column generation procedure for the Generalized Assignment (GAP) with a custom Branch-and-Bound (B&B) strategy:
  * ```cgGAP.jl```: A GAP column generation formulation;
  * ```bbGAP.jl```: A B&B  algorithm for the GAP column generation formulation;

Any doubts feel free to reach out: matheusdiogenesandrade@ic.unicamp.br

