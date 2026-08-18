#import "../utils.typ": todo, silentheading, flex-caption

= Experimental Setup

This chapter describes the experimental setup used to evaluate the proposed method. 
It presents the neural network configuration, the machine learning environment, and the evaluation protocol. Most aspects of the setup are common to all experiments and are therefore described first.
Experiment-specific settings are introduced in the corresponding sections.

As described in @methodology, the proposed method evolves only the encoder architecture of the attention-based routing model introduced by Kool et al. @Kool. The decoder, training procedure, and reinforcement learning framework are identical to those of the original implementation unless stated otherwise.

== Common Experimental Setup

=== Datasets

The benchmark instances for the Capacitated Vehicle Routing Problem (CVRP) are
generated synthetically using the procedure proposed by Nazari et al. @Nazari.
The same generation procedure was later adopted by Kool et al. @Kool.

The depot location and customer coordinates are sampled independently from a
uniform distribution over the unit square:
$ (x_i, y_i) ~  U(0, 1) $

Customer demands are sampled uniformly from the integers $1$ to $9$ and
normalized by the vehicle capacity:
$ d_i ~ U({1,...,9}) $
$ hat(d_i) = d_i / C , quad C in {20, 30} $

where $C = 20$ for CVRP10 and $C = 30$ for CVRP20.

The generated instances are used for both training and validation.


=== Evaluation

To reduce the computational cost of the architecture search, a proxy evaluation procedure is employed. During the search, candidate architectures are trained using a reduced training configuration, with fewer epochs and a smaller number of training instances per epoch compared with the original training procedure of Kool et al. @Kool. To reduce the impact of evaluation noise, a fixed validation set is used instead of generating a new validation set for each evaluation.

After the search is completed, the most promising architectures identified using proxy evaluation are selected for full evaluation. During this stage, the selected architectures are trained and evaluated using the full training configuration. The exact procedure used to select architectures for full evaluation is described separately for each experiment. 

Following Kool et al. @Kool, the mean tour length over the validation instances is used as the evaluation score, with lower values indicating better performance.

The proxy and full training configurations are summarized in @proxy_table:
#figure(
  table(
    columns: (2fr, 1fr, 1fr),
    align: (left, center, center),

    table.header(
      [*Parameter*],
      [*Proxy evaluation*],
      [*Full evaluation*],
    ),

    [Number of epochs], [10], [100],
    [Epoch size], [12,800], [128,000],
  ),
  caption: [Configurations used for proxy and full evaluation.]
) <proxy_table>

=== CGP-NAS

The size of the CGP grid is selected separately for each experiment and is therefore specified in the corresponding experiment sections.

The decay coefficient $k$ in the mutation schedule defined in @mut_k is fixed to $k = 3$ across all experiments. This value was chosen to provide a balance between larger mutations during the early stages of the search, encouraging exploration, and smaller mutations towards the end of the search, promoting local exploitation.

The number of offspring is set to $lambda = 4$, resulting in a $(1 + 4)$ evolutionary strategy. Consequently, four offspring are generated from the current parent in each generation. The $(1 + 4)$ strategy is commonly used in @cgp and follows the configuration used by Miller and Thomson @MillerCGP.

The common CGP-NAS configuration is summarized in @cgp_params.

#figure(
  table(
    columns: (1fr, 1fr),
        align: (left, center),
    [*Parameter*], [*Value*],
    [Decay $k$], [3],
    [Offspring $lambda$], [4],
  ),
  caption: [Common configuration of CGP-NAS.]
) <cgp_params>

=== Baseline Model

The neural architecture search is based on the attention-based routing model introduced by Kool et al. @Kool. Throughout all experiments, only the encoder architecture is subject to modification. All remaining components of the model, including the decoder, are kept unchanged.

The interface between the encoder and decoder is preserved regardless of the internal structure of the evolved architecture. Although individual branches of an evolved encoder may temporarily operate on different embedding dimensions due to the *Linear Scaling* blocks, the final output is projected to the embedding dimension expected by the fixed decoder.

Parameters of model are specified in @model_params:
#figure(
  table(
    columns: (1fr, 1fr),
    align: (left, center),
    [*Parameter*], [*Value*],
    [Batch size], [512],
    [Embedding dimension], [128],
    [Hidden dimension], [128],
    [Validation set size], [10000], 
    [Baseline method], [rollout],
    [Optimizer], [Adam],
    [Learning rate], [$10^(-4)$],
  ),
  caption: [Common training and model configuration.]
) <model_params>

=== Implementation

The proposed method was implemented in Python using PyTorch. The implementation of the attention-based routing model is based on the implementation by Kool et al. @Kool and was extended with the CGP representation, evolutionary search procedure, genotype-to-phenotype decoding, mutation operators, and partial weight inheritance described in the previous chapter.

To ensure reproducibility, all experiments were performed using predefined random seeds. The seeds used for each experiment are specified in the corresponding experiment sections.

The complete implementation, including experiment configurations, is available in the accompanying source code repository:
#todo("dodac link do githuba")

== Experiment I: CGP-NAS vs Random Search

=== Goal

The goal of this experiment is to compare the proposed CGP-NAS method with random search under the same computational budget. Both methods operate on the same architecture search space and use the same proxy evaluation procedure, allowing the effect of the search strategy itself to be evaluated.

In random search, each candidate architecture is generated independently by randomly sampling a new genome from the search space. Therefore, for a given computational budget of $N$ evaluations, $N$ architectures are randomly generated and the best-performing one is selected. In CGP-NAS, new candidates are instead generated by mutating the current parent according to the evolutionary procedure described in @methodology. Both methods explore the same search space, but in a different way.

=== Procedure

The experiment is divided into three phases. In the first phase, ten independent search runs are performed for both CGP-NAS and random search using different random seeds. Both methods are given the same computational budget and all candidate architectures are evaluated using the proxy configuration described in @proxy_table.

After completing the search runs, the best-performing architecture from each run is collected. 
The three architectures with the best scores for each search method are then selected for full evaluation on CVRP10. These architectures are retrained from scratch using the full training configuration to obtain more representative performance estimates.

Finally, the same selected architectures are trained from scratch and evaluated also on CVRP20. This phase investigates whether architectures discovered by searching on CVRP10 transfer to a larger problem size.

The experimental procedure can therefore be summarized in three phases:

1. Perform 10 independent CGP-NAS and 10 independent random search runs on CVRP10 using proxy evaluation.
2. Select the three best architectures discovered by each method and perform full training and evaluation on CVRP10.
3. Train and evaluate the same selected architectures on CVRP20 using the full training configuration.

The search terminates when the predefined computational budget is exhausted. The budget is expressed as the number of neural network training and evaluation operations, with one budget unit corresponding to training and evaluating one candidate architecture using the proxy configuration.

In random search, every newly generated architecture requires evaluation and therefore consumes one unit of the computational budget. In CGP-NAS, an offspring consumes one budget unit only when its expressed phenotype differs from that of its parent. Mutations affecting exclusively inactive genes result in neutral drift and do not modify the phenotype. Such offspring inherit the fitness of their parent without requiring training and therefore do not consume the evaluation budget.

Using the same evaluation budget ensures that both search methods are allowed the same number of costly operations, enabling a fair comparison between them.

=== CGP configuration

In this experiment, a grid of 15 columns and 5 rows is used. The size of the grid dictates the potential search space. If the search space is too small, promising architectures may not have enough space to emerge. If the search space is too large, the evolutionary process may not be able to effectively explore it within the available computational budget.

The size of $15 times 5$ was selected heuristically, with the aim of providing a good compromise between these two cases.
#pagebreak()

Given the decay coefficient $k = 3$ defined in @mut_k, the number of mutations for the selected $15 times 5$ grid is shown on @mutations_number

#let genome1= figure(image("../images/mut_number.png", width: 100%), caption: flex-caption(
  [Number of mutations for the 15×5 CGP grid.],
  [Number of mutations for the 15×5 CGP grid.],
))
#genome1 <mutations_number>

The CGP configuration used in this experiment is summarized in @exp1_params:

#figure(
  table(
    columns: (1fr, 1fr),
        align: (left, center),
    [*Parameter*], [*Value*],
    [Columns], [15],
    [Rows], [5],
    [Evaluation budget], [200],
    [Independent runs], [10],
    [Initial parent], [Random],
  ),
  caption: [CGP configuration used in Experiment I.]
) <exp1_params>


== Experiment II: Evolution of the Transformer

=== Goal

The goal of this experiment is to investigate whether CGP-NAS can not only discover promising architectures starting from a random initial parent, but can also improve upon an already known and well-performing architecture such as the Transformer. In particular, the experiment investigates whether the evolutionary search can discover improvements to the Transformer architecture or whether the original architecture remains the best-performing solution.

=== Procedure <exp2_procedure>

This experiment consists of ten independent search runs using different random seeds. Each run uses a computational budget of 200 evaluations, the same as in the previous experiment. However, instead of starting from a randomly generated parent, each run is initialized with the Transformer architecture.

After completing all ten search runs, the best-performing architecture from each run is collected. The three architectures with the best proxy evaluation scores are then selected and retrained from scratch using the full training configuration. This allows the experiment to verify whether improvements over the initial Transformer observed during the proxy search are preserved after full training.

The experimental procedure can be summarized in following way:

1. Perform 10 independent CGP-NAS evolutions starting from the Transformer on CVRP10 using proxy evaluation.
2. Select the three best architectures and perform full training and evaluation on CVRP10.
3. Train and evaluate the same selected architectures on CVRP20 using the full training configuration.

=== CGP setup

In this experiment, the grid must be able to contain and represent the Transformer architecture, which puts additional constraints on the grid size. Kool et al. @Kool use an encoder consisting of multiple Transformer layers, with three layers being the default configuration. In this experiment, the encoder is limited to a single Transformer layer. Representing all three layers within a single CGP genome would require a substantially larger grid and consequently increase the search space. Since the objective of this experiment is to investigate whether CGP-NAS can modify and improve an existing Transformer architecture, a single layer Transformer is used as the initial parent.

Representing a single Transformer encoder layer requires at least 2 rows and 8 columns in the proposed CGP representation. The requirement of two rows comes from the residual connections present in the Transformer architecture. While one branch passes through the computational blocks, the skip connection must be propagated through *Identity* nodes until both branches can be combined by an *Add* block.
A larger grid of 5 rows and 8 columns was selected to provide additional space for the evolutionary process to modify the initial architecture and discover alternative structures.

The Transformer encoder layer represented within the selected CGP grid is shown in @transformer_grid:

#let genome1= figure(image("../images/TRANSFORMER.png", width: 100%), caption: flex-caption(
  [Transformer Architecture in CGP representation],
   [Transformer Architecture in CGP representation],
))
#genome1 <transformer_grid>

The active nodes shown in @transformer_grid reproduce the structure of the original Transformer encoder layer, while the remaining nodes are inactive. This genome is used as the initial parent for all evolutionary runs in this experiment. 

The complete CGP configuration used in this experiment is summarized in @exp2_params:

#figure(
  table(
    columns: (1fr, 1fr),
        align: (left, center),
    [*Parameter*], [*Value*],
    [Columns], [8],
    [Rows], [5],
    [Evaluation budget], [200],
    [Independent runs], [10],
    [Initial parent], [Single-layer Transformer],
  ),
  caption: [CGP configuration used in Experiment II.]
) <exp2_params>