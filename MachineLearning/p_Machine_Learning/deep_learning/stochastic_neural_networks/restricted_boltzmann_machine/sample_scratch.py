import numpy as np
import matplotlib.pyplot as plt
from tensorflow.keras.datasets import mnist
import sys, os

sys.path.insert(1, os.getcwd() + "./../../_network")
from algorithms.activation_functions import act_functions

def batch_iterator(X, y=None, batch_size=64):
    """ Simple batch generator """
    n_samples = X.shape[0]
    for i in np.arange(0, n_samples, batch_size):
        begin, end = i, min(i+batch_size, n_samples)
        if y is not None:
            yield X[begin:end], y[begin:end]
        else:
            yield X[begin:end]

class RBM():
    def __init__(self, n_visible=784, n_hidden=128, learning_rate=0.1, activation="sigmoid"):
        self.n_visible = n_visible
        self.n_hidden = n_hidden
        self.lr = learning_rate

        self.activation = act_functions[activation]()
        
        # initialize
        self.W = np.random.normal(scale=0.1, size=(self.n_visible, self.n_hidden))
        self.v0 = np.zeros(self.n_visible)# visible
        self.h0 = np.zeros(self.n_hidden)# hidden

    def fit(self, X, y, batch_size=10, n_epochs=100, n_interval=400):
        for epoch in range(n_epochs):
            loss_batch = []
            for batch in batch_iterator(X, batch_size=batch_size):
                # Positive phase
                positive_hidden = self.activation(batch.dot(self.W) + self.h0)
                hidden_states = self.filter(positive_hidden)
                positive_associations = batch.T.dot(positive_hidden)

                # Negative phase
                negative_visible = self.activation(hidden_states.dot(self.W.T) + self.v0)
                negative_visible = self.filter(negative_visible)
                negative_hidden = self.activation(negative_visible.dot(self.W) + self.h0)
                negative_associations = negative_visible.T.dot(negative_hidden)

                self.W  += self.lr * (positive_associations - negative_associations)
                self.h0 += self.lr * (positive_hidden.sum(axis=0) - negative_hidden.sum(axis=0))
                self.v0 += self.lr * (batch.sum(axis=0) - negative_visible.sum(axis=0))

                loss_batch.append(np.mean((batch - negative_visible) ** 2))

            loss = np.mean(loss_batch)
            print(f"\r[{epoch+1}/{n_epochs}] loss:{loss}", end="")

            if epoch % n_interval == 0:
                self.save_image(epoch, X)

    def filter(self, X):
        return X > np.random.random_sample(size=X.shape)

    def predict(self, X):
        positive_hidden = self.activation(X.dot(self.W) + self.h0)
        hidden_states = self.filter(positive_hidden)
        negative_visible = self.activation(hidden_states.dot(self.W.T) + self.v0)
        return negative_visible

    def save_image(self, epoch, X):
        # predict random image
        idx = np.random.choice(range(X.shape[0]), 100)
        image = self.predict(self.predict(X[idx]))

        # Plot the images during the last iteration
        fig, axs = plt.subplots(5, 5)
        plt.suptitle("Restricted Boltzmann Machine")
        cnt = 0
        for i in range(5):
            for j in range(5):
                axs[i,j].imshow(image[cnt].reshape((28, 28)), cmap='gray')
                axs[i,j].axis('off')
                cnt += 1
                
        fig.savefig(f"./sample_scratch_output/image_{epoch}.png")
        plt.close()

os.makedirs("sample_scratch_output", exist_ok=True)
if __name__ == "__main__":
    # data
    (x_train, y_train), (x_test, y_test) = mnist.load_data()
    x_train = x_train.astype('float32') / 255.
    x_test = x_test.astype('float32') / 255.
    x_train = x_train.reshape((len(x_train), np.prod(x_train.shape[1:])))
    x_test = x_test.reshape((len(x_test), np.prod(x_test.shape[1:])))
    X, y = x_train, y_train

    # redce dataset to 500 samples
    idx = np.random.choice(range(X.shape[0]), size=500, replace=False)
    X = X[idx]

    # network
    network = RBM(n_visible=784, n_hidden=50, learning_rate=0.001)
    network.fit(X, y, n_epochs=20000, batch_size=25)