#import "../utils.typ": todo, silentheading, flex-caption

= Conclusions

The main goal of this thesis was to investigate whether @cgp can be effectively used as a @nas method for evolving encoder architectures for the @cvrp. In particular, the work focused on comparing CGP-based architecture search with random search and investigating whether it can improve an existing transformer-based encoder.

Experiment I provides a positive answer to RQ1 under the considered proxy-evaluation setup. Across 10 independent runs, CGP-based @nas achieved better proxy scores than random search, both on average and for the best-performing run. The analysis of the search progress also showed that @cgp continued to improve the architectures throughout the search, while random search showed relatively little improvement after the initial part of the search.

However, the experiment also showed an important limitation of the proxy evaluation. The ranking obtained during proxy evaluation was not strongly preserved after full training. This shows that the proxy evaluation can be useful for guiding the search, but should not be treated as an accurate predictor of the final performance of individual architectures.

The results of Experiment II show that CGP-based architecture search can also effectively evolve an existing transformer encoder. Starting from a single-layer transformer, the search discovered several different architectures that remained competitive after full training. On CVRP10, two of the three selected evolved architectures outperformed the initial transformer. Moreover, EVO-3 achieved a better score than the transformer on every evaluated problem size, including CVRP10, CVRP20, CVRP50, and CVRP100. The transformer did not achieve the best result on any of the evaluated problem sizes. These results provide a positive answer to RQ2, although the differences in performance are generally small and should be interpreted with caution.

The evolved architectures also differ considerably from each other. EVO-3 achieves better results than the single-layer transformer across all evaluated problem sizes while using almost the same number of parameters. EVO-4 uses considerably fewer parameters, whereas EVO-6 is larger and more complex. This shows that the evolutionary search is able to discover different modifications of the initial architecture rather than simply increasing its size.

Overall, the results support the central hypothesis of this thesis. Under the considered experimental setup, CGP-based @nas is able to guide the architecture search more effectively than random search and can discover effective modifications of an existing transformer encoder. However, the experiments also show that the improvements after full training are relatively small and that further evaluation is needed before drawing more general conclusions.

== Limitations 

The main limitation of this work is the computational cost of evaluating neural network architectures. Because of this, the architecture search uses a reduced proxy training setup, while only a small number of selected architectures are evaluated using full training. In addition, each full evaluation is performed only once. Since the training process is stochastic, small differences between architectures should therefore be interpreted with caution.

Furthermore, only the three best architectures selected by proxy evaluation are considered for full evaluation. As the proxy ranking does not strongly correspond to the ranking after full training, potentially strong architectures may therefore not be selected for further evaluation.

Another limitation is that the evolutionary search is performed only on CVRP10 and within a restricted search space. Although the discovered architectures are also evaluated on CVRP20, CVRP50, and CVRP100, performing the search directly on larger problem sizes could lead to different architectures.

== Future Work

Future work could use larger computational budgets and multiple full training runs for each selected architecture. It would also be interesting to perform the evolutionary search directly on larger @cvrp problem sizes and investigate whether different architectures are discovered.

The proxy evaluation method could also be further developed. For example, the evaluation of architectures that show poor performance during the first training epochs could be terminated early, reducing the computational cost of the search. Instead of considering only the score after the final proxy training epoch, the evaluation could also take into account the learning curve and its general trajectory. A separate neural network could be trained to predict whether an architecture is promising based on its training progress. Candidates predicted to be uncompetitive could then be terminated early.

Another possible direction is to perform multiple stages of evolutionary search. After completing one search, the best discovered architecture could be used as the initial architecture for another search. This could allow the evolutionary process to explore its local neighborhood in more detail and potentially refine the architecture further.

The mutation strategy could also be improved. Currently, all block types have the same probability of being selected during mutation. However, information collected during the search could be used to identify which changes are more likely to improve performance. For example, if replacing one type of block with another has frequently resulted in an improvement, this mutation could be selected with a higher probability in future generations. This would allow the mutation strategy to adapt based on the history of the search.

Currently, mutations operate on individual genes. Another possibility would be to introduce mutations involving larger structures consisting of multiple genes. Frequently successful structures could be collected during the search and reused as building blocks in future mutations. The size and shape of the @cgp grid could also be investigated further, as the grid dimensions used in this thesis were selected experimentally and represent only one possible configuration.

Another interesting direction would be to investigate architectures composed of multiple evolved encoder layers. In this thesis, the evolutionary search is limited to a single encoder layer. A discovered architecture could be used as a building block and repeated multiple times, for example to construct a three-layer encoder similar to the original model of Kool et al. @Kool. Alternatively, each layer could use a different evolved architecture. This would make it possible to investigate whether the improvements observed for individual evolved layers are preserved or further increased when they are combined into deeper encoder architectures.

The connectivity constraints of the @cgp representation could also be relaxed. In the current implementation, a node can directly connect only to nodes from the previous column. Longer connections are still possible through *Identity* nodes, but require additional nodes and mutations to construct. Allowing nodes to connect directly to more distant columns could make such structures easier to discover and provide more flexibility during the search.

Finally, the search space could be extended with additional neural network operations, and the method could be evaluated on other variants of the @vrp or other combinatorial optimization problems.