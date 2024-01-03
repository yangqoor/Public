# https://datascience.oneoffcoder.com/autograd-poisson-regression-gradient-descent.html
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from numpy.random import normal
from scipy.stats import poisson
from autograd import grad

# define the loss function
def loss(w, X, y):
    y_pred = np.exp(np.dot(X, w))
    loss = ((y_pred - y) ** 2.0)
    return loss.mean(axis=None)

def learn_weights(X, y, alpha=0.05, max_iter=30000, debug=False):
    w = np.array([0.0 for _ in range(X.shape[1])])

    if debug is True:
        print('initial weights = {}'.format(w))

    loss_trace = []
    weight_trace = []

    for i in range(max_iter):
        loss = loss_grad(w, X, y)
        w = w - (loss * alpha)
        if i % 2000 == 0 and debug is True:
            print('{}: loss = {}, weights = {}'.format(i, loss, w))

        loss_trace.append(loss)
        weight_trace.append(w)

    if debug is True:
        print('intercept + weights: {}'.format(w))

    loss_trace = np.array(loss_trace)
    weight_trace = np.array(weight_trace)

    return w, loss_trace, weight_trace

def plot_traces(w, loss_trace, weight_trace, alpha):
    fig, ax = plt.subplots(1, 2, figsize=(20, 5))

    ax[0].set_title(r'Log-loss of the weights over iterations, $\alpha=${}'.format(alpha))
    ax[0].set_xlabel('iteration')
    ax[0].set_ylabel('log-loss')
    ax[0].plot(loss_trace[:, 0], label=r'$\beta$')
    ax[0].plot(loss_trace[:, 1], label=r'$x_0$')
    ax[0].plot(loss_trace[:, 2], label=r'$x_1$')
    ax[0].legend()

    ax[1].set_title(r'Weight learning over iterations, $\alpha=${}'.format(alpha))
    ax[1].set_xlabel('iteration')
    ax[1].set_ylabel('weight')
    ax[1].plot(weight_trace[:, 0], label=r'$\beta={:.2f}$'.format(w[0]))
    ax[1].plot(weight_trace[:, 1], label=r'$x_0={:.2f}$'.format(w[1]))
    ax[1].plot(weight_trace[:, 2], label=r'$x_1={:.2f}$'.format(w[2]))
    ax[1].legend()

np.random.seed(37)
sns.set(color_codes=True)

n = 10000
X = np.hstack([
    np.array([1 for _ in range(n)]).reshape(n, 1),
    normal(0.0, 1.0, n).reshape(n, 1),
    normal(0.0, 1.0, n).reshape(n, 1)
])
z = np.dot(X, np.array([1.0, 0.5, 0.2])) + normal(0.0, 1.0, n)
y = np.exp(z)

fig, ax = plt.subplots(1, 2, figsize=(20, 5))

sns.kdeplot(z, ax=ax[0])
ax[0].set_title(r'Distribution of Scores')
ax[0].set_xlabel('score')
ax[0].set_ylabel('probability')

sns.kdeplot(y, ax=ax[1])
ax[1].set_title(r'Distribution of Means')
ax[1].set_xlabel('mean')
ax[1].set_ylabel('probability')

#the magic line that gives you the gradient of the loss function
loss_grad = grad(loss)


alpha = 0.01
w, loss_trace, weight_trace = learn_weights(X, y, alpha=alpha, max_iter=200)
plot_traces(w, loss_trace, weight_trace, alpha=alpha)
print(w)

plt.show()