# Exercises of the course Special Topics II: Integer Programming and Combinatorial Optimization from the Fluminense Federal University (UFF)

This repository contains the implementation in Julia v1.5.3 using JuMP of v0.21.5 (excepting class 7)  of several exercises.
The project file structure works as follows:

* class 6: This folder contains the implementation of integer and linear programming formulations:
  * ```ex1.frac.jl```: Given a linear programming formulation, this file finds the optimal solution for the linear program;
  * ```ex1.int.jl```: Given an integer programming formulation for the linear program from the file above, this file find the optimal solution for the integer program;
  * ```ex1.porta.jl```: Given a set of integer points from a polyhedron, this file uses the PORTA (POlyhedron Representation Transformation Algorithm http://porta.zib.de/) to derive the inequalities that define the polyhedron convex hull;
  * ```ex1.conv.jl```: Given the linear programming formulation derived from the inequalities obtained from ```ex1.conv.jl```, this file finds the optimal solution for this linear program, which also will be an integer solution since the inequalities given by PORTA forms a convex hull. 
* class 7: This folder contains the implementation of the well-known TSP and CVRP formulations (both with an exponential number of constraints), using Julia v1.3.1 and JuMP v0.18:  
  * ```tsp.jl```: The TSP formulation in three different versions, the version with lazy constraints, user cuts, and both;
  * ```vrp.jl```: The CVRP formulation with lazy constraints and user cuts.

Any doubts feel free to reach out: matheusdiogenesandrade@ic.unicamp.br

