import numpy as np
import sys, os

sys.path.insert(1, '../../_network')
from layers import Network_V2, Perceptron

if __name__ == "__main__":
    # data
    x_train = np.array([ [0,0,1], [1,1,1], [1,0,1], [0,1,1] ])
    y_train = np.array([   [0],     [1],     [1],     [0]   ])
    x_test  = np.array([ [0,1,0] ])

    n_input = len(x_train[0])

    # define network
    network = Network_V2(loss_name="MSE")
    network.add(Perceptron(n_units=1, input_shape=(n_input,), activation="sigmoid"))

    # train network
    network.fit(x_train, y_train, n_epochs=1500, batch_size=1)

    # network results
    y_pred = network.predict(x_test)
    print(f"predict: {y_pred}, rouded answer:{round(y_pred[0][0])}")
    # predict: [[0.44377564]], rouded answer:0


