import pandas as pd
import numpy as np
import sys, os
from tensorflow.keras import datasets

sys.path.insert(1, '../../_network')
from layers import Network_V2, Dense_V2

# data
(x_train, y_train), (x_test, y_test) = datasets.boston_housing.load_data()

# define network
network = Network_V2(loss_name="MSE")
network.add(Dense_V2(64, activation="relu", input_shape=(x_train.shape[1],), optimizer="adam"))
network.add(Dense_V2(64, activation="relu", input_shape=(64,), optimizer="adam"))
network.add(Dense_V2(1, input_shape=(64,), optimizer="adam"))

# sample
print(x_train[13])
print(y_train[13])

# train network
network.fit(x_train, y_train, n_epochs=700)

unknown_input = np.array([[ 2.23, 0.00, 3.14, 0.00, 0.24, 2.14, 65.70, 3.28, 2.20, 207.00, 17.00, 396.90, 15.72 ]])
y_pred = network.predict(unknown_input)
print(y_pred)