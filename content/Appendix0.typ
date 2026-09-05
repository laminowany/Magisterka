#import "../utils.typ": todo, silentheading, flex-caption
#import "../requirements.typ": wut-thesis, cheq
#import cheq: checklist

#show: checklist


= Program Usage Instructions <appendix0>

== Dependencies 

The minimum required Python version is Python 3.10.

Python dependencies are specified in `pyproject.toml`.

Additionally, the `graphviz` system package is required. On Ubuntu, it can be installed with:

```bash
sudo apt install graphviz
```

== Overview

The software developed as part of this thesis is run from the command line. The main entry point is `run.py`, which supports several execution modes for architecture search, full training, dataset generation, and model evaluation.

The general command format is:

#raw(block: true, lang: "bash", "python run.py --mode MODE [OPTIONS]")

The available modes are:

- `cgp_search` -- CGP-based architecture search,
- `random_search` -- random architecture search,
- `genome_evaluation` -- training and evaluation of a specified genome,
- `scoring` -- evaluation of a trained model checkpoint on a test dataset,
- `generate_validation_data` -- generation of a fixed CVRP dataset.

== Common Parameters

The most important command-line parameters are:

#table(
  columns: (auto, auto),
  inset: 6pt,
  [*Parameter*], [*Description*],
  [`--mode`], [Execution mode.],
  [`--seed`], [Random seed. The default value is `1234`. Setting it to `-1` generates a random seed.],
  [`--graph_size`], [Number of customers in the CVRP instance.],
  [`--epoch_size`], [Number of training instances generated per epoch.],
  [`--n_epochs`], [Number of training epochs. The default value is `100`.],
  [`--budget`], [Number of architecture evaluations available during architecture search. The default value is `200`.],
  [`--x_dim`], [Number of columns in the CGP grid.],
  [`--y_dim`], [Number of rows in the CGP grid.],
  [`--validation_set_path`], [Path to a fixed validation dataset.],
  [`--test_set_path`], [Path to a test dataset.],
  [`--checkpoint_path`], [Path to a model checkpoint containing trained weights.],
  [`--run_name`], [Optional name added to the generated experiment directory.],
  [`--no_progress_bar`], [Boolean flag. Disables the animated progress bar during neural network training.],
  [`--no_save_model`],  [Boolean flag. Prevents model weights from being saved.],
  [`--start_from_transformer`], [Boolean flag. Uses the transformer as the initial parent.]
)

The training procedure uses the rollout baseline and eight attention heads. These values are fixed internally by the implementation.

== CGP Search

To reproduce the CGP search from Experiment I, the following command can be used:

#raw(block: true, lang: "bash", "python run.py \
  --mode cgp_search --x_dim 15 --y_dim 5 \
  --n_epochs 10 --epoch_size 12800 --graph_size 10 \
  --no_progress_bar --no_save_model --seed -1 \
  --validation_set_path data/dataset_10CVRP_seed_3232.pt")

This will run the CGP search using the default computational budget (200).

To reproduce the first phase of Experiment II, initialize the search from the transformer by adding the `--start_from_transformer`. The number of transformer layers depends on `x_dim`. The program will create as many layers as fit within the specified grid.
To reproduce Experiment II:

#raw(block: true, lang: "bash", "python run.py \
  --mode cgp_search --start_from_transformer --x_dim 8 --y_dim 5 \
  --n_epochs 10 --epoch_size 12800 --graph_size 10 \
  --no_progress_bar --no_save_model --seed -1 \
  --validation_set_path data/dataset_10CVRP_seed_3232.pt")

== Random Search

To run random search from Experiment I:

#raw(block: true, lang: "bash", "python run.py \
  --mode random_search --x_dim 15 --y_dim 5 \
  --n_epochs 10 --epoch_size 12800 --graph_size 10 \
  --no_progress_bar --no_save_model --seed -1 \
  --validation_set_path data/dataset_10CVRP_seed_3232.pt")

In this mode, architectures are generated randomly from the same architecture search space. 

== Genome Training and Evaluation

This mode creates an encoder based on the architecture provided through the `--genome` argument.

To train EVO-3 from Experiment II on CVRP100:

#raw(block: true, lang: "bash", "python run.py \
  --mode genome_evaluation --x_dim 8 --y_dim 5 --graph_size 100 \
  --n_epochs 100 --epoch_size 1280000 \
  --genome \"[None, (5, 0), (1, 17), (7, 18), (5, 27), (7, 20), (1, 21), (5, 22), (7, 7), (4, 0), (3, 33, 1), (4, 2), (6, 19), (1, 4), (7, 5), (2, 38), (6, 15), (2, 0), (5, (1, 9)), (5, 26), (3, 3, 1), (1, 12), (3, 5, -1), (4, 30), (2, 7), (7, 0), (6, 25), (3, 34, -1), (2, 35), (1, 28), (2, 21), (7, 38), (7, 23), (2, 0), (7, 25), (1, 34), (5, 3), (4, 28), (4, 13), (2, 30), (7, 23), (5, 24)]\" \
  --validation_set_path data/dataset_100CVRP_seed_3232.pt")

The value passed to `--genome` must use a valid Python list representation.

== Evaluation of a Trained Model

A trained model can be evaluated on an existing test dataset using the `scoring` mode. To evaluate the score of EVO-3 from Experiment II on CVRP100 test dataset:

#raw(block: true, lang: "bash", "python run.py \
  --checkpoint_path ../saved_weights/EVO-3/epoch-99.pt \
  --mode scoring --x_dim 8 --y_dim 5 \
  --genome \"[None, (5, 0), (1, 17), (7, 18), (5, 27), (7, 20), (1, 21), (5, 22), (7, 7), (4, 0), (3, 33, 1), (4, 2), (6, 19), (1, 4), (7, 5), (2, 38), (6, 15), (2, 0), (5, (1, 9)), (5, 26), (3, 3, 1), (1, 12), (3, 5, -1), (4, 30), (2, 7), (7, 0), (6, 25), (3, 34, -1), (2, 35), (1, 28), (2, 21), (7, 38), (7, 23), (2, 0), (7, 25), (1, 34), (5, 3), (4, 28), (4, 13), (2, 30), (7, 23), (5, 24)]\" \
  --test_set_path data/dataset_100CVRP_seed_2323.pt")

The program reconstructs the encoder from the provided genome, loads the model parameters from the checkpoint, and evaluates the model on the specified test set.

The final routing score and the number of active encoder parameters are printed after evaluation.

Test datasets may be stored either as PyTorch files or as `.pkl` files. Pickle datasets are converted internally to the representation expected by the CVRP implementation.

== Dataset Generation

A fixed CVRP dataset can be generated using:

#raw(block: true, lang: "bash", "python run.py \
  --mode generate_validation_data \
  --graph_size 10 \
  --seed 2323")

The resulting dataset is stored in the experiment output directory using a file name containing the problem size and random seed.

For example:

#raw(block: true, lang: "text", "dataset_10CVRP_seed_2323.pt")

The same generated dataset can later be supplied using `--validation_set_path` or `--test_set_path`.

== Output Files

Each run creates a separate timestamped directory of the form:

#raw(block: true, lang: "text", "outputs/run_YYYYMMDDTHHMMSS_NAME/")

For architecture search modes, additional directories are created:

#raw(block: true, lang: "text", "genomes_full/
genomes_active/
parents/")

The `genomes_full` directory contains visualizations of complete CGP genotypes, including inactive nodes. The `genomes_active` directory contains visualizations of the corresponding active computational graphs. The `parents` directory stores visualizations of architectures selected as parents during evolution.

The program also records candidate genomes, evaluation scores, evolutionary progress, and budget usage during the experiment.
