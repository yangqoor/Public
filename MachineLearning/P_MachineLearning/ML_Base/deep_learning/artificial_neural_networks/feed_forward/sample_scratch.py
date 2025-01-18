import numpy as np
import sys, os

sys.path.insert(1, '../../_network')
from layers import Network_V2, Dense_V2

# Example way of usage (Feed Forwarded)
if __name__ == "__main__":
    # train data
    X_train = np.array([ [1,1,1], [1,1,0], [1,0,0], [0,0,0], [0,0,1], [0,1,1] ])
    y_train = np.array([  [0,1],   [0,1],   [1,0],   [0,1],   [0,1],   [0,1]  ])
    X_test  = np.array([ [0,1,0] ])

    # define network
    network = Network_V2(loss_name="MSE")
    network.add(Dense_V2(3, input_shape=(3, ), activation="sigmoid"))
    network.add(Dense_V2(3, input_shape=(3, ), activation="sigmoid"))
    network.add(Dense_V2(2, input_shape=(3, ), activation="sigmoid"))

    # train network
    network.fit(X_train, y_train, n_epochs=1500)

    # network result
    y_pred = network.predict(X_test)
    print(f"prediction on [0,1,0] is {y_pred} ([{round(y_pred[0][0])}, {round(y_pred[0][1])}])")
