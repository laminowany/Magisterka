// this is an example. Check https://typst.app/universe/package/glossarium

#let glossary = (
  // minimal term
  (key: "gnn", short: "GNN", long: "Graph Neural Networks",
    plural: "GNNs", longplural: "Graph Neural Networks"),
  (key: "gcn", short: "GCN", long: "Graph Convolutional Network",
    plural: "GCNs", longplural: "Graph Convolutional Networks"),
    (key: "gat", short: "GAT", long: "Graph Attention Network",
    plural: "GATs", longplural: "Graph Attention Networks"),
  
  (key: "rl", short: "RL", long: "Reinforcement Learning"),
  (key: "vrp", short: "VRP", long: "Vehicle Routing Problem"),
  (key: "cvrp", short: "CVRP", long: "Capacitated Vehicle Routing Problem",
  "custom": "Capacitated Vehicle Routing Problem (CVRP)"),
  (key: "vrptw", short: "VRPTW", long: "Vehicle Routing Problem with Time Windows"),
  (key: "mdvrp", short: "MDVRP", long: "Multi-Depot Vehicle Routing Problem"),
  (key: "ovrp", short: "OVRP", long: "Open Vehicle Routing Problem"),
  (key: "tsp", short: "TSP", long: "Traveling Salesman Problem"),
  (key: "op", short: "OP", long: "Orienteering Problem"),
  (key: "pctsp", short: "PCTSP", long: "Prize Collecting Traveling Salesman Problem"),
  (key: "cgp", short: "CGP", long: "Cartesian Genetic Programming"),
  (key: "nas", short: "NAS", long: "Neural Architecture Search"),
    (key: "automl", short: "AutoML", long: "Automated Machine Learning"),
  (key: "ml", short: "ML", long: "Machine Learning"),
  (key: "mdp", short: "MDP", long: "Markov Decision Process"),
  (key: "ptrnet", short: "Ptr-Net", long: "Pointer Network"),
  (key: "seq", short: "seq-to-seq", long: "sequence-to-sequence"),
  (key: "lstm", short: "LSTM", long: "Long Short-Term Memory"),
    (key: "rnn", short: "RNN", long: "Recurrent Neural Network",
     plural: "RNNs", longplural: "Recurrent Neural Networks"),
      (key: "cnn", short: "CNN", long: "Convolutional Neural Network",
      plural: "CNNs", longplural: "Convolutional Neural Networks"),


  (key: "kdecom", short: "KDE Community", description:"An international team developing and distributing Open Source software."),
  (key: "nlp", short: "NLP", long: "Natural Language Processing"),
   (key: "msa", short: "MSA", long: "Multiple Sequence Alignment"),
      (key: "ccgp", short: "CCGP", long: "Continuous Cartesian Genetic Programming"),
)
