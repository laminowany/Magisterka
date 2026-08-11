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

The notation CVRP$N$ is widely used to denote a CVRP instance with $N$ customer nodes. For example CVRP10 denotes the CVRP problem with 10 customers.

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

There is no formal and strict definition of what a Graph Neural Network (GNN) is, nor are there precise architectural or methodological requirements that a neural network must satisfy to be classified as a GNN. A practical and widely applicable definition is that any neural network that operates on graph-structured data can be considered a GNN.

A graph can be formally defined as $G = (V, E)$, where $V$ denotes the set of nodes and $E subset.eq V times V$ denotes the set of edges.
Each node $v in V$ is associated with feature vector $h_v$. Each edge $(u, v) in E$ may also be associated with an additional feature vector which can represent some spatial relationships.

=== Message Passing Framework

The majority of modern GNN architectures employ the message passing paradigm, in which node representations are updated iteratively by exchanging information with neighboring nodes.

At each sequential layer $k$, the message passing procedure consists of three steps:

#v(1em)

*1. Message Computation*

$ m_(u->v)^((k)) = M^((k))(h_v^((k)), h_u^((k)), e_((u v))) $

where:

$m_(u->v)^((k))$ - directional message sent from node $u$ to node $v$ at layer $k$

$M^((k))(dot.c)$ - learnable message function that computes the information propagated between neighboring nodes

$h_v^((k)) in RR^d$ - $d$ dimensional feature embedding of node $v$ at layer $k$

$e_((u v))$ - optional feature vector associated with edge $(u,v)$

#v(1em)

*2. Aggregation*

$ a_v^((k)) = sum_(u in N(v)) m_(u->v)^((k)) $

where:

$a_v^((k))$ - aggregated information received by node $v$

$N(v)$ - set of neighboring nodes of node $u$

#v(1em)

*3. Update*

$ h_v^((k+1)) = U^((k))(h_v^((k)), a_v^((k))) $

where:
 
$U^((k))(dot.c)$ - learnable update function, combines aggregated neighborhood information with node's current state

#v(1em)

The aggregation operator must be permutation invariant, meaning that the resulting node representation should not depend on the order in which neighboring nodes are processed. After $K$ message-passing layers, each node embedding contains information from its $K$-hop neighborhood. This follows from the fact that information is propagated across at most one edge per layer in standard message passing architectures.

Numerous GNN architectures have been proposed, varying primarily in the way messages are computed, aggregated, and used to update node representations. Examples include Graph Convolutional Networks (GCNs), Graph Attention Networks (GATs), GraphSAGE, and Transformer-based architectures such as the attention-based encoder used in @Kool. While many GNNs follow the message passing paradigm, Transformer-based models exchange information through self-attention rather than explicit neighborhood aggregation. 
Despite this difference in implementation, they pursue the same objective of learning expressive representations of graph-structured data and can still be regarded as Graph Neural Networks under the broad definition adopted in this thesis.

=== Self-Attention Mechanism

Attention in neural networks is a mechanism that enables the model to focus on the parts of the input that are most relevant when making a prediction. It assigns a weight to each input token, indicating its relevance to other tokens in the sequence. This allows the model to selectively aggregate contextual information instead of treating all input elements equally, leading to richer representations and more accurate predictions. The attention mechanism forms the foundation of the Transformer architecture.

There are many variants of attention mechanisms. This section focuses on the scaled dot-product attention introduced by Vaswani et al. @Vaswani, which forms the core building block of the Transformer architecture.

For each input token, three vectors are computed through learnable linear projections: a query ($Q$), a key ($K$), and a value ($V$). These vectors are then used to enrich its embedding with contextual information from the entire input sequence. Specifically, the query vector is compared with the key vectors of all input tokens to determine their relevance. Tokens that receive higher attention scores contribute more to the updated embedding through their corresponding value vectors.

Mathematically, attention is computed by taking the scaled dot product between the query and key vectors, producing a similarity score that reflects how strongly two tokens are related in the given context:

$ "Attention"(Q, K, V) = "softmax"("QK"^T/sqrt(d_k))V $

where $d_k$ is the dimensionality of the key vectors. The softmax function converts the similarity scores into a probability distribution, allowing the attention mechanism to assign normalized weights to all input tokens while remaining fully differentiable.

Modern architectures typically employ multiple attention heads instead of a single one. The input embeddings are projected multiple times, once for each attention head, using independent sets of query, key, and value projections. Each attention head learns to capture different contextual characteristics and relationships within the input sequence. Finally, the outputs of all attention heads are concatenated and linearly projected to produce the final embedding.

In the classical attention mechanism, commonly referred to as cross-attention, the query vectors are produced by the decoder, while the key and value vectors originate from the encoder. Consequently, the decoder attends to the encoded input representation when generating the output.
In self-attention, the query, key, and value vectors are all computed from the same input embeddings. As a result, each input element attends to every other element in the sequence, allowing its representation to be enriched with contextual information. This property gives rise to the term self-attention.

When applied to graph neural networks, self-attention enables each node embedding to incorporate information from all other nodes in the graph. Since attention operates on a set of node embeddings rather than on their ordering, it is permutation-equivariant, making it particularly well suited for routing problems, where the order of customers in the input should not affect the solution.

The attention-based encoder proposed by Kool et al. @Kool is based on stacked multi-head self-attention layers. In this thesis, the architecture of this encoder serves as the baseline for the proposed CGP-based Neural Architecture Search method.

=== Graph Neural Networks in VRP

Graph Neural Networks are widely used to solve graph-based combinatorial optimization problems such as the Traveling Salesman Problem (TSP) and the Vehicle Routing Problem (VRP), as their architecture naturally aligns with the structure of these problems. In such settings, nodes typically represent cities or customers, while edges represent distances or travel costs.

GNN-based models are able to capture both local neighborhood information and global graph structure, which makes them well suited for combinatorial optimization problems such as TSP and CVRP.

One of the most common neural architectures for these tasks is the encoder–decoder framework. In this setup, the encoder processes the input graph and produces node embeddings that serve as latent representations of the graph structure. The decoder then uses these embeddings to iteratively construct a solution, typically in an autoregressive manner, by selecting one node at a time. This architecture is employed by the model proposed in @Kool, which serves as the baseline throughout this thesis.

== Reinforcement Learning for Routing

=== Reinforcement Learning

Reinforcement Learning is a machine learning approach in which an agent makes decisions and learns based on the environment's response. At each step, the agent chooses an action given the current state, performs the selected action, and receives a reward that reflects the quality of the decision. The goal is to learn a policy that maximizes the expected cumulative reward over the entire sequence of decisions, which in combinatorial optimization is often sparse and delayed, as it is evaluated only after the entire sequence of decisions is completed. The model learns through trial and error, balancing the exploration of new action sequences and the exploitation already known trajectories.

In contrast to supervised learning, reinforcement learning does not require knowledge of optimal solutions, which makes it particularly suitable for tackling combinatorial optimization problems such as the VRP and its variants. For these NP-hard problems, generating exact baseline solutions for large instances is computationally infeasible. Such problems can be naturally formulated as sequential decision-making processes and modeled as a Markov Decision Process (MDP).

A CVRP can be formulated as Markov Decision Process (MDP) in form of a tuple $(S, A, P, R, gamma)$, where: 
- $S$ - state space, where each state represents partially constructed route and encompasses variables like remaining vehicles capacity
- $A$ - action space, an action represent selecting a next node on the route
- $P$ - transitions dynamics, in case of CVRP each transition $P(s_(t+1)|s_t, a_t)$ is deterministic, and the next state $s_(t+1)$ is uniquely determined by applying action $a_t$ to the current state $s_t$
- $R$ - reward function, calculated at the final step when all routes are constructed and applied to all decisions in sequence, intermediate rewards are set to 0
- $gamma$ - discount factor equal to $1$, this ensures that all decisions taken at any stage of the route construction are given the same weight

At each time step $t$, the agent sequentially selects the next node to visit according to its policy until a complete, valid route is constructed and all constraints are satisfied

=== Policy Gradient Optimization

The entire decision process is modeled as parametrized stochastic policy:
$ pi_theta (a|s) $ where $theta$ are the trainable network parameters. The policy defines a probability distribution over all feasible actions that can be selected in a given state $s$.

A complete solution to the routing problem has the form of a trajectory:
$ tau = (s_1, a_1, dots, s_T, a_T) $

The goal is to find such $theta$ that maximize the expected reward:
$ J(theta) = EE_(tau ~ pi_theta)[R(tau)] $

In CVRP the reward usually corresponds to negative total route length, which makes reward maximization equivalent to minimizing total route cost.

Because the action space in CVRP involves making discrete decisions at each step and the reward function is not differentiable with respect to the network parameters $theta$, standard gradient descent cannot be applied directly. Instead, policy gradient methods such as the REINFORCE algorithm are used.
The gradient of the objective function is estimated as:

$ gradient_theta J(theta) = EE_(pi_theta)[(R(tau) - b) sum_(t=1)^T gradient_theta log pi_theta (a_t|s_t)] $

where $b$ is a baseline used to reduce the variance of the gradient estimate and improve training stability. A baseline serves as a reference value and is typically obtained either as a running average of previously observed returns or as the output of a separate learned value function (critic) that estimates the expected return for a given state or problem instance.

Instead of learning directly from the reward, the optimization is driven by the advantage:
$ A(tau) = R(tau) - b $

The advantage indicates whether the sampled solution is better or worse than expected. A positive advantage increases the probability of selecting similar actions in the future, while a negative advantage decreases it.

In practice, the expected value of the objective function cannot be computed exactly because of the enormous state and action spaces. Therefore, it is typically approximated using Monte Carlo sampling over trajectories, or more generally using sampling-based estimators such as actor-critic methods.

=== Routing Models

Modern reinforcement learning techniques for routing problems typically use an encoder-decoder architecture. The role of the encoder is to transform the input graph into node embeddings, which are internal vector representations of the graph and its structure. Based on these embeddings, the decoder constructs the route sequentially, one step at a time, in an autoregressive manner. Route construction starts at the depot and is completed when all customers have been visited. At each step, the decoder makes a decision based on the current state of the partially constructed solution and the graph representation encoded by the node embeddings.

To ensure that only feasible solutions are generated, the policy uses action masking to eliminate invalid actions. Customers that have already been visited or whose demand exceeds the remaining vehicle capacity are removed from the set of candidate actions before the action probabilities are computed.

Inference is usually performed using a greedy strategy, where at each step the action with the highest probability is selected. It is a computationally efficient strategy and often provides high-quality solutions. However, it is worth noting that other decoding strategies can also be used, such as stochastic sampling, where each action is sampled from the predicted probability distribution, or beam search, which keeps multiple partial solutions at each step and expands only the most promising ones.

== Neural Architecture Search (NAS)

Designing effective neural network architectures is not a trivial task, and there are many cases where advances in this area become a breakthrough for the entire field, such as when the Transformer architecture and the multi-head attention mechanism were introduced. Neural Architecture Search (NAS) is a technique for automatically discovering efficient neural network architectures. It can be used to generate architectures that match or outperform those manually designed, as well as to efficiently explore a large architectural search space. NAS can also help find custom architectures tailored to a specific problem to which a machine learning model is applied, without requiring extensive domain knowledge from the engineer.

It is a subfield of Automated Machine Learning (AutoML), which aims to automate the application of machine learning paradigms to real-world problems.

NAS methods can be analyzed from three perspectives:
+ Search space
+ Search strategy
+ Performance estimation strategy


The *search space* defines the set of all valid architectures that a NAS method can discover. It specifies the design choices that can be optimized, such as connectivity patterns, types of operations, network depth, and other architectural components. There is a trade-off between the expressiveness of the search space and its computational cost. A larger search space provides greater flexibility and allows the discovery of more specialized architectures, but it also increases the computational cost and time required for the search. Some methods search over the entire network topology, deciding how each layer or block is connected, while others focus only on specific architectural components, such as activation functions or convolutional kernels, leaving the overall architecture unchanged.

The *search strategy* determines how the search space is explored. One of the most common search strategies is based on evolutionary algorithms, where each architecture is represented by a genotype. The best-performing architectures are selected for reproduction and undergo mutation, while the least effective ones are discarded. Cartesian Genetic Programming (CGP), which is used in this thesis, belongs to this category. Other notable search strategies include gradient-based methods, reinforcement learning, and random search.

Candidate architectures generated by a NAS method must be evaluated to estimate their performance. Since training every candidate from scratch is computationally expensive, various *performance estimation strategies* are used to obtain an approximate evaluation that is sufficient for ranking architectures. Such approaches are commonly referred to as proxy techniques and include methods such as training for fewer epochs, using smaller datasets or batch sizes, and weight sharing. In some cases, a separate auxiliary model is trained to predict the performance of candidate architectures.

== Cartesian Genetic Programming (CGP)

Cartesian Genetic Programming (CGP) is a variant of genetic programming introduced by Miller @MillerCGP. It represents a computational structure as a directed acyclic graph arranged on a two-dimensional grid, hence the name Cartesian. CGP is a general-purpose representation that can be applied to a wide range of problems, including image filtering, digital circuit design, game-playing agents @CGPAtari, and neural architecture search.

=== Representation

The genotype has a fixed length determined by the number of rows and columns in the grid. Each node in the grid represents a primitive computational unit, such as a mathematical function, a logical operator, or a neural network component.

Each node corresponds to a gene defined by its function type and the indices of its input connections. The position of a gene in the genotype determines the identifier of the corresponding node in the graph. Connections are restricted such that nodes can only receive inputs from previous nodes in the grid, ensuring that the resulting structure is a directed acyclic graph.
Designated output nodes define the final outputs of the computational graph.

Each gene can be represented as a tuple: 
$ ("TYPE", ["INPUTS"]) $ 

where $"TYPE"$ denotes the operation performed by the node, and $"INPUTS"$ specifies the indices of its input nodes.

#let cgp_fig1= figure(image("../images/cgp1.png", width: 100%), caption: flex-caption(
  [General form of CGP from @MillerCGP2],
  [General form of Cartesian Genetic Programming, 2-dimensional grid],
))
#cgp_fig1 <cgp_figure>

=== Evolution

In contrast to most genetic algorithms, which rely on both crossover and mutation, CGP typically operates using purely mutation-based evolution. This stems from the fact that crossover operations are often destructive for graph structures and rarely preserve meaningful functional substructures.

The most common evolutionary algorithm for CGP is the $(1 + lambda)$ strategy, where in each generation a single parent generates $lambda$ offspring through mutation. The best-performing individuals are then selected for the next generation, while the remaining candidates are discarded. Mutation can affect node functions, input connections, or both, introducing structural variation in the computational graph.

What is characteristic of CGP is that the phenotype can differ from the genotype. Because of the graph structure, only a subset of nodes takes part in the computation. This creates room for structural redundancy and neutral drift. Neutral drift is a key component of CGP and occurs when a mutation affects an inactive gene, resulting in the offspring having the same fitness as its parent. In this case, the child is always preferred, which allows the search process to better explore the search space.