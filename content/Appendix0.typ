#import "../utils.typ": todo, silentheading, flex-caption
#import "../requirements.typ": wut-thesis, cheq
#import cheq: checklist

#show: checklist



= Program Usage Instructions <appendix0>

The software developed as part of this thesis is operated from the command line. The main entry point is `run.py`, which supports several execution modes for architecture search, full training, dataset generation, and model evaluation.

The general command format is:

#raw(block: true, lang: "bash", "python run.py --mode MODE [OPTIONS]")

The available modes are:

- `cgp` -- CGP-based architecture search,
- `random_search` -- random architecture search,
- `evolve_transformer` -- CGP evolution initialized from a single-layer Transformer encoder,
- `full_evaluation` -- full training and evaluation of a selected architecture,
- `genome_evaluation` -- direct evaluation of a specified genome,
- `generate_validation_data` -- generation of a fixed CVRP dataset,
- `scoring` -- evaluation of a trained model checkpoint on a test dataset.

== Common Parameters

The most important command-line parameters are:

#table(
  columns: (auto, auto),
  inset: 6pt,
  [*Parameter*], [*Description*],
  [`--mode`], [Execution mode.],
  [`--seed`], [Random seed. The default value is `1234`. Setting it to `-1` generates a random seed.],
  [`--graph_size`], [Number of customers in the CVRP instance. The default value is `10`.],
  [`--batch_size`], [Training batch size. The default value is `512`.],
  [`--epoch_size`], [Number of training instances generated per epoch.],
  [`--n_epochs`], [Number of training epochs. The default value is `100`.],
  [`--budget`], [Number of architecture evaluations available during architecture search. The default value is `200`.],
  [`--x_dim`], [Number of columns in the CGP grid.],
  [`--y_dim`], [Number of rows in the CGP grid.],
  [`--validation_set_path`], [Path to a fixed validation dataset.],
  [`--test_set_path`], [Path to a test dataset.],
  [`--output_dir`], [Directory in which experiment outputs are stored.],
  [`--run_name`], [Optional name added to the generated experiment directory.],
  [`--no_cuda`], [Disables CUDA and runs the program on the CPU.],
)

Unless CUDA is explicitly disabled, the program uses a CUDA-capable GPU when one is available.

The training procedure uses the rollout baseline and eight attention heads. These values are fixed internally by the implementation.

== CGP Architecture Search

CGP-based architecture search is started using:

#raw(block: true, lang: "bash", "python run.py \
  --mode cgp \
  --budget 200 \
  --x_dim 15 \
  --y_dim 5 \
  --graph_size 10 \
  --seed 1234")

The program first generates a random CGP encoder architecture and evaluates it. It then repeatedly produces mutated offspring and evaluates them using the configured proxy training procedure.

The `--budget` parameter specifies the number of candidate evaluations available during the search. Architectures that are equivalent to previously evaluated architectures may reuse an existing score and do not require another training run.

The outputs of the search are stored in a timestamped directory under `--output_dir`.

== Random Search

Random search can be executed using:

#raw(block: true, lang: "bash", "python run.py \
  --mode random_search \
  --budget 200 \
  --x_dim 15 \
  --y_dim 5 \
  --graph_size 10 \
  --seed 1234")

In this mode, architectures are generated randomly from the same CGP search space. Duplicate architectures are skipped. Each unique architecture is trained and evaluated independently.

This mode is used as the baseline for comparison with CGP-based architecture search.

== Evolution Starting from the Transformer

Evolution initialized from a predefined single-layer Transformer encoder is executed using:

#raw(block: true, lang: "bash", "python run.py \
  --mode evolve_transformer \
  --budget 200 \
  --x_dim 8 \
  --y_dim 5 \
  --graph_size 10 \
  --seed 1234")

In this mode, the initial parent is not randomly generated. Instead, a CGP representation of the single-layer Transformer encoder is constructed and used as the starting architecture.

Subsequent architectures are produced and evaluated using the same evolutionary procedure as in the standard CGP mode.

== Full Evaluation of a Selected Architecture

Architectures produced during architecture search are stored together with their identifiers and genomes. A selected candidate can later be trained using the full training configuration.

The command has the following form:

#raw(block: true, lang: "bash", "python run.py \
  --mode full_evaluation \
  --genome_path PATH_TO_SEARCH_RESULTS \
  --id CANDIDATE_ID \
  --graph_size 10 \
  --n_epochs 100 \
  --epoch_size 128000 \
  --seed 1234")

Both `--genome_path` and `--id` are required in this mode.

The program loads `candidates.csv` from the directory specified by `--genome_path`, finds the row corresponding to the requested candidate identifier, reconstructs its genome, and trains the resulting model.

This mode is used to train selected architectures from scratch after the proxy-based architecture search.

== Direct Genome Evaluation

A genome can also be provided directly from the command line:

#raw(block: true, lang: "bash", "python run.py \
  --mode genome_evaluation \
  --genome \"[GENOME]\" \
  --graph_size 10")

The value passed to `--genome` must use a valid Python list representation. It is parsed internally and used to construct the corresponding CGP encoder.

An optional name can be assigned using:

#raw(block: true, lang: "bash", "--genome_name NAME")

== Dataset Generation

A fixed CVRP dataset can be generated using:

#raw(block: true, lang: "bash", "python run.py \
  --mode generate_validation_data \
  --graph_size 10 \
  --val_test_size 10000 \
  --seed 2323")

The resulting dataset is stored in the experiment output directory using a file name containing the problem size and random seed.

For example:

#raw(block: true, lang: "text", "dataset_10CVRP_seed_2323.pt")

The same generated dataset can later be supplied using `--validation_set_path` or `--test_set_path`.

== Evaluation of a Trained Model

A trained model can be evaluated on an existing test dataset using the `scoring` mode:

#raw(block: true, lang: "bash", "python run.py \
  --mode scoring \
  --genome \"[GENOME]\" \
  --checkpoint_path PATH_TO_CHECKPOINT \
  --test_set_path PATH_TO_TEST_SET \
  --graph_size 100")

The program reconstructs the encoder from the provided genome, loads the model parameters from the checkpoint, and evaluates the model on the specified test set.

The final routing score and the number of active encoder parameters are printed after evaluation.

Test datasets may be stored either as PyTorch files or as `.pkl` files. Pickle datasets are converted internally to the representation expected by the CVRP implementation.

== Output Files

Each run creates a separate timestamped directory of the form:

#raw(block: true, lang: "text", "outputs/run_YYYYMMDDTHHMMSS_NAME/")

For architecture search modes, additional directories are created:

#raw(block: true, lang: "text", "genomes_full/
genomes_active/
parents/")

The `genomes_full` directory contains visualizations of complete CGP genotypes, including inactive nodes. The `genomes_active` directory contains visualizations of the corresponding active computational graphs. The `parents` directory stores visualizations of architectures selected as parents during evolution.

The program also records candidate genomes, evaluation scores, evolutionary progress, and budget usage during the experiment.

== Reproducing an Experiment

To reproduce an experiment, the same execution mode, random seed, dataset, training parameters, CGP grid dimensions, and computational budget should be used.

For example, a CGP search corresponding to a CVRP10 experiment can be executed using:

#raw(block: true, lang: "bash", "python run.py \
  --mode cgp \
  --graph_size 10 \
  --budget 200 \
  --x_dim 15 \
  --y_dim 5 \
  --n_epochs 10 \
  --epoch_size 12800 \
  --batch_size 512 \
  --validation_set_path PATH_TO_VALIDATION_SET \
  --seed 1234")