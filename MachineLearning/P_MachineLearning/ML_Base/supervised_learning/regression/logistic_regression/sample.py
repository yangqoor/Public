import numpy as np
import matplotlib.pyplot as plt

class LogisticRegression:
    def __init__(self, batch_size=64, learning_rate=0.1, epochs=1000):
        """
        Contructor for logistic regression.

        Parameter
        ---------
        batch_size: number of batch size using each iteraction
        epochs: max number of interactions to train logistic regression.
        learning_rate: learning_rate algorithm to update weights.
        """
        self.batch_size = batch_size
        self.learning_rate = learning_rate
        self.epochs = epochs

    def _hypothesis(self, X, w):
        """
        Compute the Hypothesis.
        """
        return X.dot(w)

    def sigmoid(self, X, w):
        """
        Sigmoid activation function:
            h = X.w
            s(h) = 1/(1+e^-x)

        Parameter
        ---------
        X: matrix of dataset. shape = (n, d) with n is number of training, d
            is dimension of each vector.

        Return
        ---------
        s(x): value of activation.
        """
        h = self._hypothesis(X, w)
        return 1/(1+np.exp(-h))

    def _cross_entropy_loss(self, y_true, y_pred):
        """
        Compute cross entropy loss.
        """
        m = y_true.shape[0]
        return -np.sum(y_true*np.log(y_pred) + (1-y_true) * np.log(1-y_pred)) / m

    def _gradient(self, X, y_true, y_pred):
        """
        Compute gradient of J with respect to `w`
        """
        m = X.shape[0]
        return (X.T.dot(y_pred - y_true)) / m

    def train(self, train_X, train_y, w):
        """
        Wrapper training function, check the prior condition first
        """
        assert type(train_X) is np.ndarray, "Expected train X is numpy array but got %s" % type(train_X)
        assert type(train_y) is np.ndarray, "Expected train y is numpy array but got %s" % type(train_y)
        train_y = train_y.reshape((-1, 1))

        self.w = w
        # self.w = np.random.normal((train_X.shape[1], 1))

        return self.batch_gradient_descent(train_X, train_y, self.w)
        
    def predict(self, test_X, weight):
        """
        Output sigmoid value of trained parameter w, b.
        Choose threshold 0.5
        """
        pred = self.sigmoid(test_X, weight)
        pred[pred >= 0.5] = 1
        pred[pred < 0.5] = 0
        return pred

    def batch_gradient_descent(self, X, y, weight):
        """
        Main training function        
        """
        loss_history = []
        theta_history = []

        for epoch in range(self.epochs):
            batch_loss = 0
            num_batches = 0
            index = 0

            while index < X.shape[0]:
                index_end = index + self.batch_size
                batch_X = X[index:index_end]
                batch_y = y[index:index_end]
                
                y_pred = self.sigmoid(batch_X, weight)
                loss = self._cross_entropy_loss(batch_y, y_pred)
                theta_history.append(weight)
                loss_history.append(loss)

                grad = self._gradient(batch_X, batch_y, y_pred)
                weight -= self.learning_rate * grad

                batch_loss += loss
                index += self.batch_size
                num_batches += 1

            print(f"\r[{epoch}/{self.epochs}] loss: {batch_loss}", end="")
            
        return loss_history, theta_history, epoch

def get_data(length_data = 100):
    X1 = np.random.multivariate_normal([5, 6], [[5, 1], [1, 5]], length_data)
    X2 = np.random.multivariate_normal([14, 15], [[4, 0], [0, 4]], length_data)
    
    y1 = np.ones( shape=(length_data, 1) )
    y2 = np.zeros( shape=(length_data, 1) )

    return X1, X2, y1, y2

if __name__ == "__main__":
    # data
    X1, X2, y1, y2 = get_data(length_data = 50)

    learning_rate = 0.1
    n_epochs = 1000

    # define model
    model = LogisticRegression(
        batch_size = 64, 
        learning_rate = learning_rate, 
        epochs = n_epochs
    )

    X = np.concatenate((X1, X2), axis=0)
    X = np.concatenate((X, np.ones(shape=(2 * len(X1), 1))), axis=1)
    y = np.concatenate((y1, y2), axis=0)
    w = np.random.normal(size=(X.shape[1], 1))

    """Calculation"""
    costs, thetas, iterations = model.batch_gradient_descent(X, y, w)
    y = model.predict(X, thetas[-1])

    # calculate data visualization
    X1 = X[:len(X1), :]
    X2 = X[len(X1):, :]
    y1 = y[:len(X1), :]
    y2 = y[len(X1):, :]

    # straight line corner to corner
    line = np.linspace(0, 20, num=len(X1)).reshape((-1, 1))
    bias = np.ones((len(X1), 1))

    line_plot = np.concatenate((line, line, bias), axis=1)
    line_plot = model.sigmoid(line_plot, thetas[-1])
    line_z = np.squeeze(line_plot)

    # display model
    plt.figure(1, figsize=(6, 6))

    ax = plt.axes(projection='3d')
    ax.set_title("Loss: " + str(costs[-1]), fontsize=20)
    ax.set_xlabel("x axis", fontsize=14)
    ax.set_ylabel("y axis", fontsize=14)
    ax.set_zlabel("z axis", fontsize=14);

    label = "Iterations: " + str(iterations)
    ax.scatter(line, line, line_z, cmap='viridis', linewidth=0.5, label=label);
    ax.scatter(X1[:, 0], X1[:, 1], y1, c="b", label="Class 1")
    ax.scatter(X2[:, 0], X2[:, 1], y2,  c="r", label="Class 0")
    
    plt.show()