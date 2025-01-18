from sklearn import datasets
import matplotlib.pyplot as plt
import numpy as np
import sys, os 

sys.path.insert(1, os.getcwd() + "./../../_network") 
from layers import Dense_V2, Conv2D, Network_V2, Flatten, Activation

class ConvNet:
    def __init__(self, input_shape, filter_shape, stride=1, loss="CrossEntropy", optimizer="adam"):
        self.model = Network_V2(loss_name=loss)

        self.model.add(Conv2D(16, filter_shape=filter_shape, input_shape=input_shape, stride=stride, padding='same', activation="relu", optimizer=optimizer))
        self.model.add(Conv2D(32, filter_shape=filter_shape, input_shape=(16, 8, 8), stride=stride, padding='same', activation="relu", optimizer=optimizer))
        self.model.add(Flatten(input_shape=(32, 8, 8)))
        self.model.add(Dense_V2(256, input_shape=(2048, ), activation="relu", optimizer=optimizer))
        self.model.add(Dense_V2(10, input_shape=(256, ), activation="softmax_v2", optimizer=optimizer))

        self.model.summary()

    def train(self, X, y, n_epochs=50, batch_size=256):
        return self.model.fit(X, y, n_epochs=n_epochs, batch_size=batch_size)

def one_hot_encoding(x, n_col=None):
    """ One-hot encoding of nominal values """
    if not n_col:
        n_col = np.amax(x) + 1
    
    one_hot = np.zeros((x.shape[0], n_col))
    one_hot[np.arange(x.shape[0]), x] = 1

    return one_hot

data = datasets.load_digits()
X = data.data
y = one_hot_encoding(data.target.astype("int"))# Convert to one-hot encoding

def get_data(test_size=0.5, seed=None):
    # Split the training data from test data in the ratio specified in
    # test_size
    split_i = len(y) - int(len(y) // (1 / test_size))
    X_train, X_test = X[:split_i], X[split_i:]
    y_train, y_test = y[:split_i], y[split_i:]

    # reshape data
    X_train = X_train.reshape((-1,1,8,8))
    X_test = X_test.reshape((-1,1,8,8))

    return X_train, X_test, y_train, y_test

def plot_data(X_test, y_pred, title, accuracy, legend_labels):
    X_transformed = self._transform(X, dim=2)
    x1 = X_transformed[:, 0]
    x2 = X_transformed[:, 1]
    class_distr = []

    y = np.array(y).astype(int)

    colors = [self.cmap(i) for i in np.linspace(0, 1, len(np.unique(y)))]

    # Plot the different class distributions
    for i, l in enumerate(np.unique(y)):
        _x1 = x1[y == l]
        _x2 = x2[y == l]
        _y = y[y == l]
        class_distr.append(plt.scatter(_x1, _x2, color=colors[i]))

    # Plot legend
    if not legend_labels is None: 
        plt.legend(class_distr, legend_labels, loc=1)

    # Plot title
    if title:
        if accuracy:
            perc = 100 * accuracy
            plt.suptitle(title)
            plt.title("Accuracy: %.1f%%" % perc, fontsize=10)
        else:
            plt.title(title)

    # Axis labels
    plt.xlabel('Principal Component 1')
    plt.ylabel('Principal Component 2')

    plt.show()

if __name__ == "__main__":
    # Dataset, Reshape X to (n_samples, channels, height, width)
    X_train, X_test, y_train, y_test = get_data(test_size=0.4, seed=1)

    # define network
    network = ConvNet(input_shape=(1,8,8), filter_shape=(3,3))

    # train network
    loss_history, accuracy = network.train(X=X_train, y=y_train, n_epochs=50, batch_size=256)

    _, accuracy = network.model.test_on_batch(X_test, y_test)
    print("Accuracy:", accuracy)

    # Reduce dimension to 2D using PCA and plot the results
    X_test = X_test.reshape(-1, 8 * 8)
    y_pred = np.argmax(network.model.predict(X_test), axis=1)
    plot_data(X_test, y_pred, title="Convolutional Neural Network", accuracy=accuracy, legend_labels=range(10))



