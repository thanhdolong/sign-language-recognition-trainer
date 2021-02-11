
import turicreate as tc
import pandas as pd


# MARK: Properties
NUM_ITERATIONS = 5
SINGLE_ITERATION_LEN = 10
stats = {
    "random_forest": {},
    "boosted_trees": {},
    "logistic_regression": {}
}


def load_dataset(file_location: str):

    print("Starting to load the dataset.")

    # Load the datset csv file
    df = pd.read_csv(file_location, encoding="utf-8")

    # Construct the SFrame for training from the data
    sframe = tc.SFrame(data=df)

    print("Dataset loading finished.")

    return sframe


data = load_dataset("normalization/result.csv")

print("Starting the experiments.")

# Iterate over the given set of sizes and experiment with various maximum iterations
for iteration_index in list(range(NUM_ITERATIONS))[1:]:
    max_iterations = iteration_index * SINGLE_ITERATION_LEN

    # Model type: Random forest
    model_rf = tc.random_forest_classifier.create(data, target="labels", features=None, verbose=False,
                                                  max_iterations=max_iterations)
    stats["random_forest"][max_iterations] = {"accuracy": model_rf.training_accuracy,
                                              "recall": model_rf.training_recall,
                                              "precision": model_rf.training_precision}

    # Model type: Boosted trees
    model_bt = tc.boosted_trees_classifier.create(data, target="labels", features=None, verbose=False,
                                                  max_iterations=max_iterations)
    stats["boosted_trees"][max_iterations] = {"accuracy": model_bt.training_accuracy,
                                              "recall": model_bt.training_recall,
                                              "precision": model_bt.training_precision}

    # Model type: Logistic regression
    model_lr = tc.logistic_classifier.create(data, target="labels", features=None, verbose=False,
                                                  max_iterations=max_iterations)
    stats["logistic_regression"][max_iterations] = {"accuracy": model_lr.training_accuracy,
                                              "recall": model_lr.training_recall,
                                              "precision": model_lr.training_precision}


print("Experiments finished.")
print("Constructing the results table of the experiments.")

# Construct the results of the experiment
results_df = pd.DataFrame(columns=["iterations", "random_forest", "boosted_trees", "logistic_regression"])

iterations = [iteration_index * SINGLE_ITERATION_LEN for iteration_index in list(range(NUM_ITERATIONS))[1:]]
results_df["iterations"] = iterations
results_df["random_forest"] = [stats["random_forest"][iteration] for iteration in iterations]
results_df["boosted_trees"] = [stats["boosted_trees"][iteration] for iteration in iterations]
results_df["logistic_regression"] = [stats["logistic_regression"][iteration] for iteration in iterations]

# Write the statistics to file
results_df.to_csv("output/results.csv", encoding="utf-8")
