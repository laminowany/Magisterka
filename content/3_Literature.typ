#import "../utils.typ": todo, silentheading, flex-caption

= Literature Review

== Deep Learning for Routing Problems

=== Hopfield network
First application of neural networks to routing problems can be dated back to 1985, when Hopfield and Tank formulated the TSP as an energy minimization problem using a recurrent neural network (Hopfield network) @Hopfield. They describe the network through its energy function, where the optimal path is represented by the state with the lowest energy. All constraints like visiting a node only once are modeled through penalties in the energy function. Such constraints, which can be broken but are discouraged through the cost function, are referred to as soft constraints.


=== Pointer Network (Ptr-Net)

A real breakthrough came in 2015 when Vinyals introduced Pointer Networks (Ptr-Net) @PointerNetwork, which improved upon the sequence-to-sequence (seq-to-seq) architecture and applied it to combinatorial optimization problems such as the Traveling Salesman Problem. One of the biggest shortcomings of the seq-to-seq architecture was its fixed output vocabulary, where the output dimensionality was determined by the size of a predefined dictionary. Ptr-Net addresses this limitation by introducing an attention mechanism that allows the decoder to point directly to elements of the input sequence. This enables the network to generate a permutation of the input as the output, making it particularly well suited for routing problems. Instead of using a fixed-size output dictionary, the output dimensionality now adapts to the length of the input sequence.

#let ptr_net1= figure(image("../images/PtrNet.png", width: 100%), caption: flex-caption(
  [Comparision of seq-to-seq vs Ptr-Net from @PointerNetwork],
  [Comparision of seq-to-seq vs Ptr-Net],
))
#ptr_net1 <ptrnet_figure>

In his original paper @PointerNetwork, Vinyals et al. applied Ptr-Net to several problems, including convex hull, Delaunay triangulation, and the Traveling Salesman Problem. The network uses an encoder-decoder architecture, where the input sequence is processed by the encoder and transformed into an internal representation. The decoder then uses this representation to compute a probability distribution over input elements, which are selected as part of the output sequence.
Each decision depends on the current decoder state, and therefore on previously made decisions. Such a model is called autoregressive.

=== Reinforcement Learning

The original Ptr-Net was trained using supervised learning with a cross-entropy loss over known optimal solutions. This approach has a serious limitation, as obtaining optimal solutions is not feasible for large-scale real-world problems. Moreover, it defeats the purpose of designing a neural network to solve a combinatorial optimization problem if the optimal solution is already available. Bello et al. @Bello addressed this limitation by adopting reinforcement learning instead of supervised learning. This allows the network to be trained without requiring optimal solutions and to learn directly from the quality of the generated solutions. This was a major step forward in applying neural networks to combinatorial optimization problems.

Their results on larger TSP instances significantly outperformed those of Vinyals et al. and produced solutions close to the optimum when sufficient computational time was allowed. However, reinforcement learning comes with its own challenges, such as training instability and high variance of the policy gradient estimates.

=== From RNN to Feed-Forward Encoders 

A further improvement over Pointer Networks for combinatorial optimization was proposed by Nazari et al. @Nazari. They replaced the LSTM encoder used in Pointer Networks with a feed-forward projection, allowing each node to be embedded independently rather than sequentially. As a result, node embeddings can be efficiently updated whenever the routing state changes, without re-running the entire recurrent encoder. This enables dynamic state information, such as visited nodes or the remaining vehicle capacity, to be incorporated without a significant computational overhead.

Apart from reducing the complexity of handling the dynamic state, 
Nazari's approach also improves permutation invariance.
In routing problems, the order of nodes in the input is arbitrary and should not affect the solution.
However, RNNs are inherently sensitive to the order of their inputs.
By replacing the recurrent encoder with element-wise projections, the resulting node embeddings depend only on the 
features of individual nodes rather than their position in the input sequence, making the encoder permutation-invariant.
However, since each node is embedded independently, the encoder cannot model interactions between customers. Consequently, the representation of each node depends solely on its own features rather than on the global graph structure.

=== The Transformer-Based Approach (Kool)
Going one step further, Kool @Kool proposed a Transformer-based architecture, 
employing multi-head self-attention in the encoder and an attention-based decoder. 
Unlike the feed-forward encoder introduced by Nazari the 
Transformer encoder produces contextualized node embeddings by allowing each node to attend to every other node in the graph. 
Consequently, the embedding of each customer depends not only on its own features but also on the entire graph structure, 
enabling the model to capture global relationships between customers.
In addition, Kool improved the REINFORCE training procedure by introducing a rollout baseline, 
eliminating the need for a separate critic network and simplifying the overall training architecture.
This model serves as the baseline for this thesis. Since the proposed NAS method is applied to its encoder, the architecture is described in greater detail below.

The initial node embeddings are obtained via linear projection: 
$ h_i^((0)) = W^x x_i + b^x $
where, $W^x$ and $b^x$ are learnable parameters. These embeddings are then processed and iteratively updated by the stacked multi-head self-attention and feed-forward layers of the encoder.

The encoder also computes an embedding for entire graph $overline(h)^"(N)"$, by taking an average of all final nodes embeddings:
$ overline(h)^"(N)"  = 1 / n sum_"i=1"^n h_i^"(N)" $ 

The output of encoder consists of final node embeddings $h_i^"(N)"$ and the graph embedding $overline(h)^"(N)"$.

#let encoder_kool1 = figure(image("../images/encoderKool.png", width: 100%), caption: flex-caption(
  [The encoder architecture of Kool model from @Kool],
  [The encoder architecture of Kool model],
))
#encoder_kool1 <encoder_kool1>

As presented on @encoder_kool1, the input nodes are processed by successive multi-head self-attention and feed-forward layers to produce contextualized node embeddings, which are subsequently used by the decoder.

The decoder constructs the route in an autoregressive manner by iteratively selecting the next customer to visit while masking infeasible nodes, such as already visited customers or customers whose demand exceeds the remaining vehicle capacity. The final probabilities of selecting each node are computed using an attention mechanism.

The decoder operates on a context embedding that combines information produced by the encoder with the partial solution constructed so far. Specifically, the context consists of the graph embedding, the embedding of the previously visited node, and the embedding of the first node in the current route. This context is used to compute the query vector for the attention mechanism, while the encoded node representations serve as keys and values.

Another novelty introduced by @Kool was replacing the learned critic network with a rollout baseline in the REINFORCE policy gradient algorithm.
Instead of using a separate neural network to estimate the baseline, Kool uses a baseline generated by greedily decoding solutions with a frozen copy of the current best policy. Whenever a new policy achieves statistically significant improvement, it replaces the current baseline.
This approach reduces the variance of the policy gradient estimates while eliminating the need for an additional network to estimate the baseline, resulting in a simpler and more stable training procedure.

The model proposed by Kool achieves close to state-of-the-art results on several routing problems, including the Traveling Salesman Problem (TSP), the Capacitated Vehicle Routing Problem (CVRP), the Orienteering Problem (OP), and the Prize Collecting Traveling Salesman Problem (PCTSP). The introduction of the Transformer-based architecture and the rollout baseline improves both the solution quality and the stability of training.
In this thesis, the model proposed by Kool serves as the baseline for the proposed Neural Architecture Search method. The main objective is to evolve the Transformer encoder while preserving the decoder, reinforcement learning framework, and the remaining components of the architecture unchanged.

== Neural Architecture Search for Graph Neural Networks

== Cartesian Genetic Programming in Automated Machine Learning