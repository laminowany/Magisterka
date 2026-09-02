#import "../utils.typ": todo, silentheading, flex-caption, algorithm, comment

= Methodology <methodology>

== Overview

To evaluate the effectiveness of the CGP-based NAS approach in a controlled setting, this thesis focuses on the @cvrp as the target optimization problem and uses the attention-based model proposed by Kool et al. as the baseline @Kool.
The @cvrp is a well-established and extensively studied routing problem. The model introduced by Kool et al. has been influential in the development of learning-based approaches to routing problems and provides a relatively simple and clearly structured architecture. In particular, its separation into encoder and decoder components makes it well suited for controlled architectural modifications.

To isolate the effect of architecture search, the evolutionary process is restricted to the encoder. The decoder, reinforcement learning framework, and other components of the baseline model remain unchanged. Thanks to that, differences in routing performance can be attributed primarily to changes in the encoder architecture rather than to modifications of the overall solution framework.

The method implemented in this thesis uses @cgp to explore the search space of alternative encoder architectures. Candidate encoders are represented as directed acyclic computational graphs encoded in the form of a @cgp genome. The @nas operates directly on this representation by modifying the operations of individual nodes and the connections between them.

The overall CGP-based architecture search procedure is summarized in @concept

#algorithm(caption: [General concept of proposed CGP-NAS method])[
  + _parent_ = #smallcaps[initialize_parent];()
  + _parentScore_ = #smallcaps[evaluate];(parent)
  + *while* _budgetRemaining_ > 0 *do*
      + _children_ = #smallcaps[produce_offspring];(_parent_)
      + *for each* _child_ *in* _children_
        + *if*  #smallcaps[phenotypes_match];(_child_, _parent_)
          + _childScore_ = _parentScore_
        + *else*
          + _childScore_ = #smallcaps[evaluate];(_child_)
          + _budgetRemaining_ = _budgetRemaining_ - 1
        + *if* _childScore_ <= _parentScore_
          + _parent_ = _child_ 
          + _parentScore_ = _childScore_
  + *return* _parent_
]<concept>


At the beginning, the first parent is initialized and its fitness score is calculated.

Then, the evolutionary process takes place until the computational budget is exhausted. The computational budget is represented as an integer value, where training and evaluating a single architecture consumes one unit of the budget.

As long as there is remaining budget, candidate architectures are generated as offspring of the parent through mutation, which is described in more detail in a later section. A characteristic property of @cgp is that not all blocks encoded in the genome take part in the computation. Some of them are inactive, which means that the genotype may differ without changing the expressed phenotype. If an offspring's phenotype is identical to that of its parent, no evaluation is required and the offspring inherits the score of its parent. This not only allows neutral drift but also prevents the computational budget from being consumed by evaluations of identical architectures. Such neutral mutations are an important property of @cgp and allow the search to explore substantial regions of the search space.

If an offspring achieves the same or a better score than its parent, it becomes the parent for the next generation. The entire process is repeated until the computational budget is exhausted.

The description of this method can be decomposed into three parts:
1. Architecture Representation
2. Evolutionary Search
3. Candidate Evaluation

The remainder of this chapter discusses these components in more detail.

== Architecture Representation

=== Genome 

Candidate encoder architectures are represented using the @cgp encoding.
A genome consists of a sequence of genes that encode a directed acyclic computational 
graph whose nodes are arranged on a two-dimensional rectangular grid. Each gene describes a 
single computational block and therefore corresponds to one node of the computational graph.

$ "GENOME" quad := quad ["GENE", quad ...] $

Every node is implicitly assigned a unique identifier according to its position in the genome. These identifiers are subsequently used to specify connections between computational blocks. Numbering starts from *1*, while *0* is reserved to represent the input of the neural network. Consequently, any connection referencing node *0* receives the original network input rather than the output of another computational block.

A gene is represented as a tuple of the following form:
$ "GENE" quad := quad ("TYPE", quad ["INPUTS"], quad "ARGUMENT?") $

where:

$"TYPE"$ - the type of the computational block

$"INPUTS"$ - list of identifiers specifying the inputs to the block

$"ARGUMENT"$ - operation-specific parameter if required by the selected block type

=== Computational Blocks

Each node in a @cgp genome represents a single computational block. In classical @cgp, these blocks often represent mathematical operations, such as addition or multiplication.
In the context of neural networks, each block represents a standalone neural network component that performs an operation on its input and passes the resulting representation to subsequent computational blocks.

The choice of computational block types is crucial, as it defines the search space and limits the architectures that the search can discover. In this thesis, we decided to use seven types of computational blocks. The selected blocks provide sufficient diversity of operations while keeping their number relatively small, preventing the search space from becoming excessively large. They include operations commonly used in neural network architectures while allowing the evolutionary process to modify feature transformations, attention, nonlinearities, and the connectivity between different computational paths.

Type of computational blocks:
1. *Identity* - return the input unchanged.
2. *Normalization* - applies layer normalization to stabilize the feature distribution.
3. *Linear Scaling* – applies a learnable linear transformation whose output dimension is determined by the scaling argument. 

  The embedding dimension can be increased by a factor of four, reduced by a factor of four, or left unchanged depending on the value of ARGUMENT:

    - *-1*:  reduces the embedding dimension by a factor of four (down to a minimum of 8)
    - *0*:  preserves the embedding dimension
    - *1*:  increases the embedding dimension by a factor of four (up to a maximum of 4096)
  *Linear Scaling* block is the only one that takes argument.

The factor of four was chosen arbitraly to provide a sufficiently large change in the embedding dimension while avoiding excessively large differences between computational blocks.

4. *Multi-Head Attention* - performs multi-head self-attention over the input representations
5. *Add* - projects all input tensors to a common embedding dimension if needed, and returns their element-wise sum. *Add* is the only block that can accept more than one input.
6. *GELU* - applies the Gaussian Error Linear Unit activation function.
7. *ReLU*- applies the Rectified Linear Unit activation function.

Together, these computational blocks allow the search to construct a variety of encoder architectures, including structures resembling the original transformer encoder as well as substantially different computational graphs.

=== Structural Constraints <constraints>

The genome representation is subject to several structural constraints. Although the computational graph is arranged on a two-dimensional grid of size $N times M$, the genome contains $N dot M + 1$ genes. The additional gene represents the output of the entire network and is always of type *Add*, allowing it to aggregate one or more outputs produced by the last column of computational blocks. 

The input embedding initially has a fixed dimensionality. However, the *Linear Scaling* block may increase or decrease the embedding dimension along individual branches of the computational graph. Consequently, tensors arriving at an *Add* block may have different dimensionalities. To ensure compatibility, the *Add* block first projects each input back to the target embedding dimension of the model using a learnable linear transformation whenever necessary, and only then computes their element-wise sum.

Every node may receive inputs only from nodes in the immediately preceding column. This restriction limits the connectivity of the computational graph and prevents connections from skipping intermediate columns. Nodes in the first column receive the original network input. The output gene can be considered an additional node placed after the final column and may therefore receive inputs from nodes in that column.

Finally, the *Add* block is the only computational block that may accept multiple input connections. All remaining blocks operate on a single input tensor.

=== Genotype to Phenotype Mapping

Not all genes contained in a @cgp genome necessarily participate in the resulting neural network. While the genotype contains all genes defined by the grid, only a subset of them may contribute to the network output. This active subset forms the phenotype of the candidate architecture.

During decoding, traversal starts from the output gene and recursively follows all referenced input connections. Only visited genes are considered active and are instantiated as computational blocks. Genes that are not reachable from the output gene are considered inactive and do not contribute to the resulting neural network.
Each active gene is instantiated as the computational block specified by its type, while the connectivity of the neural network is reconstructed from the input references stored in the genome.

As a result, different genotypes may represent the same phenotype if their differences occur only in inactive genes. This property plays an important role in the evolutionary search, as mutations affecting inactive genes do not modify the expressed neural network and therefore constitute neutral mutations.

=== Examples

The following examples illustrate the genome representation and its mapping to the corresponding computational graph. The first example shows a genome in which all genes are active, while the second demonstrates the effect of inactive genes on the resulting phenotype.

==== Example 1

Consider the following genome of length $5$, representing a $2 times 2$ grid:
$ (2, [0]), (7, [1]), (5, [0]), (4, [3]), (5, [2, 4]) $

which corresponds to the following computational graph:

1. Block 1 - *Normalization* (type 2), network input (0)
2. Block 2 - *ReLU* (type 7), input from node 1
3. Block 3 - *Add* (type 5), network input (0)
4. Block 4 - *Multi-Head Attention* (type 4), input from node 3
5. Block 5 - *Add* (type 5), input from nodes 2 and 4

#let genome1= figure(image("../images/genome1.png", width: 80%), caption: flex-caption(
  [Example of genome 1],
  [Example of genome 1],
))
#genome1 <genome1_figure>

@genome1_figure illustrates the corresponding computational graph. Node *0* represents the network input, while the final *Add* node represents the network output.

In this example, all genes are active and participate in the resulting neural network. Therefore, the entire genotype is expressed in the phenotype. 

==== Example 2

In this example, the genome also has length $5$ and represents a $2 times 2$ grid:

$ (2, [0]), (2, [1]), (2, [0]), (3, [1], 1), (5, [4]) $

which can be decoded into the following computational graph:

1. Block 1 - *Normalization* (type 2), network input (0)
2. Block 2 - *Normalization* (type 2), input from node 1
3. Block 3 - *Normalization* (type 2), network input (0)
4. Block 4 - *Linear Scaling* (type 3), input from node 1, scaling dimensions up (1)
5. Block 5 - *Add* (type 5), input from node 4

#let genome2= figure(image("../images/genome2.png", width: 80%), caption: flex-caption(
  [Example of genome 2],
  [Example of genome 2],
))
#genome2 <genome2_figure>

As shown in @genome2_figure, not all genes are active. 
Since the network output depends only on node *4*, nodes *2* and *3* are never 
visited during the decoding process and are therefore excluded from the phenotype. 
As a result, the decoded neural network contains only the active subset of the genome. 

== Evolutionary Search

Once candidate architectures are represented as @cgp genomes, the resulting search space is explored through an evolutionary process. Starting from a single parent architecture, new candidates are generated through mutation and evaluated according to their fitness. Based on these evaluations, the search progressively explores different regions of the architecture space while retaining promising solutions.

The evolutionary process consists of several components described in the following sections: 
- the evolutionary strategy
- initialization of the parent architecture
- mutation procedure
- neutral drift
- partial weight inheritance

=== Evolutionary Strategy

The evolutionary search used in this thesis follows the standard $(1+lambda)$ evolutionary strategy commonly used in @cgp, including in the original formulation by Miller and Thomson @MillerCGP. During each iteration, the current parent is mutated to generate $lambda$ offspring. Each offspring is decoded into a neural network, trained, and evaluated to determine its fitness.

After all offspring have been evaluated, the best candidate is compared with the current parent. If its fitness is better than or equal to that of the parent, it replaces the parent in the next iteration. Otherwise, the parent is retained. This process continues until the predefined computational budget is exhausted.

Allowing offspring with equal fitness to replace the parent enables neutral changes in the genotype to propagate between generations. The role of such neutral mutations is discussed in more detail in @drift.

=== Initial Parent

The evolutionary search starts from a single parent genome, which serves as the initial solution for the optimization process. The choice of the initial parent can influence both the convergence speed and the quality of the final architecture.

The method is independent of the initialization strategy used to generate the initial parent. The parent genome may either be generated randomly or constructed from a predefined neural network architecture. A randomly generated parent encourages exploration of the search space from scratch, whereas initialization from an existing high-performing architecture allows the evolutionary process to focus on incremental modifications of a strong baseline. In this thesis, both initialization strategies are evaluated experimentally and compared in the following chapters.

=== Mutation

==== Overview

Mutation is the only search operator used to explore the search space.
Each offspring is generated as a copy of the current parent and subsequently modified through a sequence of mutations. The number of mutations is determined by the proportion of the remaining computational budget to the total budget and follows an exponential decay schedule.
As the search progresses and the remaining budget decreases, the number of mutations applied to each offspring also decreases. At least one mutation is always applied when generating an offspring.

The entire procedure of mutating a candidate genome can be summarized in three steps:

1. Calculate the number $m$ of genes to mutate based on the remaining computational budget, as described in @mutation_rate.
2. Select $m$ genes to be mutated by sampling from the genome without replacement.
3. For each selected gene, perform either a type mutation or an input mutation, as described in @gene_mutation.

All mutations are generated so that the structural constraints described in @constraints remain satisfied. 
Consequently, every offspring can be decoded into a valid computational graph. 
Nodes in the first column cannot undergo input mutation, as their only valid predecessor 
is the network input. 
The output gene, in contrast, has a fixed block type and may only undergo input mutation.

==== Mutation Rate <mutation_rate>

The implemented CGP-based NAS method does not use a fixed grid size, as its dimensions are parameterized. Therefore, the number of mutated genes is calculated relative to the total genome length rather than being defined as an absolute value.

Specifically, the number of mutated genes is computed as: 
$ "m" = max(1, floor(0.5 dot (|G| - 1) dot e^(-k  (1-r)) )) $ <mut_k>
where $|G|$ denotes the genome length, $k$ is the decay coefficient, and
$ r = B_"remaining" / B_"total" $ 
is the fraction of remaining computational budget.

This allows the search to perform larger modifications during the early stages
of evolution, encouraging broad exploration of the search space, while gradually
shifting towards smaller modifications that exploit the neighbourhood of 
high-performing solutions.
A higher mutation rate at the beginning of the search is particularly beneficial
when the initial parent is generated randomly, as it helps the evolutionary process
escape poor local optima before focusing on fine-grained improvements later on.

==== Gene Mutation <gene_mutation>

Each selected gene undergoes either a type mutation or an input mutation.

The probability of selecting an input mutation depends on the number of rows in the grid and the number of available block types. The number of rows is used as an approximation of the number of possible input connections. Strictly speaking, the number of possible input mutations may be larger because the *Add* block can accept multiple inputs.

The probability of selecting an input mutation is given by:

$ P("input mutation") = R / (R + 7) $

while the probability of selecting a type mutation is:

$ P("type mutation") = 7 / (R + 7) $

where $R$ is the number of rows in the grid.

Once the mutation type is selected, the new input connection or block type is sampled uniformly from the corresponding set of valid choices.

When *mutating input connections*, the number of inputs depends on the block type.
Most computational blocks always receive exactly one input connection.
The *Add* block may accept multiple inputs. During mutation, one input is always selected,
while each additional input is included with probability $0.5$.
Input connections are sampled without replacement from the set of valid predecessors.

When *mutating the block type*, the new type is selected uniformly from all block types except the current one.
If the newly selected block requires operation-specific parameters, such as the scaling factor of the
*Linear Scaling* block, these parameters are initialized randomly.
Furthermore, if the new block type does not support multiple input connections, any additional inputs are discarded, 
preserving only the first one.
This guarantees that the mutated gene remains structurally valid.


=== Neutral drift <drift>

Allowing offspring with equal fitness to replace the parent enables neutral drift, a characteristic feature of @cgp. Neutral drift allows inactive parts of the genome to evolve without affecting the expressed phenotype, potentially creating new evolutionary pathways that become beneficial after subsequent mutations.

To reduce the computational cost of the search, mutations affecting only inactive genes are detected before training. Since such mutations do not alter the expressed neural network, the offspring has the same phenotype as its parent. Therefore, it inherits the parent's fitness score without requiring training or evaluation. As a result, the computational budget is consumed only when an offspring requires an actual neural network training.

=== Partial Weight Inheritance

To further reduce the computational cost of training offspring architectures, partial weight inheritance is used, which is a well-known technique in @nas @9556005. Before training an offspring, parameters from the parent network are transferred whenever a parameter with the same name and tensor shape exists in the offspring architecture. As a result, parameters that remain compatible between the parent and offspring can be reused, while newly introduced or dimensionally incompatible parameters are trained from scratch.

Since offspring architectures are generated by mutating the current parent, substantial parts of their computational graphs may remain unchanged. Reusing the corresponding parameters allows the offspring to continue training from parameters already optimized in the parent instead of initializing the entire network from scratch. This reduces the amount of training required to obtain a meaningful fitness estimate.

== Candidate Evaluation

The evolutionary search requires a fitness score to compare candidate architectures and select the parent for subsequent generations. The implemented CGP-based NAS method does not impose a specific procedure for calculating this score, allowing different evaluation strategies to be used depending on the considered problem.

In this thesis, the fitness score is based on the routing performance of the candidate architecture, with lower values indicating better performance. The specific procedure used to train and evaluate candidate architectures and calculate their fitness scores is described in  @experiments.