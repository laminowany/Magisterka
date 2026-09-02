#import "../utils.typ": todo, silentheading, flex-caption

= Related Work

== Deep Learning for Routing Problems

=== Hopfield network
First application of neural networks to routing problems can be dated back to 1985, when Hopfield and Tank formulated the @tsp as an energy minimization problem using a recurrent neural network (Hopfield network) @Hopfield. They describe the network through its energy function, where the optimal path is represented by the state with the lowest energy. All constraints like visiting a node only once are modeled through penalties in the energy function. Such constraints, which can be broken but are discouraged through the cost function, are referred to as soft constraints.


=== Pointer Network (Ptr-Net)

A real breakthrough came in 2015 when Vinyals et al. introduced @ptrnet @PointerNetwork, which improved upon the @seq architecture and applied it to combinatorial optimization problems such as the @tsp. @ptrnet follows an encoder-decoder architecture based on recurrent neural networks, with @lstm networks used for both the encoder and decoder.

One of the biggest shortcomings of the @seq architecture was its fixed output vocabulary, where the output dimensionality was determined by the size of a predefined dictionary. @ptrnet addresses this limitation by introducing an attention mechanism that allows the decoder to point directly to elements of the input sequence. This difference is illustrated in @ptrnet_figure. This enables the network to generate a permutation of the input as the output, making it particularly well suited for routing problems. Instead of using a fixed-size output dictionary, the output dimensionality now adapts to the length of the input sequence.

#let ptr_net1= figure(image("../images/PtrNet.png", width: 100%), caption: flex-caption(
  [Comparision of seq-to-seq vs Ptr-Net (source: @PointerNetwork)],
  [Comparision of seq-to-seq vs Ptr-Net],
))
#ptr_net1 <ptrnet_figure>

In his original paper @PointerNetwork, Vinyals et al. applied @ptrnet to several problems, including convex hull, Delaunay triangulation, and the @tsp. The network uses an encoder-decoder architecture, where the input sequence is processed by the encoder and transformed into an internal representation. The decoder then uses this representation to compute a probability distribution over input elements, which are selected as part of the output sequence.
Each decision depends on the current decoder state, and therefore on previously made decisions. Such a model is called autoregressive.

=== Reinforcement Learning

The original @ptrnet was trained using supervised learning with a cross-entropy loss over known optimal solutions. This approach has a serious limitation, as obtaining optimal solutions is not feasible for large-scale real-world problems. Moreover, it defeats the purpose of designing a neural network to solve a combinatorial optimization problem if the optimal solution is already available. Bello et al. addressed this limitation by adopting reinforcement learning instead of supervised learning @Bello. This allows the network to be trained without requiring optimal solutions and to learn directly from the quality of the generated solutions. This was a major step forward in applying neural networks to combinatorial optimization problems.

Their results on larger @tsp instances significantly outperformed those of Vinyals et al. and produced solutions close to the optimum when sufficient computational time was allowed. However, reinforcement learning comes with its own challenges, such as training instability and high variance of the policy gradient estimates.

=== From Recurrent to Feed-Forward Encoders 

A further improvement over @ptrnet:long for combinatorial optimization was proposed by Nazari et al. @Nazari. They replaced the @lstm encoder used in @ptrnet with a feed-forward projection, allowing each node to be embedded independently rather than sequentially. As a result, node embeddings can be efficiently updated whenever the routing state changes, without re-running the entire recurrent encoder. This enables dynamic state information, such as visited nodes or the remaining vehicle capacity, to be incorporated without a significant computational overhead.

Apart from reducing the complexity of handling the dynamic state, 
Nazari's approach also improves permutation invariance.
In routing problems, the order of nodes in the input is arbitrary and should not affect the solution.
However, @rnn:pl are inherently sensitive to the order of their inputs.
By replacing the recurrent encoder with element-wise projections, the resulting node embeddings depend only on the 
features of individual nodes rather than their position in the input sequence, making the encoder permutation-invariant.
However, since each node is embedded independently, the encoder cannot model interactions between customers. Consequently, the representation of each node depends solely on its own features rather than on the global graph structure.

=== The Transformer-Based Approach (Kool)
Going one step further, Kool et al. proposed a transformer-based architecture, 
employing multi-head self-attention in the encoder and an attention-based decoder @Kool. 
Unlike the feed-forward encoder introduced by Nazari the 
transformer encoder produces contextualized node embeddings by allowing each node to attend to every other node in the graph. 
This mechanism can be interpreted as message passing over a fully connected graph, where each node aggregates information from all other nodes, weighted by the corresponding attention scores. Consequently, the embedding of each customer depends not only on its own features but also on the representations of the other nodes, enabling the model to capture global relationships between customers.

This model serves as the baseline for this thesis. As the CGP-based NAS method investigated in this work is applied to its encoder, the architecture is described in greater detail in the following section.

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

As presented in @encoder_kool1, the input nodes are processed by successive multi-head self-attention and feed-forward layers to produce contextualized node embeddings, which are subsequently used by the decoder.

The decoder constructs the route in an autoregressive manner by iteratively selecting the next customer to visit while masking infeasible nodes, such as already visited customers or customers whose demand exceeds the remaining vehicle capacity. The final probabilities of selecting each node are computed using an attention mechanism.

The decoder operates on a context embedding that combines information produced by the encoder with the partial solution constructed so far. Specifically, the context consists of the graph embedding, the embedding of the previously visited node, and the embedding of the first node in the current route. This context is used to compute the query vector for the attention mechanism, while the encoded node representations serve as keys and values.

Another improvement introduced by @Kool was replacing the learned critic network with a rollout baseline in the REINFORCE policy gradient algorithm.
Instead of using a separate neural network to estimate the baseline, Kool uses a baseline generated by greedily decoding solutions with a frozen copy of the current best policy. Whenever a new policy achieves statistically significant improvement, it replaces the current baseline.
This approach reduces the variance of the policy gradient estimates while eliminating the need for an additional network to estimate the baseline, resulting in a simpler and more stable training procedure.

The model proposed by Kool et al. achieves competitive results on several routing problems, including the @tsp, the @cvrp, the @op, and the @pctsp. The introduction of the transformer-based architecture and the rollout baseline improves both solution quality and training stability compared with previously proposed learning-based approaches.


== Neural Architecture Search

@nas:long is a broad umbrella term that encompasses a wide range of methods aimed at automating the design and discovery of neural network architectures. These methods differ in several aspects, including the search space, the search strategy, and the performance estimation technique used to evaluate candidate architectures. Over the years, numerous @nas approaches have been proposed, varying primarily in the way the search is performed and candidate architectures are evaluated.

While @nas is a subfield of @automl:long, the latter encompasses a much broader range of tasks, including feature engineering, hyperparameter optimization, and model selection. In contrast, @nas focuses exclusively on the automatic design and optimization of neural network architectures.

=== Introducing Neural Architecture Search
The term @nas was introduced by Zoph et al. @Zoph in 2017. Their approach uses a controller @rnn to generate architectural hyperparameters, from which the target network is synthesized. Since the controller itself is recurrent, it can naturally generate architectures of variable length. The controller is trained using the REINFORCE policy gradient algorithm, assigning higher probabilities to architectures that achieve better performance and gradually improving the search process over time.
Independently, Baker et al. @Baker proposed a reinforcement learning approach based on Q-learning to automatically design convolutional neural networks. Their method constructs @cnn architectures layer by layer by treating the addition of each layer as an action in a sequential decision-making process. At the time, @cnn:pl represented the state of the art in many deep learning tasks.

=== Evolutionary Neural Architecture Search
Real et al. @Real demonstrated that evolutionary algorithms can also be successfully applied to @nas, achieving competitive results. Their approach maintains a population of candidate architectures and evolves them using tournament selection. New architectures are generated through mutations and inherit the weights of their parents whenever possible, reducing the computational cost of training.
Each architecture is represented by a DNA encoding that specifies its structure and hyperparameters. A mutation corresponds to a single modification of this encoding, such as adding or removing a skip connection, changing the stride of an operation, modifying the learning rate, or resetting network weights. This simple mutation-based evolutionary process proved capable of discovering architectures that matched or outperformed manually designed networks.

=== Cell-Based Neural Architecture Search
While the original @nas proposed by Zoph et al. in 2017 searched for an entire neural network architecture @Zoph, in 2018 Zoph et al. introduced a different approach @Zoph2. Based on the observation that modern neural networks are often composed of repeated computational structures, their method searches only for such a structure, called a cell, and constructs the final architecture by repeatedly stacking the discovered cells. Furthermore, they demonstrated that the search can be performed on smaller image recognition problems, such as CIFAR-10, and the discovered cells can then be transferred to larger-scale image recognition datasets like ImageNet, substantially reducing the computational cost of @nas.

=== Differentiable Neural Architecture Search
All of the previously mentioned approaches were computationally expensive due to the immense size of the search space and the need to train every candidate architecture before it could be evaluated. Furthermore, they all relied on searching over a discrete set of architectural choices. This paradigm changed with DARTS proposed by Liu et al. @DARTS, which relaxed the discrete search space into a continuous one, allowing architectures to be optimized directly using gradient descent. This differentiable formulation significantly reduced the computational cost of neural architecture search while achieving state-of-the-art performance. The continuous relaxation is achieved by representing each connection between nodes as a weighted mixture of candidate operations. During optimization, each operation is assigned a learnable weight, and the final architecture is obtained by selecting the operations with the highest weights.


#let darts= figure(image("../images/DARTS.png", width: 100%), caption: flex-caption(
  [Overview of DARTS from @DARTS],
  [Overview of DARTS],
))
#darts <darts_figure>

This process is illustrated in @darts_figure:

In step (a), at the beginning of the search, the optimal operations are not yet known. 

Step (b) demonstrates the continuous relaxation: instead of choosing a single operation, each edge between nodes contains a weighted combination of all candidate operations. 

Step (c) shows how these weights are learned during the search, causing some operations to become more dominant than others.

 Finally, step (d) shows the discretization process, where the operations with the highest weights are selected to produce the final architecture.


=== Extending NAS to Graph Neural Networks
All of the previously discussed methods were designed for @nas in @cnn:pl, which were the primary focus of research at the time. @nas was extended to @gnn:pl by Gao et al. @GraphNAS. Similar to the original @nas, GraphNAS employs a recurrent controller trained with the REINFORCE algorithm to sequentially generate candidate architectures, which are then evaluated on a downstream graph learning task.

Unlike CNN-oriented @nas methods, the search space is specifically designed for graph neural networks and includes graph-specific architectural choices such as aggregation functions, attention mechanisms, hidden dimensionality, and the number of message-passing layers. GraphNAS demonstrated that @nas can be successfully applied to @gnn:pl.

== Cartesian Genetic Programming in Neural Architecture Search

=== Early Applications of CGP to Neural Architecture Search

One of the first applications of @cgp to @nas was proposed by Suganuma et al. in 2017 @Suganuma. They applied @cgp to evolve the architecture of @cnn:pl. The network architecture is represented as a directed acyclic graph, where each node corresponds to a high-level operation such as convolution, pooling, or summation. For the evolutionary process, the authors employed a modified $(1+lambda)$ evolutionary strategy. The evolved architectures were evaluated on the CIFAR-10 image classification benchmark, demonstrating that @cgp can serve as an effective @nas method capable of discovering competitive architectures.

As a continuation of their earlier work, Suganuma et al. extended their approach by introducing several improvements @Suganuma2. First, they expanded the set of available node functions, increasing the search space and allowing a wider variety of network architectures to emerge. Second, they proposed a rich initialization strategy. Instead of starting from randomly generated architectures, the initial population was based on modified ResNet and DenseNet architectures represented in the @cgp encoding. This allowed the evolutionary process to begin from high-performing architectures and improved the efficiency of the search. Finally, they introduced early termination of poorly performing candidates, reducing the computational cost of the search. These improvements enabled the method to achieve competitive performance on both the CIFAR-10 and CIFAR-100 image classification benchmarks.

While Suganuma et al. focused on image classification, Wu et al. applied CGP-based @nas to a @nlp task, namely sentence classification @Wu. Their proposed method, called CGPNAS, follows the same general principles as the work of Suganuma et al. and does not introduce significant changes to the underlying search mechanism. Instead, its main contribution is demonstrating that CGP-based @nas is not limited to image classification tasks and can be successfully applied to other application domains, such as @nlp.

=== Modern Approaches to NAS with CGP

Traditionally, @cgp is evolved using a mutation-only strategy. This approach was also advocated by the inventor of @cgp, Miller, who argued that crossover is often destructive due to the mismatch between genotype and phenotype in @cgp @MillerCGP. Torabi et al. addressed this limitation by introducing a crossover operator based on @msa @Torabi. The proposed operator aims to preserve common structural patterns shared by high-performing individuals, allowing beneficial building blocks to be inherited by offspring. Benchmarking on the CIFAR-10 and CIFAR-100 datasets demonstrated a significant improvement over the standard mutation-only @cgp approach.

Another major development of the original @cgp algorithm was the introduction of @ccgp by Garcia et al. @Garcia in 2023. By replacing the discrete genotype with a continuous encoding, the proposed representation enables the application of continuous multi-objective optimization algorithms. This allows the search process to optimize not only model accuracy but also objectives such as the number of operations, inference latency, and power consumption. Experimental results demonstrated performance comparable to state-of-the-art approaches while maintaining the flexibility of the @cgp representation.

== Research Gap

@nas:long has been successfully applied to @gnn:pl, while @cgp has also been investigated as a representation and search mechanism for neural architecture optimization. At the same time, learning-based approaches have become increasingly prominent for solving @vrp. However, these research directions have largely developed independently. To the best of our knowledge, @cgp has not previously been investigated as a @nas method for evolving the encoder architecture of the Attention Model proposed by Kool et al. for the @cvrp. This thesis addresses this gap by applying CGP-based architecture search to the model encoder and evaluating whether automatically discovered architectures can improve routing performance over the manually designed baseline.