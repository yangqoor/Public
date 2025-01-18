import pandas as pd
import numpy as np
from tensorflow.keras import models, layers, datasets

# data
(x_train, y_train), (x_test, y_test) = datasets.boston_housing.load_data()

# define network
network = models.Sequential()
network.add(layers.Dense(64, activation="relu", input_shape=(x_train.shape[1],)))
network.add(layers.Dense(64, activation="relu"))
network.add(layers.Dense(1))
network.compile(optimizer="rmsprop", loss="mse", metrics=["mae"])

# train network
network.fit(x_train, y_train, epochs=1500, batch_size=1)

# network results
test_mse_score, test_mae_score = network.evaluate(x_test, y_test)
print(test_mae_score)
