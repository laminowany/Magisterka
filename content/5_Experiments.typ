#import "../utils.typ": todo, silentheading, flex-caption

= Experimental Setup <experiments>

== Overview 

This chapter describes the experimental setup used to evaluate the implemented CGP-based NAS method.

It presents the neural network configuration, the machine learning environment, and the evaluation protocol. Most aspects of the setup are common to all experiments and are therefore described first, while experiment-specific settings are introduced in the corresponding sections.

As described in @methodology, the implemented method evolves only the encoder architecture of the attention-based routing model introduced by Kool et al. @Kool. The decoder, training procedure, and reinforcement learning framework remain unchanged unless stated otherwise.

== Common Experimental Setup

=== Model and Training Configuration

The model and training parameters are based on the original configuration used by Kool et al. @Kool and are kept unchanged unless stated otherwise. This ensures that the experiments focus on changes to the encoder architecture rather than on additional hyperparameter tuning.

Partial weight inheritance, as described in @methodology, is used during the CGP-based search to allow offspring architectures to reuse compatible parameters from their parent.

The common model and training parameters used across all experiments are summarized in @model_params:

#figure(
  table(
    columns: (1fr, 1fr),
    align: (left, center),
    [*Parameter*], [*Value*],
    [Batch size], [512],
    [Embedding dimension], [128],
    [Hidden dimension], [128],
    [Attention heads], [8],
    [Tanh clipping], [10],
    [Gradient clipping], [1.0],
    [Baseline method], [Rollout],
    [Optimizer], [Adam],
    [Decoding strategy], [Greedy],
    [Learning rate], [$10^(-4)$],
  ),
  caption: [Common training and model configuration.]
) <model_params>

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
$ hat(d_i) = d_i / C , quad C in {20, 30, 40, 50} $

where $C$ denotes the vehicle capacity and is set to $20$, $30$, $40$, and $50$
for CVRP10, CVRP20, CVRP50, and CVRP100, respectively.

Three types of datasets are used throughout the experiments:
1. *Training dataset* - generated randomly on the fly during neural network training. Its size is determined by the `epoch_size` parameter.
2. *Validation dataset* - a fixed dataset generated offline and used at the end of each training epoch for logging and plotting. In all experiments, the validation dataset contains 10,000 instances. This dataset was generated using seed 3232.
3. *Test dataset* - a fixed dataset generated offline and used to calculate the final evaluation score. It contains 10,000 instances. This dataset was generated using seed 2323.

The exact role of each dataset in the evaluation procedure is described in @evaluation_exp.

=== Evaluation <evaluation_exp>

Following Kool et al. @Kool, the architecture score is calculated as the mean tour length over the corresponding evaluation dataset, with lower values indicating better performance. Greedy decoding is used to construct the routes during both proxy and full evaluation.

Training each candidate architecture using the full training configuration is computationally expensive and infeasible during the architecture search. Therefore, following common approaches in @nas, a proxy evaluation procedure is used to estimate the performance of candidate architectures @NAS_survey. The computational cost is reduced primarily by limiting the training of each candidate to fewer epochs and fewer training instances per epoch.
It is worth noting that the term *evaluation* refers here to training a network for a specified number of epochs and calculating its score after training.

The proxy evaluation score does not need to be an accurate estimate of the final evaluation score. More importantly, it should preserve the relative ranking of candidate architectures, allowing the search to distinguish promising architectures from those that can be discarded.

Accordingly, two types of evaluation are used in this thesis:
1. *Proxy evaluation* - used during the architecture search.
  - The *training dataset* is used for training, 
  - The *validation dataset* is used to calculate the architecture score.
2. *Full evaluation* - used for the final evaluation of selected architectures.
  - The *training dataset* is used for training.
  - The *validation dataset* is used to calculate the score after each epoch for tracking training progress and plotting.
  - The *test dataset* is used to calculate the final architecture score.

The differences between the proxy and full evaluation configurations are summarized in @proxy_table:
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
    [Epoch size], [12,800], [1,280,000],
  ),
  caption: [Configurations used for proxy and full evaluation.]
) <proxy_table>

=== CGP-NAS

The size of the CGP grid is selected separately for each experiment and is therefore specified in the corresponding experiment sections.

The decay coefficient $k$ in the mutation schedule defined in equation (#ref(<mut_k>, supplement: none)) is fixed to $k = 3$ across all experiments. This value was chosen to provide a balance between larger mutations during the early stages of the search, encouraging exploration, and smaller mutations towards the end of the search, promoting local exploitation.

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


=== Implementation

The CGP-based @nas method was implemented in Python using PyTorch. The implementation of the attention-based routing model is based on the implementation by Kool et al. @Kool, and was extended with the CGP representation, evolutionary search procedure, genotype-to-phenotype decoding, mutation operators, and partial weight inheritance described in the previous chapter.

To ensure reproducibility, all experiments were performed using predefined seeds.
Every full evaluation was performed using the same fixed seed of $1234$.

Each architecture search was performed using a randomly generated seed, which is reported in the corresponding experiment sections. This allows individual search runs to be reproduced while maintaining different random initialization between runs.
The experiments were executed on CUDA-enabled NVIDIA GPUs. Since the experiments were distributed across multiple GPU instances, the exact GPU model varied between runs.

The complete implementation, including experiment configurations as well as validation and test datasets, is available in the accompanying source code repository: #link("https://github.com/laminowany/cgp-nas-cvrp")[cgp-nas-cvrp].

== Experiment I: CGP-NAS vs Random Search

=== Goal

The goal of this experiment is to compare the implemented CGP-based @nas method with random search under the same computational budget. Both methods operate on the same architecture search space, allowing the CGP-based @nas procedure to be compared with random search.

In random search, each candidate architecture is generated independently by randomly sampling a new genome from the search space. Therefore, for a given computational budget of $N$ evaluations, $N$ architectures are randomly generated and the best-performing one is selected. In CGP-based @nas, new candidates are instead generated by mutating the current parent according to the evolutionary procedure described in @methodology. Both methods explore the same search space, but in a different way.

Since the purpose of this experiment is to compare the search strategies without introducing prior architectural knowledge, the initial @cgp parent is generated randomly in each search run.

=== Procedure

The experiment consists of three phases. In the first phase, ten independent search runs are performed for both CGP-based @nas and random search on CVRP10. Each run uses a different randomly generated seed. Both methods are given the same computational budget, and all candidate architectures are evaluated using the proxy configuration described in @proxy_table.

After completing the search runs, the best-performing architecture from each run is collected. The three architectures with the best proxy evaluation scores for each search method are then selected for full evaluation on CVRP10. During full evaluation, the selected architectures are trained from scratch using the full training configuration described in @proxy_table.

Finally, the same selected architectures are trained from scratch and evaluated on CVRP20. This phase investigates whether architectures discovered during the search on CVRP10 transfer to a larger problem size.

The experimental procedure can therefore be summarized as follows:

1. Perform 10 independent CGP-based @nas and 10 independent random search runs on CVRP10 using proxy evaluation.
2. Select the three best architectures discovered by each method and perform full evaluation on CVRP10.
3. Perform full evaluation of the same selected architectures on CVRP20.

In the first phase, each search run is limited to a computational budget of 200 evaluations. The computational budget is defined as described in @methodology, with one budget unit corresponding to one candidate architecture requiring training and evaluation using the proxy configuration. The same computational budget is used for both CGP-based @nas and random search to ensure a fair comparison.

=== CGP configuration

In this experiment, a grid of 15 columns and 5 rows is used. The size of the grid dictates the potential search space. If the search space is too small, promising architectures may not have enough space to emerge. If the search space is too large, the evolutionary process may not be able to effectively explore it within the available computational budget.

A $15 times 5$ grid was selected arbitrarily, with the aim of providing a good compromise between these two cases.

Given the decay coefficient $k = 3$ defined in equation (#ref(<mut_k>, supplement: none)), the number of mutations for the selected $15 times 5$ grid is shown in @mutations_number.

#let genome1= figure(image("../images/mut_number.png", width: 100%), caption: flex-caption(
  [Number of mutations for the 15 × 5 CGP grid.],
  [Number of mutations for the 15 × 5 CGP grid.],
))
#genome1 <mutations_number>

The @cgp configuration used in this experiment is summarized in @exp1_params:

#figure(
  table(
    columns: (1fr, 1fr),
        align: (left, center),
    [*Parameter*], [*Value*],
    [Columns], [15],
    [Rows], [5],
    [Independent Runs], [10],
    [Initial Parent], [Random],
  ),
  caption: [CGP configuration used in Experiment I.]
) <exp1_params>

#pagebreak()

== Experiment II: Evolution of the Transformer

=== Goal

The goal of this experiment is to investigate whether CGP-based @nas can effectively evolve an existing transformer-based encoder architecture. In particular, the experiment investigates whether the evolutionary search can discover improvements to a single transformer encoder layer or whether the initial architecture remains the best-performing solution.

=== Procedure <exp2_procedure>

This experiment consists of ten independent search runs using different predefined seeds. Each run uses a computational budget of 200 evaluations, the same as in the previous experiment. However, instead of starting from a randomly generated parent, each run is initialized with a single-layer transformer.

After completing all ten search runs, the best-performing architecture from each run is collected. The three architectures with the best proxy evaluation scores are then selected and retrained from scratch using the full training configuration. For comparison, the initial single-layer transformer is also trained from scratch using the same full training configuration. This allows the experiment to verify whether improvements over the initial transformer observed during the proxy search are preserved after full training. The same architectures are then evaluated on CVRP20, CVRP50, and CVRP100 to investigate whether their performance relative to the transformer is maintained across larger problem sizes.

The experimental procedure can be summarized as follows:

1. Perform 10 independent CGP-based NAS evolutions starting from the transformer on CVRP10 using proxy evaluation.
2. Select the three best architectures and perform full evaluation on CVRP10, together with the initial transformer.
3. Perform full evaluation of the same selected architectures and the initial transformer on CVRP20, CVRP50, and CVRP100.

=== CGP setup

In this experiment, the grid must be able to represent the transformer architecture, which introduces additional constraints on its size. Kool et al. use an encoder consisting of multiple transformer layers, with three layers being the default configuration @Kool. In this experiment, the encoder is limited to a single transformer layer. Representing all three layers within a single CGP genome would require a substantially larger grid and consequently increase the search space. Since the objective of this experiment is to investigate whether CGP-based @nas can modify and improve an existing transformer architecture, a single transformer layer is used as the initial parent.

Representing a single transformer encoder layer requires at least two rows and eight columns in the @cgp representation used in this thesis. The requirement of two rows comes from the residual connections present in the transformer architecture. While one branch passes through the computational blocks, the skip connection must be propagated through *Identity* nodes until both branches can be combined by an *Add* block.
A larger $5 times 8$ grid was selected to provide additional space for the evolutionary process to modify the initial architecture and discover alternative structures.

The transformer encoder layer represented within the selected CGP grid is shown in @transformer_grid:

#let genome1= figure(image("../images/TRANSFORMER.png", width: 100%), caption: flex-caption(
  [Single-layer transformer in CGP representation],
   [Single-layer transformer in CGP representation],
))
#genome1 <transformer_grid>

The active nodes shown in @transformer_grid reproduce the structure of the original transformer encoder layer, while the remaining nodes are inactive. This genome is used as the initial parent for all evolutionary runs in this experiment. 

The complete CGP configuration used in this experiment is summarized in @exp2_params:

#figure(
  table(
    columns: (1fr, 1fr),
        align: (left, center),
    [*Parameter*], [*Value*],
    [Columns], [8],
    [Rows], [5],
    [Computational budget], [200],
    [Independent runs], [10],
    [Initial parent], [Single-layer transformer],
  ),
  caption: [CGP configuration used in Experiment II.]
) <exp2_params>