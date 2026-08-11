#import "../utils.typ": todo, silentheading, flex-caption, algorithm, comment

= Methodology <methodology>

This chapter describes the proposed method for evolving neural network architectures using Cartesian Genetic Programming (CGP). The proposed approach is inspired by the CGP-based Neural Architecture Search framework introduced by Suganuma et al. @Suganuma and is applied to the encoder of the attention-based model proposed by Kool et al. @Kool.

== Overview

The proposed method follows a standard mutation-only evolutionary optimization procedure. The use of crossover in CGP is often considered destructive, as it may disrupt well-performing substructures of the genotype. Consequently, the original CGP formulation proposed by Miller @MillerCGP relies exclusively on mutation, and the same approach is adopted in this thesis. 

The fitness of a candidate is defined as the validation score obtained after training the decoded neural network according to the evaluation protocol.

First, an initial candidate architecture is generated. Then, until the computational budget is exhausted, offspring are created by mutating the parent architecture. Each offspring is decoded to determine its expressed phenotype. If the mutation modifies the phenotype, the corresponding neural network is instantiated, compatible parameters are inherited from the parent, and the network is trained and evaluated to determine its fitness. Otherwise, the offspring inherits the fitness of its parent. Offspring with fitness better than or equal to that of the parent replace the parent.

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


#pagebreak()

== Genome Representation

Candidate architectures are represented using the Cartesian Genetic Programming (CGP) encoding.
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

$"ARGS"$ - operation-specific parameter if required by the selected block type

=== Types of operational blocks

In total, there are seven types of computational blocks:
1. *Identity* - return the input unchanged.
2. *Normalization* - applies layer normalization to stabilize the feature distribution.
3. *Linear Scaling* – applies a learnable linear transformation whose output dimension is determined by the scaling argument. 

  The embedding dimension can be increased by a factor of four, reduced by a factor of four, or left unchanged depending on the value of ARGUMENT:

    - *-1*:  reduces the embedding dimension by a factor of four (down to a minimum of 8)
    - *0*:  preserves the embedding dimension
    - *1*:  increases the embedding dimension by a factor of four (up to a maximum of 4096)
  *Linear Scaling* block is the only one, that takes arguments.

4. *Multi-Head Attention* - performs multi-head self-attention over the input representations
5. *Add* - projects all input tensors to a common embedding dimension if needed, and returns their element-wise sum. *Add* is the only block that can accept more than one input.
6. *GELU* - applies the Gaussian Error Linear Unit activation function.
7. *ReLU*- applies the Rectified Linear Unit activation function.

=== Dimensionality, Constraints, and Limitations <constraints>

The genome representation is subject to several structural constraints. Although the computational graph is arranged on a two-dimensional grid of size $N times M$, the genome contains $N dot M + 1$ genes. The additional gene represents the output of the entire network and is always of type *Add*, allowing it to aggregate one or more outputs produced by the last layer of computational blocks.

The input embedding initially has a fixed dimensionality. However, the *Linear Scaling* block may increase or decrease the embedding dimension along individual branches of the computational graph. Consequently, tensors arriving at an *Add* block may have different dimensionalities. To ensure compatibility, the *Add* block first projects each input to the target embedding dimension using a learnable linear transformation whenever necessary, and only then computes their element-wise sum.

Every node may receive inputs only from nodes in the immediately preceding column. This restriction guarantees that the resulting computational graph is a directed acyclic graph (DAG).

Finally, the *Add* block is the only computational block that may accept multiple input connections. All remaining blocks operate on a single input tensor.

=== Examples

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

In this example, all genes are active and participate in the resulting neural network. Therefore, the entire genotype is expressed in the phenotype. This is not always the case, as genes that are not reachable from the output node remain inactive and do not contribute to the resulting neural network. This is illustrated by the next example.


==== Example 2

In this example, the genome also has length $5$ and represents a $2 times 2$ grid:

$ (2, [0]), (2, [1]), (2, [0]), (3, [1], 1), (5, [4]) $

which can be decoded into the following computational graph:

1. Block 1 - *Normalization* (type 2), network input (0)
2. Block 2 - *Normalization* (type 2), input from node 1
3. Block 3 - *Normalization* (type 2), network input (0)
4. Block 4 - *Linear Scaling* (type 4), input from node 1, scaling dimensions up (1)
5. Block 5 - *Add* (type 5), input from node 4

#let genome2= figure(image("../images/genome2.png", width: 80%), caption: flex-caption(
  [Example of genome 2],
  [Example of genome 2],
))
#genome2 <genome2_figure>

During decoding, traversal starts from the output gene and recursively follows all 
referenced input connections. Only visited genes are considered active and are 
instantiated as computational blocks. Genes that are not reachable during this 
traversal are ignored and do not contribute to the resulting neural network.
Each visited gene is instantiated as the computational block specified by its type, 
while the connectivity of the neural network is reconstructed from the input references stored in the genome.

As shown in @genome2_figure, not all genes are active. 
Since the network output depends only on node *4*, nodes *2* and *3* are never 
visited during the decoding process and are therefore excluded from the phenotype. 
As a result, the decoded neural network contains only the active subset of the genome. 
This property enables neutral drift, as mutations affecting inactive genes do not modify the expressed neural network.


== Evolutionary Strategy

The proposed method follows the standard $(1+lambda)$ evolutionary strategy commonly used in Cartesian Genetic Programming. This strategy was originally proposed by Miller and Thomson @MillerCGP. During each iteration, the current parent is mutated to generate $lambda$ offspring. Each offspring is decoded into a neural network, trained, and evaluated to determine its fitness.
After all offspring have been evaluated, the best candidate is compared with the current parent. If its fitness is better than or equal to that of the parent, it replaces the parent in the next iteration. Otherwise, the parent is retained. This process continues until the predefined computational budget is exhausted.

Allowing offspring with equal fitness to replace the parent enables neutral drift, a characteristic feature of CGP. Neutral drift allows inactive parts of the genome to evolve without affecting the expressed phenotype, potentially creating new evolutionary pathways that become beneficial after subsequent mutations.

To reduce the computational cost of the search, mutations affecting only inactive genes are detected before training. Since such mutations do not alter the expressed neural network, the offspring is guaranteed to have the same phenotype and, consequently, the same fitness as its parent. Therefore, the offspring inherits the parent's fitness without requiring training or evaluation. As a result, the computational budget accounts only for neural network evaluations that correspond to previously unseen phenotypes.

To further reduce the computational cost of training offspring architectures, *partial weight inheritance* is used. Before training an offspring, parameters from the parent network are transferred whenever a parameter with the same name and tensor shape exists in the offspring architecture. As a result, parameters that remain compatible between the parent and offspring can be reused, while newly introduced or dimensionally incompatible parameters are trained from scratch.

== Initial Parent

The evolutionary search starts from a single parent genome, which serves as the initial solution for the optimization process. The choice of the initial parent can significantly influence both the convergence speed and the quality of the final architecture. While a randomly generated parent encourages broad exploration of the search space, initializing the search from an existing high-performing architecture allows the evolutionary process to focus on incremental improvements of a strong baseline.

The proposed method is independent of the initialization strategy used to generate the initial parent. The parent genome may either be generated randomly or constructed from a predefined neural network architecture. The former encourages exploration of the search space from scratch, whereas the latter enables the evolutionary process to refine an existing high-performing architecture. In this thesis, both initialization strategies are evaluated experimentally and compared in the following chapters.

#pagebreak()

== Mutations

Mutation is the only search operator used to explore the search space. 
Each offspring is generated as a copy of the current parent and subsequently 
modified through a sequence of mutations. The number of mutations is determined by the remaining computational budget
and follows an exponential decay schedule.
At least one mutation is always applied when generating an offspring.

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

Each mutation consists of a single elementary operation: either changing the
type of a computational block or modifying its input connections.
The probability of selecting an input mutation depends on the number of rows in the preceding column, which serves as a good approximation of the number of possible input connections for the mutated node. Strictly speaking, the number of possible input mutations is slightly larger because the *Add* block may accept multiple input connections.
However, using the number of rows provides a simple approximation that maintains a 
good balance between input mutations and type
mutations while avoiding unnecessary bias towards either mutation category.

The probability of selecting an input mutation is given by:

$ P("input" "mutation") = "#number of rows" / ( "#number of rows" + "#number of block types") $

Consequently, the probability of mutating type:
$ P("type mutation") = "#number of block types" / ( "#number of rows" + "#number of block types") $

Once the mutation category has been selected, the new input connection or block type is 
sampled uniformly from the corresponding set of valid choices. This heuristic ensures that every 
elementary mutation has approximately the same probability of being selected. The genes chosen for 
mutation are sampled uniformly without replacement,
ensuring that each gene is mutated at most once when generating a single offspring.

When mutating input connections, the number of inputs depends on the block type.
Most computational blocks always receive exactly one input connection.
The *Add* block may accept multiple inputs. During mutation, one input is always selected,
while each additional input is included with probability $0.5$.
Input connections are sampled without replacement from the set of valid predecessors.

When mutating the block type, the new type is selected uniformly from all block types except the current one.
If the newly selected block requires operation-specific parameters, such as the scaling factor of the
*Linear Scaling* block, these parameters are initialized randomly.
Furthermore, if the new block type does not support multiple input connections, any additional inputs are discarded, 
preserving only the first one.
This guarantees that the mutated gene remains structurally valid.

All mutations are generated so that the structural constraints described in @constraints remain satisfied. 
Consequently, every offspring can be decoded into a valid computational graph. 
Nodes in the first column cannot undergo input mutation, as their only valid predecessor 
is the network input. 
The output gene, in contrast, has a fixed block type and may only undergo input mutation.

// The mutation procedure is outlined in @mutation.

// #algorithm(caption: [Mutation algorithm in proposed CGP-NAS method])[
//   - *Require:* _deck_ is an unsorted array of integers
//   - ~
//   + *function* #smallcaps[produce_child];(_parent_, _remainingBudget_)
//     + _child_ = _parent_.#smallcaps[copy];()
//     + _numberOfMutations_ = #smallcaps[calculate_number_of_mutations];()
//     + *for each*
//     - ~
//     + *return* _deck_

//   + _parent_ = #smallcaps[initialize_parent];()
//   + _parent_score_ = #smallcaps[evaluate];(parent)
//   + *while* _budget_remaining_ > 0 *do*
//       + _children_ = #smallcaps[produce_offspring];(_parent_)
//       + *for each* _child_ *in* _children_
//         + *if*  #smallcaps[phenotypes_match];(_child_, _parent_)
//           + _child_score_ = _parent_score_
//         + *else*
//           + _child_score_ = #smallcaps[evaluate];(_child_)
//           + _budget_remaining_ = _budget_remaining_ - 1
//         + *if* _child_score_ <= _parent_score_
//           + _parent_ = _child_ 
//           + _parent_score_ = _child_score_
//   + *return* _parent_
// ]<mutation>
