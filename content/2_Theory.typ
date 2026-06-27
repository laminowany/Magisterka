#import "../utils.typ": todo, silentheading, flex-caption
= Theoretical Background

== Capacitated Vehicle Routing Problem (CVRP)

=== Problem Definition

The Vehicle Routing Problem (VRP) is a class of combinatorial optimization problems whose objective is to determine optimal routes for a fleet of vehicles. Introduced by Dantzig and Ramser in 1959 @DantzigRamser, VRP can be viewed as a generalization of the Traveling Salesman Problem (TSP).

While the TSP aims to find the shortest possible route for a single vehicle that must visit a set of customers and return to a central depot, VRP focuses on optimizing multiple routes for a fleet of vehicles. The objective is typically to minimize the total distance traveled by all vehicles while ensuring that every customer is visited.

A common approach to solving VRP is to decompose it into two subproblems. First, customers are assigned to individual vehicles, often through a clustering procedure. Then, for each vehicle, a corresponding TSP instance is solved to determine the visiting order of customers. Several routing algorithms follow this approach, combining clustering techniques for customer assignment with specialized methods for solving the resulting TSP instances.

VRP is NP-hard and can be formulated as a Mixed Integer Programming (MIP) problem. However, exact methods become computationally infeasible for large real-world instances. Consequently, a wide range of heuristics, metaheuristics, and hybrid approaches have been developed to obtain high-quality solutions within reasonable computation times. More recently, machine learning approaches based on Graph Neural Networks (GNNs) and Reinforcement Learning (RL) have emerged as an alternative paradigm for solving routing problems.

While the classical VRP consists of a single depot, multiple customers that must be visited, and a fleet of vehicles that start and end their routes at the depot, numerous variants of the problem have been proposed in the literature. Some of the most common variants include:

- Capacitated Vehicle Routing Problem (CVRP) – each vehicle has a limited carrying capacity, and each customer is associated with a specific demand.
- Vehicle Routing Problem with Time Windows (VRPTW) – each customer must be served within a specified time window.
- Multi-Depot Vehicle Routing Problem (MDVRP) – multiple depots are available, and vehicles may be assigned to different depots.
- Open Vehicle Routing Problem (OVRP) – vehicles are not required to return to the depot after completing their routes.

This thesis focuses exclusively on the Capacitated Vehicle Routing Problem (CVRP).

#pagebreak()

=== Mathematical Formulation

CVRP can be formulated as a Mixed Integer Linear Programming (MILP) problem as follows:

*Sets*

$ V = {0} union C, quad C = {1, dots, n} $ 
$ K = {1, dots, k} $

where:
- node $0$ denotes the depot
- $C$ denotes the set of customers
- $K$ denotes the set of vehicles.
#sym.zws

*Parameters*

$ c_"ij" "- the cost of travel between "i" and "j, quad i,j in V  $ 
$ d_"i" "- the demand of customer "i, quad i in V  $ 
$ Q "- the maximum capacity of each vehicle" $
#sym.zws

*Decision Variables*

$ x_"ijk" "- binary variable, equal to 1 if vehicle" k "travels from "i" to "j", 0 otherwise" \ quad i,j in V, quad k in K $ 
$ u_i "- continuous variable representing the cumulative load after departing from customer" \ quad i in C $ 
#sym.zws

*Cost Function*

Minimize the total disctance traveled by vehicles:
$ min sum_(k in K) sum_(i in V) sum_(j in V) c_"ij" x_"ijk"  $
#sym.zws

*Constraints*

Each vehicle can leave the depot at most once:
$ sum_(j in C) x_"0jk" <= 1, quad forall k in K $
#sym.zws


Each customer must be visited exactely once:
$ sum_(k in K) sum_(i in V) x_"ijk" = 1, quad forall j in C $
#sym.zws


#sym.zws
A vehicle that arrives at the customer must also leave it:
$ sum_(i in C) x_"ihk" - sum_(j in C) x_"hjk" = 0, quad forall h in C, forall k in K $
#sym.zws

Load of vehicle cannot exceed its capacity:
$ sum_(i in C) d_"i" sum_(j in V) x_"ijk" <= Q , quad forall k in K $
#sym.zws

Eliminating subtours (Miller-Tucker-Zemlin formulation @MTZ):
$ u_j - u_i >= q_j - Q(1-x_"ijk"), quad forall i,j in C, quad i != j $
$ q_i <= u_i <= Q, quad forall i in C $
#sym.zws

Decision variables constraints:
$ x_"ijk" in {0, 1}, quad forall i, j in V, quad forall k in K $
$ u_i >= 0, quad forall i in C $

== Graph Neural Network (GNN)

== Reinforcement Learning for routing

== Kool model

== Neural Architecture Search (NAS)

== Cartesian Genetic Programming (CGP)