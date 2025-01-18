# good resource: https://satishgunjal.com/multivariate_lr/
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import math

x_train = [[2104, 3],[1600, 3],[2400, 3],[1416, 2],[3000, 4],[1985, 4],[1534, 3],[1427, 3],[1380, 3],[1494, 3],[1940, 4],[2000, 3],[1890, 3],[4478, 5],[1268, 3],[2300, 4],[1320, 2],[1236, 3],[2609, 4],[3031, 4],[1767, 3],[1888, 2],[1604, 3],[1962, 4],[3890, 3],[1100, 3],[1458, 3],[2526, 3],[2200, 3],[2637, 3],[1839, 2],[1000, 1],[2040, 4],[3137, 3],[1811, 4],[1437, 3],[1239, 3],[2132, 4],[4215, 4],[2162, 4],[1664, 2],[2238, 3],[2567, 4],[1200, 3],[852, 2],[1852, 4],[1203, 3]]
y_train = [399900, 329900, 369000, 232000, 539900, 299900, 314900, 198999, 212000, 242500, 239999, 347000, 329999, 699900, 259900, 449900, 299900, 199900, 499998, 599000, 252900, 255000, 242900, 259900, 573900, 249900, 464500, 469000, 475000, 299900, 349900, 169900, 314900, 579900, 285900, 249900, 229900, 345000, 549000, 287000, 368500, 329900, 314000, 299000, 179900, 299900, 239500]

def normalize_data(X):
    # mean center of all values
    mean_values = np.mean(X, axis = 0)

    # Notice the parameter ddof (Delta Degrees of Freedom) value is 1
    # https://www.mathsisfun.com/data/standard-deviation-formulas.html
    standard_diviations = np.std(X, axis= 0, ddof = 1)

    X_norm = (X - mean_values) / standard_diviations

    return X_norm, mean_values, standard_diviations

def calc_cost(X, y, theta):
    predictions = X.dot(theta)
    errors = (predictions - y)
    sqrErrors = np.square(errors)

    #print('sqrErrors = ', sqrErrors[:5]) 
    #J = 1 / (2 * m) * np.sum(sqrErrors)
    # OR
    # We can merge 'square' and 'sum' into one by taking the transpose of matrix 'errors' and taking dot product with itself
    # If your confuse about this try to do this with few values for better understanding  
    J = 1/(2 * m) * errors.T.dot(errors)

    return J

def gradient_descent(X, y, theta, learning_rate, iterations):
    cost_history = np.zeros(iterations)

    for i in range(iterations):
        predictions = X.dot(theta)
        # print('last 4 predictions : ', predictions[:4])

        errors = (predictions - y)
        # print('last 4 errors      : ', errors[:4])

        theta = theta - (learning_rate / m) * X.T.dot(errors);
        # print('theta              : ', theta)
        
        cost = calc_cost(X, y, theta)
        cost_history[i] = cost 
        # print('cost               : ', cost)
        # print("\n===\n")

    return theta, cost_history

def displayPlot(X, y, theta, cost_history):

    #---------------------------------------------------------- 

    # display the linear regression results
    plt.figure(1)
    plt.title("visualize data")
    plt.xlabel('x')
    plt.ylabel('y')
    plt.grid()

    x = [[],[]]
    for i in range(len(X)):
        x[0].append(X[i][1])
        x[1].append(X[i][2])

    # display lines
    lineX_1 = [float(min(x[0])), float(max(x[0]))]
    lineY_1 = []
    for elem in lineX_1:
        elem = theta[1] * elem + theta[0]
        lineY_1.append(elem)

    lineX_2 = [float(min(x[1])), float(max(x[1]))]
    lineY_2 = []
    for elem in lineX_2:
        elem = theta[2] * elem + theta[0]
        lineY_2.append(elem)

    plt.plot(x[0], y, 'go', lineX_1, lineY_1, 'g-')
    plt.plot(x[1], y, 'bo', lineX_2, lineY_2, 'b-')


    #---------------------------------------------------------- 

    # display costs on iteractions
    plt.figure(2)
    plt.title("cost <-> interaction graph")
    plt.xlabel("iterations")
    plt.ylabel("cost (J)")
    plt.grid()

    plt.plot(cost_history, color ='blue')
    
    #---------------------------------------------------------- 

    # display
    plt.show()

m = len(y_train) # Number of Training Sets

# normalize data
X_norm, mean_values, standard_deviations = normalize_data(x_train)

print('X_norm             : \n'  , X_norm[:5])
print('mean_values         : '  , mean_values)
print('standard_deviations : ', standard_deviations)

mean_value_testing = np.mean(X_norm, axis = 0) # mean
standard_deviation_testing = np.std(X_norm, axis = 0, ddof = 1) # mean

# Lets use hstack() function from numpy to add column of ones to X_norm feature 
# This will be our final X_normX matrix (feature matrix)
ones = np.ones((m, 1))
X_norm = np.hstack((ones, X_norm))

# We need theta parameter for every input variable. since we have three input variable including X_0 (column of ones)
theta = np.zeros(3)
learning_rate = 0.1;
iterations = 1000;

theta, cost_history = gradient_descent(X_norm, y_train, theta, learning_rate, iterations)
print('Final value of theta =', theta)
print('First 5 values from cost_history =', cost_history[:5])
print('Last 5 values from cost_history =', cost_history[-5 :])

displayPlot(X_norm, y_train, theta, cost_history)