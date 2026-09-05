#import "../utils.typ": todo, silentheading, flex-caption

= Results and Discussion

This chapter presents and analyzes the results of the experiments described in the previous chapter.
The first experiment compares the implemented CGP-based @nas method with random search under the same computational budget.
The second experiment investigates whether the implemented CGP-based @nas method is able to improve upon the transformer architecture.

== Experiment I: CGP-based @nas vs Random Search

For clarity, the best architecture from each run is assigned a unique identifier. Architectures discovered by random search are denoted as RND-N, where N corresponds to the run number (e.g., RND-5). Similarly, architectures discovered by CGP-based @nas are denoted as CGP-N, where N also corresponds to the run number. The topologies of these architectures are presented in @appendix1.


=== Proxy Evaluation Results on CVRP10

@exp1_rnd_results presents the best architectures discovered by random search during proxy evaluation.
The three best-performing architectures are selected for full evaluation and are marked in bold.
The score represents the average route length, with lower values indicating better performance.

The search seed for each run is reported for reproducibility. The proxy score is calculated by evaluating on a fixed validation dataset generated with seed 3232, which is available in the repository.

#figure(
  table(
    columns: (1fr, 1.5fr, 1.5fr, 1.5fr),
    align: (center, center, center, center),

    table.header(
      [*Run*],
      [*Architecture ID*],
      [*Seed*],
    [*Proxy score on CVRP10*],
    ),

    [1],  [RND-1],  [8939], [4.9777],
    [*2*],  [*RND-2*],  [*3635*], [*4.9391*],
    [3],  [RND-3],  [7638], [4.9558],
    [*4*],  [*RND-4*],  [*3806*], [*4.9374*],
    [5],  [RND-5],  [2932], [4.9485],
    [*6*],  [*RND-6*],  [*1659*], [*4.9352*],
    [7],  [RND-7],  [6990], [4.9825],
    [8],  [RND-8],  [8152], [4.9554],
    [9],  [RND-9],  [214], [4.9570],
    [10], [RND-10], [5261], [4.9472],
    [Best], [RND-6], [1659], [4.9352],
    [Worst], [RND-7], [6990], [4.9825],
    [Mean ± SD], [—], [-], [4.9536 ± 0.015],
  ),
  caption: [
    Proxy evaluation of 10 independent random search runs.
  ]
) <exp1_rnd_results>

#pagebreak()

Analogously, the results for CGP-based @nas are presented in @exp1_cgp_results. The three best-performing architectures are also selected for full evaluation and marked in bold. 

#figure(
  table(
    columns: (1fr, 1.5fr, 1.5fr, 1.5fr),
    align: (center, center, center, center),

    table.header(
      [*Run*],
      [*Architecture ID*],
      [*Seed*],
    [*Proxy score on CVRP10*],
    ),

    [1],  [CGP-1],  [8032], [4.8802],
    [2],  [CGP-2],  [9840], [4.8734],
    [3],  [CGP-3],  [6435], [4.8687],
    [4],  [CGP-4],  [9998], [4.8810],
    [*5*],  [*CGP-5*],  [*514*], [*4.8492* ],
    [6],  [CGP-6],  [2637], [4.8682 ],
    [*7*],  [*CGP-7*],  [*3663*], [*4.8648 *],
    [*8*],  [*CGP-8*],  [*4102*], [*4.8635 *],
    [9],  [CGP-9],  [5269], [4.8784 ],
    [10], [CGP-10], [9530], [4.8673 ],
    [Best], [CGP-5], [514], [4.8492],
    [Worst], [CGP-4], [9998], [4.8810],
    [Mean ± SD], [—], [-], [4.8695 ± 0.009],
  ),
  caption: [
    Proxy evaluation of 10 independent CGP-based @nas runs.
  ]
) <exp1_cgp_results>

The proxy evaluation results demonstrate that the implemented CGP-based @nas method achieves much better performance on average than random search. The CGP-based @nas method achieves a mean score of $4.8695$, compared with $4.9536$ for random search. The best score achieved by CGP-based @nas ($4.8492$) also clearly outperforms the best score found by random search ($4.9352$).

Moreover, the worst score achieved by the CGP-based @nas method ($4.8810$) is still better than the best score achieved by random search ($4.9352$). This indicates that the distributions of scores achieved by the two methods are clearly separated.

Looking at the standard deviation, the implemented CGP-based @nas method also achieves lower variability, with a standard deviation of $0.009$, compared with $0.015$ for random search. However, it is worth remembering that the proxy evaluation was performed under very limited training constraints, and the small sample size of $10$ runs is also a limiting factor when drawing any final conclusions.

#pagebreak() 

To further illustrate the advantage of CGP-based @nas over random search, the proxy score distributions are shown in @proxy_dist.

It clearly shows that the two distributions are separated, with no overlap between them.

#let proxy_dist= figure(image("../images/exp1/proxy_score_distribution.png", width: 80%), caption: flex-caption(
  [Distribution of proxy scores],
   [Distribution of proxy scores],
))
#proxy_dist <proxy_dist>

#pagebreak()

==== Search Progress

To further investigate and compare how both search strategies perform, @score_to_budget shows the best-so-far proxy score for each strategy as the evaluation budget increases. At each budget value, the score represents the mean of the best scores achieved so far across the 10 independent runs.

#let score_to_budget= figure(image("../images/exp1/search_progress.png", width: 100%), caption: flex-caption(
  [Mean best-so-far score as a function of consumed evaluation budget],
  [Mean best-so-far score as a function of consumed evaluation budget],
))
#score_to_budget <score_to_budget>


It can be observed that both methods perform similarly during the initial part of the search, up to an evaluation budget of approximately 50. Beyond this point, the mean best-so-far score of CGP-based @nas begins to diverge from that of random search and decreases to considerably lower values. Random search shows relatively little improvement after approximately 60 evaluations, while CGP-based @nas continues to improve throughout most of the remaining evaluation budget.

This behavior demonstrates that the advantage of the CGP-based @nas method emerges relatively early during the search, and the difference between the two methods gradually increases with the evaluation budget. This provides further evidence that CGP-based @nas offers a systematic advantage over random search within the considered search space and experimental setup.

However, all these findings are based on the proxy evaluation setup and therefore provide more information about the behavior of the search methods than about the actual performance of the discovered architectures under full training conditions. In the following section, the three best architectures discovered by each method are evaluated using the full experimental setup. This allows us to investigate whether their strong proxy performance is preserved and to examine the stability of the ranking between proxy and full evaluation.

=== Full Evaluation on CVRP10

Based on the proxy evaluation results from the previous section, the three best-performing architectures discovered by each method are selected for full evaluation on CVRP10. This evaluation aims to determine whether the performance observed under the reduced proxy setup transfers to the full evaluation configuration.

The full evaluation scores are reported in @exp1_full_cvrp10. The rows are sorted according to the proxy evaluation ranking, from best to worst.

#figure(
  table(
    columns: (1.4fr, 1.4fr,  1.4fr, 1.4fr, 1.2fr),
    align: (center, center, center, center, center),

    table.header(
      [*Architecture ID*],
      [*Proxy score on CVRP10*],
      [*Final score on CVRP10*],
      [*Proxy rank on CVRP10*],
      [*Final rank on CVRP10*],
    ),

    [CGP-5], [4.8492], [4.6736], [1], [2],
    [CGP-8], [4.8635 ], [4.6898], [2], [4],
    [CGP-7], [4.8648 ], [4.6737], [3], [3],
    [RND-6], [4.9352 ], [4.6972], [4], [5],
    [RND-4], [4.9374 ], [4.8024], [5], [6],
    [RND-2], [4.9391 ], [4.6698], [6], [1],
  ),
  caption: [
    Full evaluation of the three best candidates for each method on CVRP10, compared with the proxy evaluation.
  ],
) <exp1_full_cvrp10>

Full evaluation changes the ranking of the selected architectures.

The most surprising result is the performance of RND-2, which was ranked last among the six selected architectures under proxy evaluation, but now achieves the best score after full evaluation with $4.6698$. CGP-5, which was previously the best-performing architecture, now occupies second place with a score of $4.6736$. CGP-7 maintains third place with a nearly identical score of $4.6737$.

Together with the proxy search results, these final scores suggest that the proxy evaluation can be effective for guiding the search under the reduced training configuration, but does not reliably predict the final ranking of individual architectures after full training. This ranking stability is analyzed further in the following section.

To better visualize the changes in ranking between the proxy and full evaluation setups, the rankings of the six selected architectures are compared in @10cvrp_ranking_stability.

#let ranking_stability= figure(image("../images/exp1/ranking_comparison.png", width: 80%), caption: flex-caption(
  [Rank stability, proxy vs full evaluation on CVRP10],
  [Rank stability, proxy vs full evaluation on CVRP10],
))
#ranking_stability <10cvrp_ranking_stability>

As shown in @10cvrp_ranking_stability, the ranking is not fully stable between the proxy and full evaluation setups. The most substantial change is observed for RND-2, which moves from sixth to first place. However, when RND-2 is not taken into account, all CGP-based architectures maintain their advantage over the architectures discovered by random search. Moreover, CGP-7 maintains exactly the same ranking position. This indicates that a substantial part of the ranking instability is driven by the unexpectedly strong performance of RND-2, rather than by a complete reordering of the selected architectures.

To assess the agreement between the two rankings quantitatively, Spearman's rank correlation coefficient is calculated:

$ rho = 1 - (6 sum d_i^2) / (n dot (n^2 -1 )) = 1 - (6 dot 32) / (6 dot (36 - 1)) = 0.086 $

The resulting Spearman rank correlation coefficient is approximately $0.086$, indicating only a very weak correlation between the proxy and full evaluation rankings. However, the coefficient is strongly affected by the substantial ranking change of RND-2, and the sample size is very small ($N=6$). Therefore, no strong conclusions can be drawn from this value.

To gain further insight into the performance of the architectures, @full_training_progress illustrates their scores throughout all 100 training epochs. This allows us to examine not only the final score of each architecture, but also how their performance converges and stabilizes during training.

#let full_train10= figure(image("../images/exp1/full_training_progress.png", width: 100%), caption: flex-caption(
  [Full evaluation progress for CVRP10],
  [Full evaluation progress for CVRP10 of best six selected architectures],
))
#full_train10 <full_training_progress>

As shown in @full_training_progress, most architectures follow similar training trajectories and gradually converge towards similar scores. The main exception is RND-4, which performs considerably worse than the other architectures throughout the whole training process.

An interesting case is RND-2, which had the worst rank under proxy evaluation, but achieves the best final score. During the first epochs, RND-2 performs relatively poorly, but its score improves quickly as the training continues. After approximately 20 epochs, its performance becomes comparable to the best CGP-based architectures, and it eventually achieves the best final score.

This may explain why RND-2 performed poorly under proxy evaluation. Since proxy evaluation uses only 10 training epochs, it may not be long enough for some architectures to reach their full performance. This also shows one of the limitations of the proxy evaluation used in this experiment.

However, it is worth keeping in mind that the training conditions are different between the two setups. The proxy evaluation reuses trained weights whenever possible, while during full evaluation each architecture is trained from scratch. Therefore, the behavior observed during the first epochs of full evaluation cannot be directly transferred to the proxy setting.

#pagebreak()

=== Transfer to CVRP20

In the previous section, the full evaluation was performed on CVRP10. In this part of the experiment, the selected architectures are evaluated on the larger CVRP20 problem to investigate whether the architectures discovered on CVRP10 maintain their relative performance when transferred to a larger problem size.

The results of the CVRP20 evaluation are presented in @exp1_full_cvrp20. Each architecture is trained from scratch on CVRP20. The rows are sorted according to the CVRP10 evaluation ranking, from best to worst.

#figure(
  table(
    columns: (1.4fr, 1.4fr,  1.4fr, 1.4fr, 1.2fr),
    align: (center, center, center, center, center),

    table.header(
      [*Architecture ID*],
      [*Final score on CVRP10*],
      [*Final score on CVRP20*],
      [*Final rank on CVRP10*],
      [*Final rank on CVRP20*],
    ),

    [RND-2], [4.6698  ], [6.4217], [1], [3],
    [CGP-5], [4.6736], [6.4203], [2], [1],
    [CGP-7], [4.6737  ], [6.4204], [3], [2],
    [CGP-8], [4.6898  ], [6.4350], [4], [4],
    [RND-6], [4.6972  ], [6.4708], [5], [5],
    [RND-4], [ 4.8024], [6.7459], [6], [6],
  ),
  caption: [
    Full evaluation of three best candidates for each method on CVRP20, comparing to full evaluation on CVRP10.
  ],
) <exp1_full_cvrp20>

Evaluation on CVRP20 changes the ranking once again. The best score is now achieved by CGP-5 with $6.4203$, closely followed by CGP-7 with $6.4204$ and RND-2 with $6.4217$. The remaining three architectures maintain exactly the same ranking positions as on CVRP10.

Overall, the ranking remains relatively stable between the full evaluations on CVRP10 and CVRP20. The main change occurs among the three best-performing architectures, while CGP-8, RND-6, and RND-4 remain in fourth, fifth, and sixth place, respectively. Moreover, the differences between the top three architectures are very small, making it difficult to draw strong conclusions about their relative performance.

Nevertheless, all three architectures discovered by CGP-based @nas remain among the four best-performing architectures on CVRP20, while RND-6 and RND-4 continue to perform worse.

The changes in ranking between CVRP10 and CVRP20 are illustrated in @20cvrp_ranking_stability.

#let ranking_stability= figure(image("../images/exp1/ranking_comparison2.png", width: 80%), caption: flex-caption(
  [Rank stability between full evaluations on CVRP10 and CVRP20],
  [Rank stability between full evaluations on CVRP10 and CVRP20],
))
#ranking_stability <20cvrp_ranking_stability>

As shown in @20cvrp_ranking_stability, the ranking remains relatively stable between the full evaluations on CVRP10 and CVRP20. The changes are limited to the three best-performing architectures, while CGP-8, RND-6, and RND-4 maintain exactly the same positions. This suggests that the ranking obtained under full evaluation is more stable across the two problem sizes than the ranking observed between proxy and full evaluation on CVRP10.

To quantify the agreement between the rankings, Spearman's rank correlation coefficient is calculated:

$ rho = 1 - (6 sum d_i^2) / (n dot (n^2 -1 )) = 1 - (6 dot 6) / (6 dot (36 - 1)) = 0.829 $

The resulting Spearman rank correlation coefficient is approximately $0.829$, indicating a strong positive correlation between the rankings obtained on CVRP10 and CVRP20. However, as in the previous comparison, the sample size is very small ($N=6$), so this value should be interpreted with caution.

=== Discussion

Experiment I demonstrated that the CGP-based @nas method outperforms random search under the considered proxy evaluation setup. It achieves a better average score across 10 independent runs and also discovers the best-performing architecture. Further analysis of the search progress shows that the advantage of CGP-based @nas emerges during the search and is maintained as the computational budget is gradually consumed. This indicates that the underlying evolutionary process is able to guide the search towards promising architectures more effectively than random search under the considered proxy setup.

However, the full evaluation shows that the ranking obtained from the proxy evaluation does not strongly correspond to the ranking after full evaluation. The Spearman rank correlation coefficient between the two rankings is only $0.086$. The most significant change is observed for RND-2, which moves from sixth place under proxy evaluation to first place after full evaluation. At the same time, when RND-2 is not taken into account, all three CGP-based architectures maintain their advantage over the remaining random-search architectures.

Plotting the scores of the architectures over the training epochs provides a possible explanation for the behavior of RND-2. During the first epochs, RND-2 performs relatively poorly, but improves considerably as the training continues and eventually achieves the best final score. Since the proxy evaluation trains each architecture for only 10 epochs, it may not be long enough for some architectures to reach their full performance. However, the training conditions are different between the two setups, as the proxy evaluation uses partial weight inheritance while the full evaluation trains each architecture from scratch. Therefore, the training trajectories cannot be compared directly.

Running the full evaluation on a larger problem size, CVRP20, shows considerably higher ranking stability. The Spearman rank correlation coefficient between the CVRP10 and CVRP20 rankings is $0.829$. The changes are limited to the three best-performing architectures, while CGP-8, RND-6, and RND-4 maintain exactly the same ranking positions. The best two scores on CVRP20 are achieved by CGP-5 and CGP-7, while RND-2 moves from first to third place. However, the differences between these three architectures are very small, making it difficult to draw strong conclusions about their relative performance.

These results suggest that the ranking obtained after full training is considerably more stable between CVRP10 and CVRP20 than the ranking between proxy and full evaluation on CVRP10. However, the sample size is very small and only two relatively small problem sizes are considered, so it is not sufficient to draw general conclusions about the transfer of architectures between different problem sizes.

To sum up, Experiment I shows that the CGP-based @nas method can guide the search process more effectively than random search within a restricted computational budget and under the considered proxy evaluation setup. It also shows the limitations of proxy evaluation and its limited ability to predict the final ranking of individual architectures. Therefore, the proxy evaluation ranking cannot be treated as a trustworthy and accurate indicator of final performance, but rather as an estimate used to guide the search.

It is worth noting that this experiment was conducted on a limited sample size and with a limited training budget, due to the high computational cost of training each network. Further experiments on a much broader set of architectures and with less restricted computational resources would be valuable to verify these findings. The transfer analysis also considers only two relatively small instances, so it is difficult to predict whether the observed behavior would generalize to larger problem sizes as well.

Despite these limitations, the experiment demonstrates that the implemented CGP-based @nas approach is capable of discovering competitive architectures and outperforms random search under the considered proxy evaluation setup.

== Experiment II: Evolving the Transformer

As in the previous experiment, the best architecture from each run is assigned a unique identifier. Architectures evolved from the single-layer transformer are denoted as EVO-N, where N corresponds to the run number (e.g., EVO-3). The single-layer transformer encoder is used as the initial architecture and is further evolved by the proposed CGP-based @nas method. For simplicity, it is referred to as the transformer throughout this section.


=== Proxy Evaluation Results on CVRP10

It is important to note that the partial weight inheritance described earlier works only for architectures that have a predecessor. This means that the first architecture is initialized with random weights and has no previous architecture from which it can inherit weights.

In this experiment, this is especially important because the transformer 
is used as the initial parent. As a result, its proxy evaluation score is obtained at a disadvantage, as it cannot benefit from partial weight inheritance.
On the other hand, this has the useful property of providing the first offspring with a 
relatively low bar to overcome, allowing the search to explore the architecture space 
early instead of having to outperform a well-trained transformer layer before moving away from 
the initial architecture.

This also means that the transformer is evaluated separately in each run. 
Therefore, each evolutionary run competes against a different initial proxy score, 
despite starting from the same single-layer transformer architecture.

The results of the search under the proxy evaluation setup are presented in @exp2_cvrp10_proxy. The initial transformer proxy score for each run is reported in the table. 
The search seeds are also reported for reproducibility. The three best-performing evolved
architectures are selected for further evaluation and marked in bold.

The improvement is calculated as the difference between the initial transformer score and the final score of the best evolved architecture in each run. Because lower scores indicate better performance, a positive improvement value means that the evolved architecture achieved a better proxy score than the starting transformer architecture.


#figure(
  table(
    columns: (1.2fr, 1.4fr, 1fr, 1.5fr, 1.3fr, 1.3fr),
    align: (center, center, center, center, center, center),

    table.header(
      [*Run*],
      [*Architecture ID*],
      [*Seed*],
        [*Initial transformer score*],
    [*Proxy score*],
    [*Improvement*]
    ),
    [1],  [EVO-1],  [2325], [4.9824], [4.8830], [0.0994],
    [2],  [EVO-2],  [9519], [4.9899], [4.8803], [0.1096], 
    [*3*],  [*EVO-3*],  [*4857*], [*4.9949*], [*4.8679*], [*0.1270*],
    [*4*],  [*EVO-4*],  [*9265*], [*4.9871*], [*4.8693*], [*0.1178*],
    [5],  [EVO-5],  [2551], [4.9736], [4.8824], [0.0912],
    [*6*],  [*EVO-6*],  [*4442*], [*4.9589*], [*4.8609*], [*0.0980*],
    [7],  [EVO-7],  [4990], [4.9774], [4.8811], [0.0963],
    [8],  [EVO-8],  [6356], [4.9656], [4.8896], [0.0760],
    [9],  [EVO-9],  [1371], [4.9783], [4.8760], [0.1023],
    [10], [EVO-10], [1130], [4.9771], [4.8801], [0.0970],
    [Best],  [EVO-6],  [4442], [4.9589], [4.8609], [0.0980],
    [Worst],  [EVO-8],  [6356], [4.9656], [4.8896], [0.0760],
    [Mean ± SD], [—], [-], [4.9785 ± 0.011], [4.8771 ± 0.009], [0.1015 ± 0.014]
    ),
  caption: [
    Proxy evaluation results of 10 CGP-based @nas runs initialized with a single-layer transformer.
  ]
) <exp2_cvrp10_proxy>

The results show noticeable variation between individual runs, despite starting from the same architecture. The proxy scores of the initial transformer vary between $4.9589$ and $4.9949$. This behavior once again demonstrates the stochastic nature of the proxy evaluation and shows that a single proxy score should not be treated as an exact measure of architecture performance.

The CGP-based @nas method manages to improve the starting proxy score in all 10 runs. The improvement ranges from $0.0760$ to $0.1270$, with an average improvement of approximately $0.101$. The best final proxy score is achieved by EVO-6 with $4.8609$, followed by EVO-3 with $4.8679$ and EVO-4 with $4.8693$. These three architectures are therefore selected for full evaluation.

These results show that the evolutionary search is able to consistently improve the proxy score of the initial parent. This suggests that the CGP-based @nas method is able to effectively guide the search away from the initial transformer architecture towards architectures achieving better scores under the proxy evaluation setup.

However, these results do not yet demonstrate that the evolved architectures are better than the initial transformer architecture. The initial transformer starts from randomly initialized weights, while the evolved architectures can benefit from partial weight inheritance over multiple generations. Therefore, the comparison under proxy evaluation is not fully equal. In the next part of the experiment, the three selected architectures and the initial transformer are trained from scratch under identical conditions, allowing for a more meaningful comparison of their architectures.

=== Full Evaluation on CVRP10

The full evaluation on CVRP10 includes EVO-6, EVO-3, and EVO-4, which achieved the three best proxy scores, together with the single-layer transformer baseline. The results are presented in @exp2_full_cvrp10.

#figure(
  table(
    columns: (1.4fr, 1.4fr,  1.4fr, 1.4fr, 1.2fr),
    align: (center, center, center, center, center),

    table.header(
      [*Architecture ID*],
      [*Proxy score on CVRP10*],
      [*Final score on CVRP10*],
      [*Proxy rank on CVRP10*],
      [*Final rank on CVRP10*],
    ),
    [Transformer], [-], [4.6894], [-], [3],
    [EVO-6], [4.8609], [4.6874], [1], [2],
    [EVO-3], [4.8679], [4.6824], [2], [1],
    [EVO-4], [4.8693], [4.6985], [3], [4],

  ),
  caption: [
    Full evaluation of the three best evolved architectures and
    the single-layer transformer on CVRP10.
  ],
) <exp2_full_cvrp10>

The full evaluation results show that the differences between the best evolved architectures and the single-layer transformer are relatively small. EVO-3 achieves the best final score of $4.6824$, followed by EVO-6 with $4.6874$. EVO-4 achieves the worst score of $4.6985$. The difference between the best architecture, EVO-3, and the transformer is only $0.0070$.

The ranking obtained during proxy evaluation is not fully preserved after full training. Nevertheless, two of the three selected evolved architectures achieve slightly better final scores than the single-layer transformer.

These results indicate that the improvements observed during the evolutionary search are only partially preserved when the architectures are trained from scratch. While CGP-based @nas discovers architectures that can outperform the initial transformer, the differences are small and not all selected architectures maintain an advantage after full training. Therefore, the results do not provide strong evidence that the evolved architectures are consistently better than the single-layer transformer, but demonstrate that the evolutionary process is capable of discovering competitive modifications of the initial architecture.

=== Transfer to CVRP20, CVRP50, CVRP100

The previous evaluation compares the evolved architectures with the initial transformer on CVRP10, which is the same problem size that was used during the evolutionary search. To investigate whether the discovered architectures remain competitive on larger problem sizes, EVO-3, EVO-4, EVO-6, and the transformer are additionally evaluated on CVRP20, CVRP50, and CVRP100.

For each problem size, all architectures are trained from scratch using the full training configuration. The single-layer transformer is evaluated under the same conditions and is used as a baseline. Therefore, this evaluation investigates the transfer of the discovered architectures across problem sizes rather than the transfer of previously trained model weights.

In addition to the routing scores, the number of trainable encoder parameters is reported for each architecture. This provides an indication of the complexity of the evolved architectures and allows their performance to be considered together with their parameter count. The results for all four problem sizes are presented in @exp2_full_cvrpX. The best score for each problem size is marked in bold.

#figure(
  table(
    columns: (1.4fr, 1.4fr,  1.4fr, 1.4fr,1.4fr,1.4fr,),
    align: (center, center, center, center, center, center),

    table.header(
      [*Architecture ID*],
      [*Encoder parameters*],
      [*CVRP10 score*],
      [*CVRP20 score*],
      [*CVRP50 score*],
      [*CVRP100 score*],
    ),
    [Transformer], [197,760], [4.6894], [6.4633], [11.0679], [16.7780],
    [EVO-3], [197,504], [*4.6824*], [*6.4628*], [*11.0324*], [16.7213],
    [EVO-4], [67,072], [4.6985], [6.4762], [11.1093], [16.8082],
    [EVO-6], [280,064], [4.6874], [6.4670], [11.0613], [*16.7204*],

  ),
  caption: [
    Full evaluation of the three best evolved architectures and
    the single-layer transformer on CVRP10, CVRP20, CVRP50, CVRP100.
  ],
) <exp2_full_cvrpX>

The results show that the evolved architectures remain competitive with the single-layer transformer across the larger problem sizes. EVO-3 achieves the best score on CVRP20 and CVRP50, with scores of $6.4628$ and $11.0324$, respectively. On CVRP100, the best score is achieved by EVO-6 with $16.7204$, closely followed by EVO-3 with $16.7213$. 

EVO-3 is particularly interesting, as its encoder contains $197,504$ trainable parameters, almost the same number as the original transformer with $197,760$ parameters, while achieving a better score on all three larger problem sizes. The difference is very small on CVRP20, but becomes more noticeable on CVRP50 and CVRP100.

The evolved architectures also differ considerably in their parameter counts. EVO-4 contains only $67,072$ encoder parameters, approximately 66% fewer than the transformer, while remaining relatively competitive across all evaluated problem sizes. In contrast, EVO-6 is the largest architecture with $280,064$ parameters and achieves the best result on CVRP100. These results show that the evolutionary process discovers architectures with various levels of complexity rather than simply increasing the size of the initial transformer.

Overall, the results suggest that the architectural modifications discovered during the search on CVRP10 can transfer to larger problem sizes. In particular, EVO-3 consistently outperforms the transformer on CVRP20, CVRP50, and CVRP100 without increasing the number of encoder parameters. However, the differences in routing scores remain relatively small, and the evaluation is based on a single full training run for each architecture and problem size. Therefore, the results should not be interpreted as conclusive evidence that the evolved architectures generally outperform the transformer.

==== Learning Curves

To further investigate the behavior of the architectures during full training, @exp2_training_progress shows their validation scores over 100 training epochs for each problem size. While the previous analysis focuses on the final performance, the training curves provide additional insight into how the relative performance of the architectures develops throughout the training process.

#let ranking_stability= figure(image("../images/exp2/exp2_training_progress.png", height: 100%), caption: flex-caption(
  [Training progress on CVRP10, CVRP20, CVRP50, and CVRP100],
  [Training progress on CVRP10, CVRP20, CVRP50, and CVRP100],
))
#ranking_stability <exp2_training_progress>

The training trajectories provide additional insight into the behavior of the architectures across different problem sizes. On CVRP10, all four architectures follow very similar trajectories and the differences between them remain small throughout training. EVO-3 achieves a slightly lower validation score during a substantial part of the later training, which is consistent with its best final score reported in @exp2_full_cvrp10.

As the problem size increases, the differences in the training behavior become more visible. On CVRP20, EVO-3 reaches lower validation scores relatively early and maintains an advantage over the other architectures during most of the training. A similar pattern can be observed on CVRP50, where EVO-3 remains below the other architectures for a substantial part of the training process, while EVO-4 generally achieves the highest validation scores.

However, on CVRP100 the performance of architectures is somewhat different. EVO-6 improves particularly quickly during the early stages of training and achieves the lowest validation scores for a large part of the training process. EVO-3 follows closely, and the differences between the architectures gradually decrease towards the end of training.

Overall, all four architectures exhibit a similar general convergence pattern, characterized by rapid improvement during the first epochs followed by slower and more gradual improvement. However, their relative training behavior changes with the problem size. In particular, the evolved architectures that perform well on the larger instances tend to establish their advantage relatively early in training rather than only achieving a better score in the final epochs. Nevertheless, the differences remain relatively small, especially towards the end of training. Therefore, small differences in the final ranking should be interpreted cautiously, as they may be sensitive to the particular set of problem instances used for evaluation.

=== Comparison with the Original Attention Model

Notably, Kool et al. @Kool report a score of $16.80$ on CVRP100 for their original model, which uses a three-layer transformer encoder. In comparison, both EVO-3 and EVO-6 achieve better scores in our evaluation. Moreover, even the single-layer transformer achieves a slightly better score than the value reported by Kool et al.

However, these results cannot be directly compared. The training process is stochastic and, more importantly, our evaluation uses a different predefined test dataset than the one used by Kool et al. Therefore, the observed differences may result from the particular problem instances used for evaluation rather than differences between the architectures.

Kool et al. provide the datasets used for their evaluation in their public repository. Therefore, to make the comparison more meaningful, we additionally evaluate our trained architectures on the same datasets. The results are presented in @exp2_kool_comparison. The best score for each problem size is marked in bold.

#figure(
  table(
    columns: (1.5fr, 1.3fr, 1.3fr, 1.3fr),
    align: (center, center, center, center),

    table.header(
      [*Architecture*],
      [*CVRP20 score*],
      [*CVRP50 score*],
      [*CVRP100 score*],
    ),

    [Kool et al. (reported)], [*6.40*], [*10.98*], [16.80],
    [Kool et al. (reproduced)], [6.41], [11.00], [16.91],
    [single-layer transformer], [6.47], [11.09], [16.82],
    [EVO-3], [6.46], [11.05], [*16.77*],
    [EVO-4], [6.48], [11.13], [16.85],
    [EVO-6], [6.48], [11.08], [*16.77*],
  ),

  caption: [
    Comparison of the selected architectures with the reported and reproduced results of Kool et al.
    on their test datasets.
  ],
) <exp2_kool_comparison>

After evaluation on the test datasets provided by Kool et al., the performance of the single-layer transformer is more in line with what would be expected when compared with the original three-layer model. On CVRP20 and CVRP50, the original model achieves the best results, both in the values reported by Kool et al. and in our reproduction. However, on CVRP100, EVO-3 and EVO-6 achieve the best score of $16.77$, outperforming both the reported score of $16.80$ and the reproduced score of $16.91$.

This further suggests that the relative performance of different architectures may change with the problem size. It is also worth noting that EVO-3 contains less than one third of the encoder parameters of the original three-layer transformer, while achieving a slightly better score on CVRP100.

However, the difference on CVRP100 is very small and should be interpreted with caution. The reported result of Kool et al. and the results obtained in this work come from separately trained models, and the training process is stochastic. Therefore, these results do not provide sufficient evidence to conclude that EVO-3 or EVO-6 generally outperform the original model. Nevertheless, achieving comparable or slightly better performance on CVRP100 is particularly interesting given that the evolved architectures originate from a single-layer transformer and were discovered through an evolutionary search conducted only on CVRP10.

=== Analysis of Evolved Architectures

In addition to evaluating their routing performance, it is useful to examine how the evolutionary process modified the initial transformer architecture. The three architectures selected for full evaluation, EVO-3, EVO-4, and EVO-6, are therefore analyzed in more detail. Their simplified encoder structures are presented in this section, allowing the architectural changes introduced during evolution to be compared with the initial single-layer transformer.

For clarity, the diagrams show simplified phenotypes of the architectures. Inactive CGP nodes and Identity operations that only propagate their input without modification are omitted. This makes it easier to identify the operations and connections that directly affect the computation performed by each encoder. The complete CGP representations of the evolved architectures, including inactive and Identity nodes, are provided in @appendix2.

For reference, the baseline single-layer transformer is shown in @exp2_trans1:

#let ranking_stability= figure(image("../images/exp2/TRANS1.png", width: 100%), caption: flex-caption(
  [Architecture of single-layer transformer],
  [Architecture of single-layer transformer],
))
#ranking_stability <exp2_trans1>

The single-layer transformer consists of two main blocks. The first is a multi-head attention block with a residual connection. The second is a feed-forward block consisting of a linear transformation that scales the embedding dimension up, followed by a ReLU activation and another linear transformation that scales the dimension back down. This block also includes a residual connection. Both blocks are followed by normalization. This structure follows the standard transformer architecture commonly used in the literature.

The architecture of EVO-3 is presented in @exp2_evo3 :

#let ranking_stability= figure(image("../images/exp2/EVO3.png", width: 100%), caption: flex-caption(
  [Architecture of EVO-3],
  [Architecture of EVO-3],
))
#ranking_stability <exp2_evo3>

While EVO-3 preserves the main structure of the transformer, it simplifies its architecture. It removes the residual connection around the feed-forward block and replaces one of the normalization operations with a ReLU activation.
The number of trainable parameters is almost identical ($197,504$ vs. $197,760$), which shows that the improvement in performance cannot be explained by an increase in the parameter count alone.

The architecture of EVO-4 is presented in @exp2_evo4 :

#let ranking_stability= figure(image("../images/exp2/EVO4.png", width: 100%), caption: flex-caption(
  [Architecture of EVO-4],
  [Architecture of EVO-4],
))
#ranking_stability <exp2_evo4>

EVO-4 differs substantially from the initial transformer architecture. The input is split into two parallel branches, which are later combined using an *Add* operator. While one branch preserves an attention operation, the standard transformer residual and feed-forward structures are no longer present.
 Instead, the architecture relies heavily on normalization and activation operations. EVO-4 is also considerably smaller, containing only $67,072$ trainable parameters, approximately 66% fewer than the single-layer transformer. Despite this reduction, it remains relatively competitive, although it achieves the worst routing scores among the three selected evolved architectures.

The architecture of EVO-6 is presented in @exp2_evo6 :

#let ranking_stability= figure(image("../images/exp2/EVO6.png", width: 100%), caption: flex-caption(
  [Architecture of EVO-6],
  [Architecture of EVO-6],
))
#ranking_stability <exp2_evo6>

EVO-6 is the most complex of the three selected architectures and differs substantially from the initial transformer.
It contains two consecutive attention operators and multiple parallel branches.
This increased structural complexity is also reflected in the parameter count, with EVO-6 containing $280,064$ trainable parameters compared with $197,760$ in the single-layer transformer. EVO-6 performs particularly well on CVRP100, but its larger size makes it difficult to separate the effect of the architectural changes from the increased model capacity.

Overall, the three evolved architectures differ substantially from each other, both in their structure and parameter count. This demonstrates the diversity of solutions explored by the CGP-based search, ranging from the relatively simple EVO-4 to the more complex EVO-6. Importantly, the search does not converge towards a single type of modification of the transformer, but discovers several structurally different architectures that remain competitive. This suggests that multiple different encoder structures can provide effective solutions for the @cvrp within the investigated search space.


=== Discussion

Experiment II shows that the CGP-based @nas method is able to effectively evolve the initial single-layer transformer architecture. While all 10 runs improve upon the initial parent under proxy evaluation, these results are affected by partial weight inheritance. After full training from scratch, the differences become considerably smaller. Nevertheless, two of the three selected evolved architectures slightly outperform the initial transformer on CVRP10.

The evaluation on larger problem sizes shows that the discovered architectures remain competitive beyond CVRP10, on which the evolutionary search was performed. EVO-3 performs particularly well across CVRP20, CVRP50, and CVRP100, while EVO-6 achieves the best result on CVRP100. The comparison with Kool et al. @Kool further shows that EVO-3 and EVO-6 achieve slightly better scores than the result reported for the original three-layer transformer on CVRP100, although the original model remains better on CVRP20 and CVRP50. This suggests that the relative performance of different architectures may depend on the problem size.

The evolved architectures also differ substantially in their structure and parameter count. EVO-3 simplifies the initial transformer while maintaining almost the same number of parameters, EVO-4 discovers a considerably smaller architecture, and EVO-6 produces a larger and more complex architecture. This demonstrates that the CGP-based search explores diverse structural modifications rather than simply increasing the size of the initial model.

Overall, the results indicate that CGP-based @nas can successfully evolve an existing transformer-based encoder and discover competitive alternatives. However, the differences in performance are generally small, and only three evolved architectures are considered under full evaluation, with a single training run for each configuration. Therefore, the results do not provide strong evidence that the evolved architectures consistently outperform the transformer, but demonstrate that CGP-based @nas is capable of discovering effective modifications of its architecture.