#import "../utils.typ": todo, silentheading, flex-caption
= Introduction

== Background and Motivation

The Vehicle Routing Problem (VRP) is one of the most widely known problems in combinatorial optimization. Due to its practical and industrial applications across logistics and transportation, it is well researched and widely studied. Even small optimizations in the total length of vehicle routes can result in significant savings at an industrial scale.

While there are many variants of the VRP, in this work we study the Capacitated Vehicle Routing Problem (CVRP), where each vehicle has a limited load capacity that cannot be exceeded. This variant combines relative simplicity with practical constraints and is representative of real-world routing problems.

The problem is NP-hard, which means that calculating optimal solutions using exact methods for real-world-sized instances is often infeasible. Hence, a wide range of heuristics, metaheuristics, and hybrid heuristic methods have been developed. Among the most notable are Lin-Kernighan-Helsgaun (LKH-3) and Hybrid Genetic Search (HGS-CVRP), which are capable of producing near-optimal solutions within relatively short computation times.

Due to the rising popularity of Machine Learning in recent years, there have been numerous attempts to apply Machine Learning and Graph Neural Networks (GNNs) to routing problems, including CVRP. While exact methods and heuristic approaches solve individual problem instances, machine learning models attempt to learn a policy that generalizes across a distribution of instances. Once trained, such models can produce solutions with relatively low inference cost and execution time.

Graph Neural Networks are particularly well suited for routing problems because they can naturally operate on graph-structured data and capture relationships between nodes and edges. This makes them a promising tool for learning representations of routing problems directly from data.

One of the most popular machine learning approaches involves using Reinforcement Learning to learn a decision policy and construct routes through an autoregressive model. Such approaches typically employ an encoder-decoder architecture, where the encoder creates an internal representation of the problem using embeddings, while the decoder constructs a solution step by step by selecting the next node in the route. This approach is used in the paper "Attention, Learn to Solve Routing Problems!", whose model serves as the primary baseline in this thesis.

Such GNN-based models often rely on relatively generic neural architectures. In particular, the encoder used in "Attention, Learn to Solve Routing Problems!" is based on the original Transformer architecture introduced in "Attention Is All You Need". While such architectures have proven highly effective across many domains, it remains an open question whether more specialized architectures tailored specifically to routing problems could achieve better performance.

While neural network architectures are often designed manually, there also exist methods for automatically discovering new architectures. This task is addressed by Neural Architecture Search (NAS), a family of techniques aimed at automating the design of neural network architectures. NAS methods have demonstrated promising results in various domains, reducing the need for manual architecture engineering and, in some cases, discovering architectures that outperform manually designed alternatives. However, applying NAS to Graph Neural Networks for combinatorial optimization problems remains computationally expensive, which motivates the use of constrained search spaces and efficient evolutionary strategies.

This work investigates a NAS approach based on Cartesian Genetic Programming (CGP) for evolving Graph Neural Network architectures. CGP employs a graph-based representation in the form of a two-dimensional computational grid, making it well suited for representing Graph Neural Networks, which can naturally be viewed as computational graphs.
This representation allows a direct mapping between neural network structures and evolutionary individuals, enabling flexible exploration of complex architectural designs.

The main motivation of this thesis is to investigate whether a CGP-based NAS method can discover improved encoder architectures for Graph Neural Networks applied to the Capacitated Vehicle Routing Problem.

== Scope

This thesis focuses on the application of Neural Architecture Search (NAS) to Graph Neural Networks used for solving the Capacitated Vehicle Routing Problem (CVRP). The objective is to investigate whether the architecture of an existing model can be improved through evolutionary search using a specially designed evolutionary method.

The work builds upon the model introduced in "Attention, Learn to Solve Routing Problems!", which serves as the baseline architecture throughout this study. Only the encoder component of the model is evolved. This reduces the size of the search space and isolates the impact of architectural modifications. The decoder architecture, training procedure, and reinforcement learning framework remain unchanged.

The architecture search is performed using a NAS method based on Cartesian Genetic Programming (CGP). Candidate architectures are represented as computational graphs composed of predefined building blocks and are evolved using mutation-based search operators. Each block represents a single operation, such as ReLU, GELU, scaling, or other transformations applied to node embeddings.

Due to the high computational cost associated with training and evaluating neural architectures, a proxy evaluation strategy is employed. Candidate architectures are initially ranked using smaller CVRP instances and reduced training budgets. This approach assumes that architectures performing well under proxy conditions are likely to maintain their relative performance when evaluated under more computationally demanding settings.

The scope of this work is limited to the CVRP and does not consider other variants of the Vehicle Routing Problem. Furthermore, the study focuses on evaluating the effectiveness of CGP-based architecture search rather than achieving state-of-the-art routing performance. The evolved architectures are compared against both randomly generated architectures and the original encoder architecture of the baseline model.


== Research Objectives and Questions

The primary aim of this thesis is to investigate whether Cartesian Genetic Programming (CGP) can be used as an effective Neural Architecture Search method for Graph Neural Networks applied to the Capacitated Vehicle Routing Problem (CVRP). The work focuses on determining whether evolutionary search can be used to automatically discover effective encoder architectures for a learning-based routing model.

To achieve this objective, the work addresses two main questions. First, whether CGP-based search is capable of consistently discovering architectures that outperform randomly generated encoder architectures when both approaches are allocated the same computational budget. This serves as a validation that the search process is able to exploit information gathered during evolution and is not equivalent to random exploration of the search space.

Second, the study investigates whether the architectures discovered through CGP can improve upon the manually designed Transformer-based encoder used in the baseline model. This evaluates the ability of evolutionary search to discover architectural structures that are better suited to the CVRP than a widely adopted handcrafted design.

The central hypothesis of this thesis is that CGP-based Neural Architecture Search can effectively guide the exploration of the architectural search space, producing encoder architectures that outperform randomly generated alternatives and potentially improve upon the baseline Transformer encoder.