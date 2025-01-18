"""
Deep Feed Forward model, it contains 3 input values and 
2 hidden layers and the output will contain 2 values
"""
import numpy as np# for math
from sklearn.neural_network import MLPClassifier# for model

if __name__ == "__main__":
    # train data
    X = np.array([
        [1,1,1], 
        [1,1,0], 
        [1,0,0], 
        [0,0,0], 
        [0,0,1], 
        [0,1,1]
    ])

    # train data results
    y = np.array([
        [0, 1],
        [1, 0],
        [0, 1],
        [0, 1],
        [0, 1],
        [1, 0]
    ])

    # define neural network model and trained it 
    neural_network = MLPClassifier(random_state=1, max_iter=300)
    neural_network.fit(X, y)

    # predict
    unknown_input = [[0, 1, 0]]
    result = neural_network.predict(unknown_input)

    print("\n\n")
    print("the prediction of the neural network: " + str(result))
    print("\n\n")