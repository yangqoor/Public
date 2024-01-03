from tensorflow.keras.datasets import mnist
import matplotlib.pyplot as plt
import numpy as np
import sys, os

# data
(x_train, _), (x_test, _) = mnist.load_data()
x_train = x_train.astype('float32') / 255.
x_test = x_test.astype('float32') / 255.
x_train = x_train.reshape((len(x_train), np.prod(x_train.shape[1:])))
x_test = x_test.reshape((len(x_test), np.prod(x_test.shape[1:])))

sys.path.insert(1, os.getcwd() + "./../../_network") 
from layers import Dense_V2, Network_V2

def generate_noise(images):
    noise_factor = 0.4
    return images + noise_factor * np.random.normal( loc=0.0, scale=1.0, size=images.shape )

class Autoencoder():
    """An Autoencoder with deep fully-connected neural nets.
    Training Data: MNIST Handwritten Digits (28x28 images)
    """
    def __init__(self):
        self.img_rows = 28
        self.img_cols = 28
        self.img_dim = self.img_rows * self.img_cols
        self.latent_dim = 64 # The dimension of the data embedding

        # encoder
        self.encoder = Network_V2(loss_name="MSE")
        self.encoder.add(Dense_V2(n_units=512, input_shape=(self.img_dim,), activation="relu"))
        self.encoder.add(Dense_V2(n_units=256, input_shape=(512,), activation="relu"))
        self.encoder.add(Dense_V2(n_units=128, input_shape=(256,), activation="relu"))
        self.encoder.add(Dense_V2(n_units=self.latent_dim, input_shape=(128,), activation="relu"))

        # decoder
        self.decoder = Network_V2(loss_name="MSE")
        self.decoder.add(Dense_V2(n_units=128, input_shape=(self.latent_dim,), activation="relu"))
        self.decoder.add(Dense_V2(n_units=256, input_shape=(128,), activation="relu"))
        self.decoder.add(Dense_V2(n_units=512, input_shape=(256,), activation="relu"))
        self.decoder.add(Dense_V2(n_units=self.img_dim, input_shape=(512,)))

        # define network
        self.network = Network_V2(loss_name="MSE")
        self.network.layers = np.concatenate((self.encoder.layers, self.decoder.layers))
        self.network.summary(name="Denoising Autoencoder")

    def train(self, X, y, n_epochs, batch_size=128, save_interval=50):
        noisy_images = generate_noise(X)
        
        for epoch in range(n_epochs):
            image_index = np.random.randint(0, X.shape[0], batch_size)

            # Select a random image
            noisy_image = noisy_images[image_index]
            image = X[image_index]

            # Train the Autoencoder
            loss, _, _ = self.network.train_on_batch(noisy_image, image)

            # Display the progress
            print (f"\r[{epoch}/{n_epochs}] loss: {loss}", end="")

            # If at save interval => save generated image samples
            if epoch % save_interval == 0:
                self.save_image(epoch, noisy_images)

    def save_image(self, epoch, X):
        r, c = 5, 5 # Grid size

        # Select a random half batch of images
        idx = np.random.randint(0, X.shape[0], r*c)

        # Generate images and reshape to image shape
        gen_imgs = self.network.predict(X[idx]).reshape((-1, self.img_rows, self.img_cols))

        # Rescale images 0 - 1
        gen_imgs = 0.5 * gen_imgs + 0.5

        fig, axs = plt.subplots(r, (c*2))
        plt.suptitle("Autoencoder")
        cnt = 0

        for i in range(r):
            for j in range(c):
                index = j * 2

                axs[i,index].imshow(X[idx].reshape((-1, self.img_rows, self.img_cols))[cnt,:,:], cmap='gray')# question
                axs[i,index + 1].imshow(gen_imgs[cnt,:,:], cmap='gray')# answer

                axs[i,index].axis('off')
                axs[i,index + 1].axis('off')

                cnt += 1
        fig.savefig(f"./sample_scratch_output/image_{epoch}.png")
        plt.close()

def make_dir():
    image_dir = "./sample_scratch_output"
    if not os.path.exists(image_dir):
        os.makedirs(image_dir)

if __name__ == '__main__':
    make_dir()

    ae = Autoencoder()
    ae.train(X=x_train, y=x_train, n_epochs=200000, batch_size=64, save_interval=400)


