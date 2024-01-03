import numpy as np
from sklearn.linear_model import Perceptron

if __name__ == "__main__":
    # training data consisting of 4 examples -- 3 input values and 1 output
    train_inputs = np.array(
        [
            [0,0,1],
            [1,1,1],
            [1,0,1],
            [0,1,1]
        ]
    )

    train_results = np.array(
        [
            [0],
            [1],
            [1],
            [0]
        ]
    )

    # initializing the neuron class
    neuron = Perceptron()

    #training taking place
    neuron.fit(train_inputs, train_results)

    predict = np.array([[1, 0, 1]])
    print("predict: ", str(predict))
    print("result:  ", str(int(neuron.predict(predict)[0]*100)) + "% change it is a 1 as result")
