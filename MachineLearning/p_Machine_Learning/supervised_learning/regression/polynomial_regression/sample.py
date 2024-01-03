import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def hypothesis(X, gradient):
    value = np.sum((gradient * X), axis=1)

    return value

def cost(X, y, gradient):
    h = hypothesis(X, gradient)
    return sum((h-y) ** 2)  / (2 * m)

def gradient_descent(X, y, gradient, learning_rate, n_epochs):
    cost_history = []

    for i in range(n_epochs):
        predictions = X.dot(gradient)

        # loss
        errors = (predictions - y)
        gradient = gradient - (learning_rate / m) * X.T.dot(errors)

        cost_history.append(cost(X, y, gradient))

    return cost_history, gradient

# create data
x_train = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
y_train = np.array([45000, 50000, 60000, 80000, 110000, 150000, 200000, 300000, 500000, 1000000])
X = pd.DataFrame(x_train, columns=['Level'])

X['Level1'] = X['Level'] ** 2
X['Level2'] = X['Level'] ** 3
X.head()

# rescale/normalize data
X = X/X.max()
m = len(X)
gradient = np.zeros(len(X.columns))

n_epochs = 1000
learning_rate = 0.1
J, gradient = gradient_descent(X, y_train, gradient, learning_rate, n_epochs)
y_hat = hypothesis(X, gradient)

# final 
plt.figure()
plt.scatter(x=x_train, y=y_train)           
plt.scatter(x=x_train, y=y_hat)
plt.show()

plt.figure()
plt.scatter(x=list(range(0, n_epochs)), y=J)
plt.show()




