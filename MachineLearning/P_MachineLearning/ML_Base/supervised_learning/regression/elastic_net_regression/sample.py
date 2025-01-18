import numpy as np
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt

# dataset
x_train = np.array([[1.1], [1.3], [1.5], [2.0], [2.2], [2.9], [3.0], [3.2], [3.2], [3.7], [3.9], [4.0], [4.0], [4.1], [4.5], [4.9], [5.1], [5.3], [5.9], [6.0], [6.8], [7.1], [7.9], [8.2], [8.7], [9.0], [9.5], [9.6], [10.3], [10.5]])
y_train = np.array([39343, 46205, 37731, 43525, 39891, 56642, 60150, 54445, 64445, 57189, 63218, 55794, 56957, 57081, 61111, 67938, 66029, 83088, 81363, 93940, 91738, 98273, 101302, 113812, 109431, 105582, 116969, 112635, 122391, 121872])
X_train, X_test, Y_train, Y_test = train_test_split( x_train, y_train, test_size=0.333, random_state=0) 

class ElasticRegression():

    # Function for model training
    def fit(self, X, Y, n_epochs=1000):
        # no_of_training_examples, no_of_features
        self.m, self.n = X.shape

        # weight initialization
        self.W = np.zeros(self.n)
        self.X, self.Y = X, Y
        self.b = 0

        # Gradient descent learning
        for epoch in range(n_epochs):
            self.update_weights()

    # Helper function to update weights in gradient descent
    def update_weights(self, learning_rate=0.01, delta_1=500, delta_2=1):
        Y_pred = self.predict(self.X)

        # calculate gradients
        dW = np.zeros(self.n)

        for j in range(self.n):
            if self.W[j] > 0:
                dW[j] = (-(2 * (self.X[:, j]).dot(self.Y - Y_pred)) + delta_1 + 2 * delta_2 * self.W[j]) / self.m
            else:
                dW[j] = (-(2 * (self.X[:, j]).dot(self.Y - Y_pred)) - delta_1 + 2 * delta_2 * self.W[j]) / self.m

        db = -2 * np.sum(self.Y - Y_pred) / self.m

        # update weights
        self.W = self.W - learning_rate * dW
        self.b = self.b - learning_rate * db

    def predict(self, X):
        return X.dot(self.W) + self.b

if __name__ == "__main__":
    # Model training 
    model = ElasticRegression() 
    model.fit(X_train, Y_train) 
      
    # Prediction on test set 
    Y_pred = model.predict( X_test ) 
      
    print( "Predicted values ", np.round( Y_pred[:3], 2 ) )  
    print( "Real values      ", Y_test[:3] ) 
    print( "Trained W        ", round( model.W[0], 2 ) ) 
    print( "Trained b        ", round( model.b, 2 ) ) 
      
    # Visualization on test set  
    plt.scatter( X_test, Y_test, color = 'blue' ) 
    plt.plot( X_test, Y_pred, color = 'orange' ) 
    plt.title( 'Salary vs Experience' ) 
    plt.xlabel( 'Years of Experience' ) 
    plt.ylabel( 'Salary' ) 
    plt.show() 
