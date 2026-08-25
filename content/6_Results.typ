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

#pagebreak()

==== Random Sampling Analysis

Random search provides a considerable amount of information about the search space. A total of 10 runs were performed, with 200 architectures evaluated in each run. This gives a total of 2000 randomly sampled architectures, which can be used to provide an empirical approximation of the score distribution within the search space.

The distribution of these scores is presented as a histogram in @search_space_hist.

#let search_space_hist = figure(image("../images/exp1/random_score_distribution.png", width: 100%), caption: flex-caption(
  [Distribution of scores obtained through random sampling],
  [Distribution of scores obtained through random sampling],
))
#search_space_hist <search_space_hist>

It is clearly visible that the distribution is strongly skewed to the right. The left plot shows the full range of scores. While most architectures achieve scores below $6$, there is also a noticeable group of architectures with scores above $10$. This suggests that some randomly generated encoder architectures may fail to produce useful embeddings for the decoder, resulting in very poor performance.

The average score is $5.8013$, while the median is considerably lower at $5.0898$, which is also consistent with the long right tail of the distribution. The right plot zooms into the left side of the distribution, showing the region containing the best-performing architectures.

This raises the question of how probable it is for random search to find an architecture as good as those found by the proposed CGP-NAS method. Finding such high-performing architectures through random sampling is relatively unlikely. The best 10% of architectures sampled by random search achieve scores below $4.9437$, while only the best 1% achieve scores below $4.9105$. For comparison, the average best score achieved by the proposed CGP-NAS method was $4.8851$.

This leads to another question: what computational budget would random search require to achieve results similar to those obtained by CGP-NAS with a budget of 200 evaluations? This can be estimated using an empirical simulation based on the observed distribution of randomly sampled architectures.


To estimate this, hypothetical random search runs are simulated by sampling architecture scores with replacement from the empirical distribution of 2000 observed scores. No parametric distribution is assumed, as the simulation samples directly from the empirical distribution of observed scores. For each simulated run, the best-so-far score is recorded as the computational budget increases. The simulation is repeated $50,000$ times, and the mean best-so-far score is calculated for each budget. The results of the simulation are presented in @random_budget_estimates.

#figure(
  table(
    columns: (3fr, 1fr, 1.5fr),
    align: (center, center, center),

    table.header(
            [*Reference*],
      [*Target score*],

      [*Estimated budget*],
    ),

    [Random search mean at budget 200], [4.9022], [147],
     [CGP-NAS mean at budget 200], [4.8851], [2307],
  ),
  caption: [
    Estimated random search budget required to reach selected target scores.
  ],
) <random_budget_estimates>

The empirical simulation estimates that random search would require a budget of approximately 147 evaluations to reach the average score that random search achieved with an actual budget of 200 evaluations. Although the estimate does not exactly match the observed budget, it is of the same order of magnitude.

However, to reach the average score achieved by CGP-NAS, the estimated required budget increases substantially to approximately 2307 evaluations. This is more than an order of magnitude higher than the budget of 200 evaluations used by CGP-NAS.

The resulting expected best-so-far score curve is shown in @random_search_expected.

#let random_search_expected = figure(image("../images/exp1/random_expected_progress.png", width: 100%), caption: flex-caption(
  [Expected best-so-far score of random search in relation to consumed budget],
  [Expected best-so-far score of random search in relation to consumed budget],
))
#random_search_expected <random_search_expected>

This simulation provides important additional context to the analysis. While the absolute difference between random search and the proposed CGP-NAS method is small on average, with scores of $4.9022$ and $4.8851$, respectively, corresponding to an improvement of merely $0.34%$, the estimated difference in the required computational budget is substantial. This suggests that the proposed CGP-NAS method is considerably more efficient at finding high-performing architectures than random search under the considered proxy evaluation setup.

However, it is worth noting that these budget estimates were calculated using a limited dataset. The simulation is based on the empirical distribution of 2000 sampled architectures. Moreover, the estimated budget of approximately 2307 evaluations goes beyond the budget directly evaluated in individual random search runs. Therefore, the results should be treated as an indication of the difference in search efficiency rather than as an exact estimate of the required computational budget.

==== Search Progress

To further investigate and compare how both search strategies perform, @score_to_budget shows the best-so-far proxy score for each strategy as the evaluation budget increases. At each budget value, the score represents the mean of the best scores achieved so far across the 10 independent runs.

#let score_to_budget= figure(image("../images/exp1/search_progress.png", width: 100%), caption: flex-caption(
  [Mean best-so-far score to consumed budget],
  [Mean best-so-far score to consumed budget],
))
#score_to_budget <score_to_budget>


It can be observed that both methods perform similarly up to an evaluation budget of approximately 30. Beyond this point, the mean best-so-far score of CGP-NAS begins to diverge from that of random search and decreases to lower values. The curves subsequently follow relatively similar trajectories, while CGP-NAS slightly develops its advantage throughout the remaining evaluation budget.

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

The random sampling analysis provides additional context for this advantage. Although the difference in the final proxy scores is relatively small, the empirical simulation suggests that random search would require a substantially larger computational budget to reach the average score achieved by CGP-NAS. This indicates that the advantage of CGP-NAS is more visible in terms of search efficiency than in the absolute difference between the final scores.

It is worth noting that this experiment was conducted on a limited sample size and with a limited training budget, due to the high computational cost of training each network. Further experiments on a much broader set of architectures and with less restricted computational resources would be valuable to verify these findings. The transfer between different problem sizes also considers only two relatively small instances, so it is difficult to predict whether the observed behavior would generalize to larger problem sizes as well.

Despite these limitations, the experiment demonstrates that the proposed CGP-NAS approach is capable of discovering competitive architectures and outperforms random search under the considered proxy evaluation setup.

== Experiment II: Evolving the Transformer

As in the previous experiment, the best architecture from each run is given a unique identifier. In this experiment, architectures evolved by the proposed CGP-NAS method are denoted as EVO-N, where N corresponds to the run number (e.g., EVO-3).

=== Proxy Evaluation Results on CVRP10

It is important to note that the weight sharing described earlier works only for 
architectures that have a predecessor. 
This means that the first architecture is initialized with random weights and has no previous architecture from which it can inherit weights.

In this experiment, this is especially important because the Transformer 
is used as the initial parent. As a result, its proxy evaluation score is obtained at a disadvantage, as it cannot benefit from weight sharing.
 On the other hand, this has the useful property of providing the first offspring with a 
 relatively low bar to overcome, allowing the search to explore the architecture space 
 early instead of having to outperform a well-trained Transformer before moving away from 
 the initial architecture.

This also means that the Transformer is evaluated separately in each run. 
Therefore, each evolutionary run competes against a different initial proxy score, 
despite starting from the same single-layer Transformer architecture.

The results of the search under the proxy evaluation setup are presented in @exp2_cvrp10_proxy .The initial Transformer proxy score for each run is reported in the table. 
The search seeds are also reported for reproducibility. The three best-performing evolved
architectures are selected for further evaluation and marked in bold.
The improvement is calculated as the difference between the initial Transformer score and the final score of the best evolved architecture in each run. Because lower scores indicate better performance, a positive improvement value means that the evolved architecture achieved a better proxy score than the starting Transformer architecture.


#figure(
  table(
    columns: (0.5fr, 1.5fr, 1fr, 2.5fr, 1.5fr, 1.5fr),
    align: (center, center, center, center, center, center),

    table.header(
      [*Run*],
      [*Architecture ID*],
      [*Seed*],
          [*Initial Transformer score*],
    [*Proxy score*],
    [*Improvement*]
    ),
    [*1*],  [*EVO-1*],  [*5553*], [*4.9216*], [*4.8644*], [*0.0572*],
    [*2*],  [*EVO-2*],  [*4546*], [*4.8805*], [*4.8536*], [*0.0269*], 
    [3],  [EVO-3],  [5203], [4.9315], [4.9032], [0.0283],
    [4],  [EVO-4],  [2060], [4.9020], [4.8670], [0.0350],
    [5],  [EVO-5],  [7903], [4.9017], [4.8693], [0.0324],
    [6],  [EVO-6],  [5032], [4.8954], [4.8692], [0.0262],
    [7],  [EVO-7],  [4489], [4.9247], [4.8712], [0.0535],
    [8],  [EVO-8],  [8788], [4.8921], [4.8715], [0.0206],
    [9],  [EVO-9],  [6033], [4.9090], [4.8741], [0.0349],
    [*10*], [*EVO-10*], [*1078*], [*4.9069*], [*4.8630*], [*0.0439*],
    ),
  caption: [
    Proxy evaluation results of 10 CGP-NAS runs initialized with a single-layer Transformer.
  ]
) <exp2_cvrp10_proxy>

The results show noticeable variation between individual runs, despite starting from the same architecture. The proxy scores of the initial Transformer also vary considerably between runs, ranging from $4.8805$ to $4.9315$. This behavior once again demonstrates the stochastic nature of the proxy evaluation and shows that a single proxy score should not be treated as an exact measure of architecture performance.

However, the evolutionary search turns out to be quite successful, as the proposed CGP-NAS method manages to improve the starting score in all runs. The improvement ranges from $0.0206$ to $0.0572$. The best score is achieved by EVO-2 with $4.8536$. Interestingly, this run also starts from the best initial Transformer score of $4.8805$. EVO-2 is closely followed by EVO-10 with a score of $4.8630$ and EVO-1 with a score of $4.8644$.

These results demonstrate that the proposed CGP-NAS method is able to consistently improve upon the proxy score of the initial paren by effectively guiding the search. This is particularly notable because the starting architecture is not random, but an already established single-layer Transformer architecture.

However, given the limitations of the proxy evaluation setup and the fact that the Transformer starts from randomly initialized weights, while the final evolved architectures can benefit from weight sharing over multiple generations, it is too early to conclude that the evolved architectures truly improve upon the single-layer Transformer. In the next part of the experiment, the selected architectures and the single-layer Transformer undergo full training from scratch under identical conditions, allowing for a more meaningful comparison.

=== Full Evaluation on CVRP10

In this part of experiment, the top

#figure(
  table(
    columns: (1.5fr, 1.3fr, 1.3fr, 1.5fr, 1.5fr),
    align: (center, center, center, center, center),

    table.header(
      [*Architecture*],
      [*Seed*],
      [*Proxy rank*],
      [*CVRP10 score*],
      [*CVRP10 rank*],
    ),

    [EVO-2], [1111], [1], [4.7630], [3],
    [EVO-10], [7165], [2], [4.7602], [1],
    [EVO-1], [8871], [3], [4.7610], [2],
    [Transformer], [2601], [—], [4.7645], [4],
  ),
  caption: [
    Full evaluation of the three best evolved architectures and
    the single-layer Transformer on CVRP10.
  ],
) <exp2_full_cvrp10>

#figure(
  table(
    columns: (1.5fr, 1.3fr, 1.3fr, 1.5fr, 1.5fr),
    align: (center, center, center, center, center),

    table.header(
      [*Architecture*],
      [*Seed*],
      [*CVRP10 rank*],
      [*CVRP20 score*],
      [*CVRP20 rank*],
    ),
    [EVO-10], [2464], [1], [6.5394], [3],
    [EVO-1], [8470], [2], [6.5315], [1],
    [EVO-2], [3105], [3], [6.5404], [4],

    [Transformer], [2601], [4], [6.5345], [2],
  ),
  caption: [
    Full evaluation of the three best evolved architectures and
    the single-layer Transformer on CVRP20.
  ],
) <exp2_full_cvrp20>