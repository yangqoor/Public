import argparse
import os
import numpy as np
import math

import torchvision.transforms as transforms
from torchvision.utils import save_image

from torch.utils.data import DataLoader
from torchvision import datasets
from torch.autograd import Variable

import torch.nn as nn
import torch.nn.functional as F
import torch

class Generator(nn.Module):
    def __init__(self, latent_dim, image_shape):
        super(Generator, self).__init__()
        self.latent_dim = latent_dim
        self.image_shape = image_shape

        def block(in_feat, out_feat, normalize=True):
            layers = [nn.Linear(in_feat, out_feat)]
            if normalize:
                layers.append(nn.BatchNorm1d(out_feat, 0.8))
            layers.append(nn.LeakyReLU(0.2, inplace=True))
            return layers

        self.model = nn.Sequential(
            *block(self.latent_dim, 128, normalize=False),
            *block(128, 256),
            *block(256, 512),
            *block(512, 1024),
            nn.Linear(1024, int(np.prod(self.image_shape))),
            nn.Tanh()
        )

    def forward(self, z):
        img = self.model(z)
        img = img.view(img.size(0), *self.image_shape)
        return img

class Discriminator(nn.Module):
    def __init__(self, image_shape):
        super(Discriminator, self).__init__()
        self.image_shape = image_shape

        self.model = nn.Sequential(
            nn.Linear(int(np.prod(self.image_shape)), 512),
            nn.LeakyReLU(0.2, inplace=True),
            nn.Linear(512, 256),
            nn.LeakyReLU(0.2, inplace=True),
            nn.Linear(256, 1),
            nn.Sigmoid(),
        )

    def forward(self, img):
        img_flat = img.view(img.size(0), -1)
        validity = self.model(img_flat)

        return validity

class GAN():
    def __init__(self):
        self.image_size = 28
        self.img_rows = self.image_size
        self.img_cols = self.image_size
        self.channels = 1
        self.img_shape = (self.channels, self.img_rows, self.img_cols)
        self.latent_dim = 100

        self.generator = Generator(self.latent_dim, self.img_shape)
        self.discriminator = Discriminator(self.img_shape)

        # Optimizers
        self.optimizer_G = torch.optim.Adam(    self.generator.parameters(), lr=0.0002, betas=(0.5, 0.999))
        self.optimizer_D = torch.optim.Adam(self.discriminator.parameters(), lr=0.0002, betas=(0.5, 0.999))

        # Loss function
        self.adversarial_loss = torch.nn.BCELoss()

    def train(self, X, n_epochs, batch_size=128, sample_interval=50):
        for epoch in range(n_epochs):
            for i, (imgs, _) in enumerate(X):
                # target image
                y = Variable(imgs.type(torch.FloatTensor))

                # Adversarial ground truths
                valid = Variable(torch.FloatTensor(imgs.size(0), 1).fill_(1.0), requires_grad=False)
                fake = Variable(torch.FloatTensor(imgs.size(0), 1).fill_(0.0), requires_grad=False)

                # -----------------
                #  Train Generator
                # -----------------
                self.optimizer_G.zero_grad()

                # Sample noise as generator input
                random_shape = np.random.normal(0, 1, (imgs.shape[0], self.latent_dim))
                z = Variable(torch.FloatTensor(random_shape))

                # Generate a batch of images
                gen_images = self.generator(z)

                # Discriminate a batch of images
                dis_images = self.discriminator(gen_images)

                # Loss measures generator's ability to fool the discriminator
                g_loss = self.adversarial_loss(dis_images, valid)

                g_loss.backward()
                self.optimizer_G.step()

                # ---------------------
                #  Train Discriminator
                # ---------------------
                self.optimizer_D.zero_grad()

                # Measure self.discriminator's ability to classify real from generated samples
                real_loss = self.adversarial_loss(self.discriminator(y), valid)
                fake_loss = self.adversarial_loss(self.discriminator(gen_images.detach()), fake)
                d_loss = (real_loss + fake_loss) / 2

                d_loss.backward()
                self.optimizer_D.step()

                print(f"\r[{epoch}/{n_epochs}] batch:[{i}/{len(dataloader)}] loss:{g_loss.item()}", end="")

                batches_done = epoch * len(dataloader) + i
                if batches_done % sample_interval == 0:
                    save_image(gen_images.data[:25], f"./sample_pytorch_output/image_{batches_done}.png", nrow=5, normalize=True)

if __name__ == "__main__":
    os.makedirs("./sample_pytorch_output", exist_ok=True)

    # dataset
    dataloader = torch.utils.data.DataLoader(
        datasets.MNIST( "../../../_data", train=True, download=True,
            transform=transforms.Compose(
                [transforms.Resize(28), transforms.ToTensor(), transforms.Normalize([0.5], [0.5])]
            ),
        ),
        batch_size=64, shuffle=True,
    )
            
    network = GAN()
    network.train(X=dataloader, n_epochs=200, batch_size=64, sample_interval=400)