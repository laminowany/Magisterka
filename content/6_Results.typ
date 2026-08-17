#import "../utils.typ": todo, silentheading, flex-caption

= Results and Discussion

This chapter presents and analyzes the results of the experiments described in the previous chapter.
The first experiment compares the proposed CGP-NAS method with random search under the same computational budget.
The second experiment investigates whether the proposed CGP-NAS method is able to improve upon the Transformer architecture.

== Experiment I: CGP-NAS vs Random Search

For clarity, the best architecture from each run is assigned a unique identifier. Architectures discovered by random search are denoted as RND-N, where N corresponds to the run number (e.g., RND-5). Similarly, architectures discovered by CGP-NAS are denoted as CGP-N, where N also corresponds to the run number.


=== Proxy Evaluation Results on CVRP10

@exp1_rnd_results presents the best architectures discovered by random search during proxy evaluation.
The three best-performing architectures are selected for full evaluation and are marked in bold.
The score represents the average route length, with lower values indicating better performance.

The search seed is reported for reproducibility and corresponds to the run in which the architecture was discovered.

#figure(
  table(
    columns: (1fr, 1.5fr, 1.5fr, 1.5fr),
    align: (center, center, center, center),

    table.header(
      [*Run*],
      [*Architecture ID*],
      [*Seed*],
    [*Proxy score*],
    ),

    [*1*],  [*RND-1*],  [*1634*], [*4.8808*],
    [2],  [RND-2],  [7932], [4.9169],
    [3],  [RND-3],  [4970], [4.9039],
    [4],  [RND-4],  [9061], [4.9097],
    [5],  [RND-5],  [6214], [4.9006],
    [*6*],  [*RND-6*],  [*4112*], [*4.8976*],
    [7],  [RND-7],  [6858], [4.9005],
    [*8*],  [*RND-8*],  [*2059*], [*4.8994*],
    [9],  [RND-9],  [9229], [4.9017],
    [10], [RND-10], [8030], [4.9105],
    [Best], [RND-1], [1634], [4.8808],
    [Worst], [RND-2], [7932], [4.9169],
    [Mean ± SD], [—], [-], [4.9022 ± 0.0091],
  ),
  caption: [
    Proxy evaluation of 10 independent random search runs.
  ]
) <exp1_rnd_results>

Analogously, the results for CGP-NAS are presented in @exp1_cgp_results. The three best-performing architectures are also selected for full evaluation and marked in bold. 

#figure(
  table(
    columns: (1fr, 1.5fr, 1.5fr, 1.5fr),
    align: (center, center, center, center),

    table.header(
      [*Run*],
      [*Architecture ID*],
      [*Seed*],
    [*Proxy score*],
    ),

    [1],  [CGP-1],  [7399], [4.8910],
    [*2*],  [*CGP-2*],  [*4244*], [*4.8794*],
    [*3*],  [*CGP-3*],  [*6561*], [*4.8522*],
    [4],  [CGP-4],  [6859], [4.8810],
    [5],  [CGP-5],  [9352], [4.9022],
    [6],  [CGP-6],  [6182], [4.8814],
    [7],  [CGP-7],  [2128], [4.8873],
    [8],  [CGP-8],  [5255], [4.9181],
    [*9*],  [*CGP-9*],  [*4691*], [*4.8755*],
    [10], [CGP-10], [3149], [4.8824],
    [Best], [CGP-3], [6561], [4.8522],
    [Worst], [CGP-8], [5255], [4.9181],
    [Mean ± SD], [—], [-], [4.8851 ± 0.0163],
  ),
  caption: [
    Proxy evaluation of 10 independent CGP-NAS runs.
  ]
) <exp1_cgp_results>

The distribution of the results across the independent runs is visualized in @proxy_dist. Despite the small sample size, the CGP-NAS results appear to be generally shifted towards lower, and therefore better, scores compared with random search.

It is also worth noting that the three best architectures discovered by CGP-NAS all achieve lower proxy scores than the best architecture found by random search, showing clear dominance of CGP-NAS method over random search.

#let proxy_dist= figure(image("../images/exp1/proxy_score_distribution.png", width: 80%), caption: flex-caption(
  [Distribution of proxy scores],
   [Distribution of proxy scores],
))
#proxy_dist <proxy_dist>

The proxy evaluation results show that CGP-NAS achieves slightly better performance on average than random search. The proposed CGP-NAS method achieves a mean score of $4.8851$, compared with $4.9022$ for random search, corresponding to an improvement of approximately $0.35%$. The best score achieved by CGP-NAS, $4.8522$, also outperforms the best score of $4.8808$ found by random search. However, the difference between the two methods is relatively small and should be interpreted with caution. It is also worth noting that the worst architecture discovered by CGP-NAS performs slightly worse than the worst architecture discovered by random search, with scores of $4.9181$ and $4.9169$, respectively.

CGP-NAS also exhibits greater variability between runs, with a standard deviation of $0.0163$ compared with $0.0091$ for random search. Therefore, although CGP-NAS achieves a better mean score and discovers the best-performing architecture overall, its results are less consistent across independent runs. Furthermore, these observations are based on a relatively small sample size of $N=10$ runs per method and should therefore not be treated as conclusive evidence of the superiority of either search strategy.

To further investigate and compare how both search strategies perform, @score_to_budget shows the best-so-far proxy score for each strategy as the evaluation budget increases. At each budget value, the score represents the mean of the best scores achieved so far across the 10 independent runs.

#let score_to_budget= figure(image("../images/exp1/search_progress.png", width: 100%), caption: flex-caption(
  [Mean best-so-far score to consumed budget],
  [Mean best-so-far score to consumed budget],
))
#score_to_budget <score_to_budget>


It can be observed that both methods perform similarly up to an evaluation budget of approximately 30. Beyond this point, the mean best-so-far score of CGP-NAS begins to diverge from that of random search and decreases to lower values. The curves subsequently follow relatively similar trajectories, while CGP-NAS maintains its advantage throughout the remaining evaluation budget.

This behavior suggests that the advantage of CGP-NAS observed in the final proxy scores is not limited to the final outcome of the search. Instead, the lower mean best-so-far score emerges during the search and is consistently maintained as the evaluation budget increases. This provides further evidence that CGP-NAS may offer a systematic advantage over random search within the considered search space and experimental setup.

However, all these findings are based on the proxy evaluation setup and therefore provide more information about the behavior of the search methods than about the actual performance of the discovered architectures under full training conditions. In the following section, the three best architectures discovered by each method are evaluated using the full experimental setup. This allows us to investigate whether their strong proxy performance is preserved and to examine the stability of the ranking between proxy and full evaluation.

=== Full Evaluation on CVRP10

Based on the proxy evaluation results from the previous section, the three best-performing architectures discovered by each method are selected for full evaluation on CVRP10. This evaluation aims to determine whether the performance observed under the reduced proxy setup transfers to the full evaluation configuration.

The proxy scores are obtained during corresponding search runs and therefore use the search seeds reported in the previous section.
The full evaluation score are calculated during seperate evaluation run, and theirs seeds are reported in @exp1_full_cvrp10. The rows are sorted according to the proxy evaluation ranking, from best to worst.

#figure(
  table(
    columns: (1.4fr, 1.4fr,  1.4fr, 1.4fr, 1.2fr, 1.2fr),
    align: (center, center, center, center, center, center),

    table.header(
      [*Architecture ID*],
      [*Seed*],
      [*Proxy score*],
      [*Full eval score on CVRP10*],
      [*Proxy rank*],
      [*Full eval rank on CVRP10*],
    ),
    [CGP-3], [2930], [4.8522], [4.7636], [1], [5],
    [CGP-9], [7450], [4.8755], [4.7574], [2], [3],
    [CGP-2], [3378], [4.8794], [4.7428], [3], [1],
    [RND-1], [3887], [4.8808], [4.7596], [4], [4],
    [RND-6], [9659], [4.8976], [4.7497], [5], [2],
    [RND-8], [3378], [4.8994], [4.7756], [6], [6],
  ),
  caption: [
    Full evaluation of three best candidates for each method on CVRP10, comparing to proxy.
  ],
) <exp1_full_cvrp10>

Full evaluation substantially changes the ranking of the selected architectures. The CGP-3 architecture, which achieved the best score under the proxy setup, now ranks fifth with a score of $4.7636$. In contrast, CGP-2, which was ranked third under the proxy setup, achieves the best performance after full evaluation, with a score of $4.7428$. It is followed by RND-6 in second place with a score of $4.7497$, and CGP-9 in third place with $4.7574$.

As a result, although an architecture discovered by CGP-NAS leads the comparison, the full evaluation does not demonstrate the same advantage of CGP-NAS over random search as observed under the proxy evaluation setup.

To better visualize the changes in ranking between the proxy and full evaluation setups, the rankings of the six selected architectures are compared in @10cvrp_ranking_stability.

#let ranking_stability= figure(image("../images/exp1/ranking_comparison.png", width: 80%), caption: flex-caption(
  [Rank stability, proxy vs full evaluation on CVRP10],
  [Rank stability, proxy vs full evaluation on CVRP10],
))
#ranking_stability <10cvrp_ranking_stability>

As shown in @10cvrp_ranking_stability, the ranking is not stable between the proxy and full evaluation setups. The position of every architecture changes considerably, except for RND-1 and RND-8, which remains in the same ranking positions. 

To assess the agreement between the two rankings quantitatively, Spearman's rank correlation coefficient is calculated:

$ rho = 1 - (6 sum d_i^2) / (n dot (n^2 -1 )) = 1 - (6 dot 30) / (6 dot (36 - 1)) = 0.143 $

The resulting Spearman rank correlation coefficient is approximately $0.143$, which indicates only a weak correlation between the proxy and full evaluation rankings. However, the sample size is very small ($N=6$), so no strong conclusions can be drawn from this value.

To gather further insights into the performance of the architectures, @full_training_progress illustrates their scores throughout all 100 training epochs. This allows us to examine not only the final score of each architecture, but also how their performance converges and stabilizes during training.

#let full_train10= figure(image("../images/exp1/full_training_progress.png", width: 100%), caption: flex-caption(
  [Full training progress for CVRP10],
  [Full training progress for CVRP10 of best six selected architectures],
))
#full_train10 <full_training_progress>

As shown in @full_training_progress, all evaluated architectures follow similar training trajectories. However, some differences become visible after approximately 30 epochs. From this point, RND-8 generally performs worse than the other architectures, while CGP-2 achieves noticeably better scores and remains the best-performing architecture for the majority of the remaining epochs.

During the first 20 epochs, however, most architectures achieve similar scores, with their relative performance and ranking changing frequently.

This may also explain why the ranking obtained through proxy evaluation was not very accurate. Even under the full evaluation setup, where the training process is ten times longer than in the proxy setup, the ranking remains unstable during the first 20 epochs. The proxy evaluation uses only 10 training epochs in total, meaning that the architectures are compared at a relatively early stage of their training process.

However, it is worth keeping in mind that the training conditions are different between the two setups. The proxy evaluation reuses trained weights whenever possible, while during full evaluation each architecture is trained from scratch. Therefore, the behavior observed during the first epochs of full evaluation cannot be directly transferred to the proxy setting.

=== Transfer to CVRP20

In the previous section, the full evaluation was performed on CVRP10. In this part of the experiment, the selected architectures are evaluated on the larger CVRP20 problem to investigate whether the architectures discovered on CVRP10 maintain their relative performance when transferred to a larger problem size.

The results of the CVRP20 evaluation are presented in @exp1_full_cvrp20. Each architecture is trained from scratch on CVRP20, and the corresponding evaluation seed is reported for reproducibility.  The rows are sorted according to the CVRP10 evaluation ranking, from best to worst.

#figure(
  table(
    columns: (1.5fr, 1.7fr, 1.4fr, 1.5fr, 1.4fr),
    align: (center, center, center, center, center),

    table.header(
      [*Architecture ID*],
      [*Seed*],
      [*CVRP20 score*],
      [*CVRP10 rank*],
      [*CVRP20 rank*],
    ),
    [CGP-2], [155], [6.5181], [1], [2],
    [RND-6], [756], [6.5656], [2], [6],
    [CGP-9], [2399], [6.5068], [3], [1],
    [RND-1], [4486], [6.5536], [4], [5],
    [CGP-3], [2417], [6.5185], [5], [3],
    [RND-8], [2838], [6.5478], [6], [4],
  ),
  caption: [
    Full evaluation of three best candidates for each method on CVRP20, comparing to full evaluation on CVRP10.
  ],
) <exp1_full_cvrp20>

Evaluation on CVRP20 changes the ranking once again. The best score is now achieved by CGP-9 with $6.5068$, followed by CGP-2 with $6.5181$ and CGP-3 with $6.5185$. Although all architectures discovered by CGP-NAS occupy the top three positions, given the noise and ranking instability observed in the previous section, this result alone cannot be treated as strong evidence of the superiority of CGP-NAS over random search.
Nevertheless, the fact that all three CGP-NAS architectures outperform all three random-search architectures on CVRP20 is an interesting observation.

The changes in ranking between CVRP10 and CVRP20 are illustrated in @20cvrp_ranking_stability.

#let ranking_stability= figure(image("../images/exp1/ranking_comparison2.png", width: 80%), caption: flex-caption(
  [Rank stability, full evaluation on CVRP20 vs CVRP10],
  [Rank stability, full evaluation on CVRP20 vs CVRP10],
))
#ranking_stability <20cvrp_ranking_stability>

The ranking also changes considerably between CVRP10 and CVRP20. Interestingly, the Spearman rank correlation coefficient is approximately $0.143$, which is the same value as obtained when comparing the proxy and full evaluation rankings on CVRP10:

$ rho = 1 - (6 sum d_i^2) / (n dot (n^2 -1 )) = 1 - (6 dot 30) / (6 dot (36 - 1)) = 0.143 $

This again indicates only a weak correlation between the rankings and suggests that the relative performance of individual architectures is not stable across different problem sizes.

Final results show that the performance of an architecture on CVRP10 does not necessarily transfer to CVRP20. An interesting observation is that all three architectures discovered by CGP-NAS achieve the best performance on CVRP20. Despite this observation being favorable to the proposed method, the observed ranking instability and the limitations of the proxy evaluation prevent from drawing any strong conclusions from this result.


=== Discussion

Experiment I demonstrated that the proposed CGP-NAS method outperforms random search under the considered proxy evaluation setup. It achieves a better average score across 10 independent runs and also discovers the best-performing architecture. Further analysis of the search progress shows that the advantage of CGP-NAS emerges during the search and is maintained as the computational budget is gradually consumed. This indicates that the underlying evolutionary process is able to guide the search towards promising architectures more effectively than random search under the considered proxy setup.

However, the full evaluation shows that the ranking obtained from the proxy evaluation does not strongly correspond to the ranking after full evaluation. The rankings of the six selected architectures change substantially, with a Spearman rank correlation coefficient of only $0.143$. In particular, the best architecture under proxy evaluation drops to fifth place after full evaluation.

Plotting the scores of the architectures over the training epochs demonstrates this ranking instability and provides a possible explanation. During the initial epochs of training, the architectures achieve comparable scores and their ranking changes frequently. The ranking becomes more stable later in the training process. This may explain the poor predictive ability of the proxy evaluation, which not only uses a reduced training setup, but also trains each architecture for only 10 epochs.

Running the experiment on a bigger problem size, CVRP20, shows once again that the ranking of architectures is unstable. The second-best performing architecture on CVRP10 becomes the last on CVRP20. At the same time, the three best-performing architectures on CVRP20 are those discovered by the proposed CGP-NAS method. However, taking into account the observed ranking instability, it is difficult to determine whether this is a systematic advantage or simply a result of evaluation variability.
The sample size is small and the training is noisy, so it is not sufficient to conclude that bigger problem sizes prefer different types of architectures, although the results suggest this possibility.

To sum up, Experiment I shows that proposed CGP-NAS method can guide the search process more effectively than random search within a restricted computational budget and under the considered proxy evaluation setup. It also shows the limitations of proxy evaluation and its failure to predict the ranking of architectures in a stable way. Therefore, the proxy evaluation ranking cannot be treated as a trustworthy and accurate indicator of final performance, but rather as an estimate.

It is worth noting that this experiment was conducted on a limited sample size and with a limited training budget, due to the high computational cost of training each network. Further experiments on a much broader set of architectures and with less restricted computational resources would be valuable to verify these findings. The transfer between different problem sizes also considers only two relatively small instances, so it is difficult to predict whether the observed behavior would generalize to larger problem sizes as well.

Despite these limitations, the experiment demonstrates that the proposed CGP-NAS approach is capable of discovering competitive architectures and outperforms random search under the considered proxy evaluation setup.

== Experiment II: Evolving the Transformer

As in the previous experiment, the best architecture from each run is given a unique identifier. In this experiment, architectures evolved by proposed CGP-NAS method are denoted as TRANS-N, where N corresponds to the run number (e.g., TRANS-3).

=== Proxy Evaluation Results on CVRP10

The results of the search under the proxy evaluation setup are presented in @exp2_cvrp10_proxy. According to the experimental procedure described in @exp2_procedure, the three best-performing architectures are selected for further evaluation under the full evaluation setup on CVRP10 and CVRP20. These architectures are marked in bold in the table.

It is important to note that the weight sharing described earlier works only for architectures that have a predecessor. This means that the first architecture is initialized with random weights and has no previous architecture from which it can inherit weights.

In this experiment, this is especially important because the Transformer is used as the initial parent. Consequently, its proxy evaluation score is calculated with some disadvantage, as it cannot benefit from weight sharing. On the other hand, this has the useful property of providing the first offspring with a relatively low bar to overcome, allowing the search to explore the architecture space early instead of having to outperform a well-trained Transformer before moving away from the initial architecture.

The search seeds are reported for reproducibility.


#figure(
  table(
    columns: (1fr, 1.5fr, 1.5fr, 1.5fr),
    align: (center, center, center, center),

    table.header(
      [*Run*],
      [*Architecture ID*],
      [*Seed*],
    [*Proxy score*],
    ),
    [1],  [TRANS-1],  [5553], [4.8644],
    [2],  [TRANS-2],  [4546], [4.8536],
    [3],  [TRANS-3],  [5203], [4.9032],
    [4],  [TRANS-4],  [2060], [4.8670],
    [5],  [TRANS-5],  [7903], [4.8693],
    [6],  [TRANS-6],  [], [4.8769],
    [7],  [TRANS-7],  [], [],
    [8],  [TRANS-8],  [], [],
    [9],  [TRANS-9],  [], [],
    [10], [TRANS-10], [], [],
    [Best], [], [], [],
    [Worst], [], [], [],
    [Mean ± SD], [—], [-], [],
    ),
  caption: [
    Proxy evaluation of 10 runs of evolving a single layer Transformer.
  ]
) <exp2_cvrp10_proxy>
