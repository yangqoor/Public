import numpy as np
import matplotlib.pyplot as plt

from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.datasets import mnist

# data
(x_train, _), (x_test, _) = mnist.load_data()
x_train = x_train.astype('float32') / 255.
x_test = x_test.astype('float32') / 255.
x_train = x_train.reshape((len(x_train), np.prod(x_train.shape[1:])))
x_test = x_test.reshape((len(x_test), np.prod(x_test.shape[1:])))

# settings
n_epochs = 50
batch_size = 256

class AutoEncoder():
    def __init__(self, n_inputs=[784, 256, 128, 64, 32, 16]):

        # encoder
        encoded_input = prev_layer = keras.Input(shape=(n_inputs[0],))
        for i in range(1, len(n_inputs)):
            prev_layer = layers.Dense(n_inputs[i], activation='relu')(prev_layer)

        self.encoder = keras.Model(encoded_input, prev_layer)

        # decoder
        decoded_input = keras.Input(shape=(n_inputs[-1],))
        for i in range(1, len(n_inputs)):
            prev_layer = layers.Dense(n_inputs[i-1], activation='sigmoid')(prev_layer)

        self.network = keras.Model(encoded_input, prev_layer)
        self.decoder = keras.Model(decoded_input, self.network.layers[-1](decoded_input))
        self.network.compile(optimizer='adam', loss='binary_crossentropy')

    def train(self, x_train, x_test, n_epochs, batch_size, shuffle=True):
        self.network.fit(x_train, x_train, epochs=n_epochs, batch_size=batch_size, shuffle=True, validation_data=(x_test, x_test))

    def encode(self, x):
        return self.encoder.predict(x)
        
    def decode(self, x):
        return self.decoder.predict(x)

# define network
net = AutoEncoder(n_inputs=[784, 32])

# train network
net.train(x_train, x_test, n_epochs, batch_size)

# network results
encoded_imgs = net.encode(x_test)
decoded_imgs = net.decode(encoded_imgs)

n = 10  # How many digits we will display
plt.figure(figsize=(20, 4))
for i in range(n):
    # Display original
    ax = plt.subplot(2, n, i + 1)
    plt.imshow(x_test[i].reshape(28, 28))
    plt.gray()
    ax.get_xaxis().set_visible(False)
    ax.get_yaxis().set_visible(False)

    # Display reconstruction
    ax = plt.subplot(2, n, i + 1 + n)
    plt.imshow(decoded_imgs[i].reshape(28, 28))
    plt.gray()
    ax.get_xaxis().set_visible(False)
    ax.get_yaxis().set_visible(False)

plt.show()