#import "../utils.typ": todo, silentheading, flex-caption
= Introduction

== Background and Motivation

The @vrp is one of the most widely known problems in combinatorial optimization @DantzigRamser. Due to its practical and industrial applications across logistics and transportation, it is well researched and widely studied. Even small improvements in the total length of vehicle routes can result in significant savings at an industrial scale.

While there are many variants of the @vrp, in this work we study the @cvrp, where each vehicle has a limited load capacity that cannot be exceeded. This variant combines relative simplicity with practical constraints and is representative of real-world routing problems @VRP_overview.

The problem is NP-hard, which means that calculating optimal solutions using exact methods for real-world-sized instances is often infeasible @VRP_nphard. Hence, a wide range of heuristics, metaheuristics, and hybrid heuristic methods have been developed. Among the most notable are Lin-Kernighan-Helsgaun (LKH-3) @LKH3 and Hybrid Genetic Search (HGS-CVRP) @Vidal, which are capable of producing near-optimal solutions within relatively short computation times.

Due to the rising popularity of @ml in recent years, there have been numerous attempts to apply @ml and @gnn:pl to routing problems, including @cvrp. While exact methods and heuristic approaches solve individual problem instances, @ml models attempt to learn a policy that generalizes across a distribution of instances. Once trained, such models can produce solutions with relatively low inference cost and execution time.

@gnn:pl are particularly well suited for routing problems because they can naturally operate on graph-structured data and capture relationships between nodes and edges. This makes them a promising tool for learning representations of routing problems directly from data.

One of the most popular machine learning approaches involves using @rl to learn a decision policy and construct routes through an autoregressive model. Such approaches typically employ an encoder-decoder architecture, where the encoder creates an internal representation of the problem using embeddings, while the decoder constructs a solution step by step by selecting the next node in the route. This approach is used by Kool et al. @Kool.
Their model serves as the primary baseline in this thesis.

Such GNN-based models often rely on relatively generic neural architectures. In particular, the encoder used in @Kool is based on the original transformer architecture introduced by Vaswani et al. @Vaswani. While such architectures have proven highly effective across many domains, it remains an open question whether more specialized architectures tailored specifically to routing problems could achieve better performance.

While neural network architectures are often designed manually, there also exist methods for automatically discovering new architectures. This task is addressed by @nas, a family of techniques aimed at automating the design of neural network architectures. @nas methods have demonstrated promising results in various domains, reducing the need for manual architecture engineering and, in some cases, discovering architectures that outperform manually designed alternatives @NAS_survey. However, applying @nas to @gnn:pl for combinatorial optimization problems remains computationally expensive, which motivates the use of constrained search spaces and efficient evolutionary strategies.

This work investigates a @nas approach based on @cgp @MillerCGP for evolving @gnn architectures. @cgp employs a graph-based representation in the form of a two-dimensional computational grid, making it well suited for representing @gnn:pl, which can naturally be viewed as computational graphs.
This representation allows a direct mapping between neural network structures and evolutionary individuals, enabling flexible exploration of complex architectural designs.

The main motivation of this thesis is to investigate whether CGP-based @nas can be effectively applied to the encoder of the attention-based model proposed by Kool et al. for the @cvrp and whether it can discover promising alternative architectures.

== Scope

This thesis focuses on the application of @nas to @gnn models used for solving the @cvrp. The study is limited to the @cvrp and does not consider other variants of the @vrp. The primary focus is on evaluating the effectiveness of CGP-based architecture search rather than achieving state-of-the-art routing performance.

The scope of the thesis includes the development and evaluation of a CGP-based @nas method. The proposed approach uses @cgp to evolve the encoder architecture of the attention-based model proposed by Kool et al. @Kool. This involves defining the set of available neural network operators and building blocks, designing the @cgp representation and search space, and selecting the parameters controlling the evolutionary process.

The architecture search is limited to the encoder of the model. The decoder architecture, reinforcement learning framework, and general training procedure of the original model remain unchanged. This isolates the encoder architecture as the main subject of the search and allows the impact of architectural modifications to be evaluated independently of changes to other components of the model.

The evaluation covers both the effectiveness of the proposed search method and its ability to evolve the baseline architecture. The CGP-based search is first evaluated against randomly generated architectures under the same computational budget. The method is then applied to the original transformer-based encoder, which serves as the starting point for the evolutionary search, to investigate whether @cgp can discover effective modifications of its architecture. The resulting architectures are compared with the original transformer encoder on fixed test datasets for CVRP10, CVRP20, CVRP50, and CVRP100.


== Research Objectives and Questions

#let rq(number, body) = block(
  inset: (left: 1em),
  stroke: (left: 2pt + rgb("#555555")),
  [
    *RQ#number.* #emph(body)
  ]
)

The primary aim of this thesis is to investigate whether @cgp can be used as an effective @nas method for @gnn:pl applied to the @cvrp. The work focuses on determining whether evolutionary search can be used to automatically discover effective encoder architectures for a learning-based routing model.

To achieve this objective, the thesis addresses the following research questions:

#rq(1)[
  Can CGP-based architecture search consistently discover
  better encoder architectures than random search
  under the same search space and computational budget?
]

This question evaluates whether the evolutionary search process can effectively exploit information gathered during evolution rather than behaving similarly to random exploration of the architecture space.

#rq(2)[
  Can CGP-based architecture search evolve the original transformer-based encoder to improve its routing performance?
]

This question evaluates whether @cgp can discover effective modifications of an existing, manually designed architecture. The original transformer-based encoder serves as the starting point of the evolutionary search, and the resulting architectures are evaluated across different @cvrp problem sizes.

The central hypothesis of this thesis is that CGP-based @nas can effectively guide the exploration of the architectural search space, outperform random search, and discover effective modifications of the original transformer-based encoder.