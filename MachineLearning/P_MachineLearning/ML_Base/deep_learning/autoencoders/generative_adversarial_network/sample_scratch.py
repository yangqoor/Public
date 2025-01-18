from tensorflow.keras.datasets import mnist
import matplotlib.pyplot as plt
import numpy as np
import sys, os

sys.path.insert(1, os.getcwd() + "./../../_network") 
from layers import Dense_V2, Dropout, Reshape, Flatten, BatchNormalization, Network_V2

class GAN():
    def __init__(self):
        self.channels = 1
        self.img_rows = self.img_cols = self.image_size = 28
        self.img_dim = self.img_rows * self.img_cols
        self.img_shape = (self.img_rows, self.img_cols, self.channels)
        self.latent_dim = 100

        # initialize
        self.discriminator = self.build_discriminator()
        self.generator = self.build_generator()

        # Build the combined model
        self.combined = Network_V2(loss_name="CrossEntropy")
        self.combined.layers = np.concatenate(
            (self.generator.layers, self.discriminator.layers)
        )

        # display network structures
        self.generator.summary(name="Generator")
        self.discriminator.summary(name="Discriminator")

    def build_generator(self, optimizer="adam", loss_function="CrossEntropy"):
        model = Network_V2(loss_name=loss_function)
        
        model.add(Dense_V2(n_units=256, input_shape=(self.latent_dim,), activation="leakyrelu", optimizer=optimizer))
        model.add(BatchNormalization(momentum=0.8, input_shape=(256,)))
        model.add(Dense_V2(n_units=512, input_shape=(256,), activation="leakyrelu", optimizer=optimizer))
        model.add(BatchNormalization(momentum=0.8, input_shape=(512,)))
        model.add(Dense_V2(n_units=1024, input_shape=(512,), activation="leakyrelu", optimizer=optimizer))
        model.add(BatchNormalization(momentum=0.8, input_shape=(1024,)))
        model.add(Dense_V2(n_units=np.prod(self.img_shape), input_shape=(1024,), activation="tanh", optimizer=optimizer))
        model.add(Reshape(output_shape=self.img_shape, input_shape=(np.prod(self.img_shape), )))

        return model

    def build_discriminator(self, optimizer="adam", loss_function="CrossEntropy"):
        model = Network_V2(loss_name=loss_function)

        model.add(Flatten(input_shape=self.img_shape))
        model.add(Dense_V2(n_units=512, input_shape=(np.prod(self.img_shape),), activation="leakyrelu", optimizer=optimizer))
        model.add(Dropout(lowest_value=0.5, input_shape=(512,)))
        model.add(Dense_V2(n_units=256, input_shape=(512,), activation="leakyrelu", optimizer=optimizer))
        model.add(Dropout(lowest_value=0.5, input_shape=(256,)))
        model.add(Dense_V2(n_units=1, input_shape=(256,), activation="sigmoid", optimizer=optimizer))

        return model

    def train(self, X, y, n_epochs, batch_size=128, save_interval=50):
        valid = np.ones((batch_size, 1))
        fake = np.zeros((batch_size, 1))

        for epoch in range(n_epochs):
            # ---------------------
            #  Train Discriminator
            # ---------------------
            # Select a random batch of image
            random_index = np.random.randint(0, X.shape[0], batch_size)
            rand_image = X[random_index]

            # Sample noise to use as generator input
            noise = np.random.normal(0, 1, (batch_size, self.latent_dim))

            # Generate a batch of image
            gen_image = self.generator.predict(noise)

            # Train the discriminator
            d_loss_real, d_acc_real, _ = self.discriminator.train_on_batch(rand_image, valid)
            d_loss_fake, d_acc_fake, _ = self.discriminator.train_on_batch(gen_image, fake)
            d_loss = 0.5 * np.add(d_loss_real, d_loss_fake)
            d_acc = 0.5 * np.add(d_acc_real, d_acc_fake)
            
            # --------------------- 
            #  Train Generator
            # ---------------------
            # Sample noise and use as generator input
            noise = np.random.normal(0, 1, (batch_size, self.latent_dim))

            # Train the generator
            g_loss, g_acc, _ = self.combined.train_on_batch(noise, valid)

            # Display the progress
            print (f"\r[{epoch}/{n_epochs}] discriminator_loss: {d_loss} generator_loss: {g_loss}", end="")

            # If at save interval => save generated image samples
            if epoch % save_interval == 0:
                self.save_image(epoch)

    def save_image(self, epoch):
        r, c = 5, 5 # Grid size
        noise = np.random.normal(0, 1, (r * c, self.latent_dim))

        # Generate image and reshape to image shape
        gen_image = self.generator.predict(noise)

        # Rescale image 0 - 1
        gen_image = 0.5 * gen_image + 0.5

        fig, axs = plt.subplots(r, c)
        plt.suptitle("Generative Adversarial Network")
        cnt = 0
        for i in range(r):
            for j in range(c):
                axs[i,j].imshow(gen_image[cnt,:,:, 0], cmap='gray')
                axs[i,j].axis('off')
                cnt += 1
        fig.savefig("./sample_scratch_output/image_%d.png" % epoch)
        plt.close()


# Load the dataset
(X_train, _), (_, _) = mnist.load_data()

# Rescale -1 to 1
X_train = X_train / 127.5 - 1.
X_train = np.expand_dims(X_train, axis=3)

if __name__ == '__main__':
    os.makedirs("sample_scratch_output", exist_ok=True)
    network = GAN()
    network.train(X=X_train, y=X_train, n_epochs=30000, batch_size=32, save_interval=400)