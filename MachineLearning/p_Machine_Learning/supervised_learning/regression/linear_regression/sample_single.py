import csv
import numpy as np
import matplotlib.pyplot as plt

x_train = [240000, 139800, 150500, 185530, 176000, 114800, 166800, 89000, 144500, 84000, 82029, 63060, 74000, 97500, 67000, 76025, 48235, 93000, 60949, 65674, 54000, 68500, 22899, 61789]
y_train = [3650, 3800, 4400, 4450, 5250, 5350, 5800, 5990, 5999, 6200, 6390, 6390, 6600, 6800, 6800, 6900, 6900, 6990, 7490, 7555, 7990, 7990, 7990, 8290]

# value = (value - lowest value) <-- set lowest value to 0
# return = 0.% of (value / max value)
def	normalizeElem(list_values, elem):
	return ((elem - min(list_values)) / (max(list_values) - min(list_values)))

# value = (highest value - lowest value) <-- set lowest value to 0
# return = (0.% * value) + lowest value 
def	denormalizeElem(list_values, elem):
	return ((elem * (max(list_values) - min(list_values))) + min(list_values))

# info: https://github.com/niektuytel/ML_Algorithms/gradient_descent#scaling
def normalizeData(X, Y):
    new_X = []
    for value in X:
        new_X.append( normalizeElem(X, value) )

    new_Y = []
    for value in Y:
        new_Y.append( normalizeElem(Y, value) )

    return new_X, new_Y

class Linear_Regression():
    # info https://github.com/niektuytel/ML_Algorithms/gradient_descent/tree/main/cost_functions  
    def	cost_function(self, loss, X, Y):
        cost = 0.0

        for i in range(len(X)):
            prediction = (loss[1] * X[i] + loss[0])        
            cost = cost + (prediction - Y[i]) ** 2

        return (cost / len(X))
        
    def	boldDriver(self, cost, cost_history, loss, batch_loss, learning_rate, length):
        new_learning_rate = learning_rate
        if len(cost_history) > 1:
            if cost > cost_history[-1]:
                loss = [
                    loss[0] + batch_loss[0] / length * learning_rate,
                    loss[1] + batch_loss[1] / length * learning_rate,
                ]
                new_learning_rate *=  0.5
            else:
                new_learning_rate *= 1.05

        return loss, new_learning_rate
    
    # info about gradient descent: https://github.com/niektuytel/ML_Algorithms/gradient_descent
    def	gradient_descent(self, loss, cost_history, X, Y, learning_rate, n_epochs):
        batch_loss = [0, 0]
        for coordinateX, coordinateY in zip(X, Y):
            total = (loss[1] * coordinateX + loss[0]) - coordinateY
            batch_loss = [ batch_loss[0] + total, batch_loss[1] + (total * coordinateX)]
            
        loss = [
            loss[0] - batch_loss[0] / len(X) * learning_rate,
            loss[1] - batch_loss[1] / len(Y) * learning_rate
        ]

        # position slope
        cost = self.cost_function(loss, X, Y)

        # rotation slope
        loss, learning_rate = self.boldDriver(cost, cost_history, loss, batch_loss, learning_rate, n_epochs)
        return loss, cost, learning_rate
        
    def fit(self, X, y, n_epochs=1000, learning_rate=0.1):
        loss = [0.0, 0.0]
        loss_history = [0.0, 0.0]
        cost_history = []

        for epoch in range(n_epochs):
            loss, cost, learning_rate = self.gradient_descent(loss, cost_history, X, y, learning_rate, n_epochs)
            loss_history.append(loss)
            cost_history.append(cost)

            print(f"\r[{epoch}/{n_epochs}] - loss: {loss}", end="")
        return loss, cost_history, loss_history

if __name__ == "__main__":
    x_normalized, y_normalized = normalizeData(x_train, y_train)

    # define model
    model = Linear_Regression()

    # train model
    loss, cost_history, loss_history = model.fit(x_normalized, y_normalized)
    
    # fdisplay model results
    lineX = [float(min(x_train)), float(max(x_train))]
    lineY = []
    for elem in lineX:
        elem = loss[1] * normalizeElem(x_train, elem) + loss[0]
        lineY.append(denormalizeElem(y_train, elem))

    # display the linear regression line result
    plt.figure(1)
    plt.plot(x_train, y_train, 'bo', lineX, lineY, 'r-')
    plt.xlabel('x')
    plt.ylabel('y')

    # display cost on the interaction index
    plt.figure(2)
    plt.plot(cost_history, 'r.')
    plt.xlabel('n_epochs')
    plt.ylabel('cost')

    # display
    plt.show()