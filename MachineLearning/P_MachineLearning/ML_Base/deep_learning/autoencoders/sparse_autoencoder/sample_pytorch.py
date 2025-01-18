import torch
import torchvision
import torch.nn as nn
import matplotlib
import matplotlib.pyplot as plt
import torchvision.transforms as transforms
import torch.nn.functional as F
import torch.optim as optim
import os
import time
import numpy as np
import argparse
from tqdm import tqdm
from torchvision import datasets
from torch.utils.data import DataLoader
from torchvision.utils import save_image
matplotlib.style.use('ggplot')

# image transformations
transform = transforms.Compose([ transforms.ToTensor() ])

# load datasets
trainset = datasets.FashionMNIST(root='../../../_data', train=True, download=True, transform=transform)
trainloader = DataLoader(trainset, batch_size=32, shuffle=True)

testset = datasets.FashionMNIST(root='../../../_data', train=False, download=True, transform=transform) 
testloader = DataLoader(testset, batch_size=32, shuffle=False)

# define the autoencoder model
class SparseAutoencoder(nn.Module):
    def __init__(self):
        super(SparseAutoencoder, self).__init__()

        # encoder
        self.enc1 = nn.Linear(in_features=784, out_features=256)
        self.enc2 = nn.Linear(in_features=256, out_features=128)
        self.enc3 = nn.Linear(in_features=128, out_features=64)
        self.enc4 = nn.Linear(in_features=64, out_features=32)
        self.enc5 = nn.Linear(in_features=32, out_features=16)

        # decoder 
        self.dec1 = nn.Linear(in_features=16, out_features=32)
        self.dec2 = nn.Linear(in_features=32, out_features=64)
        self.dec3 = nn.Linear(in_features=64, out_features=128)
        self.dec4 = nn.Linear(in_features=128, out_features=256)
        self.dec5 = nn.Linear(in_features=256, out_features=784)

    def forward(self, x):
        # encoding
        x = F.relu(self.enc1(x))
        x = F.relu(self.enc2(x))
        x = F.relu(self.enc3(x))
        x = F.relu(self.enc4(x))
        x = F.relu(self.enc5(x))

        # decoding
        x = F.relu(self.dec1(x))
        x = F.relu(self.dec2(x))
        x = F.relu(self.dec3(x))
        x = F.relu(self.dec4(x))
        x = F.relu(self.dec5(x))
        return x

class Network:
    def __init__(self):
        # layer models
        self.model = SparseAutoencoder()
                
        # loss function
        self.loss_function = nn.MSELoss()

        # ptimizer function
        self.optimizer = optim.Adam(self.model.parameters(), lr=1e-3)
    
    def train(self, train_loader, test_loader, n_epochs, batch_size, save_interval=400):
        # train and validate the autoencoder neural network
        train_loss = []
        val_loss = []
        for epoch in range(n_epochs):
            train_epoch_loss = self.fit(train_loader, epoch, save_interval)
            val_epoch_loss = self.validate(test_loader, epoch, save_interval)

            # network results
            print(f"\r[{epoch+1}/{n_epochs}] loss_train:{train_epoch_loss}, loss_val:{val_epoch_loss}", end="")

            train_loss.append(train_epoch_loss)
            val_loss.append(val_epoch_loss)

    def fit(self, train_loader, epoch, save_interval):
        self.model.train()
        running_loss = 0.0
        counter = 0
        for i, data in tqdm(enumerate(train_loader), total=int(len(trainset)/train_loader.batch_size)):
            counter += 1
            img, _ = data
            img = img.view(img.size(0), -1)

            self.optimizer.zero_grad()
            outputs = self.model(img)
            mse_loss = self.loss_function(outputs, img)
            l1_loss = self.loss_function_sparse(img)

            loss = mse_loss #+ 0.001 * l1_loss
            loss.backward()
            self.optimizer.step()
            running_loss += loss.item()
        epoch_loss = running_loss / counter

        # save image
        if epoch % save_interval == 0:
            img = outputs.view(img.size(0), 1, 28, 28).cpu().data
            save_image(img, f"./sample_pytorch_output/image_fit_{epoch}.png")
        return epoch_loss

    def validate(self, test_loader, epoch, save_interval):
        self.model.eval()
        running_loss = 0.0
        counter = 0
        # with torch.no_grad():
        for i, data in tqdm(enumerate(test_loader), total=int(len(testset)/test_loader.batch_size)):
            counter += 1
            img, _ = data
            img = img.view(img.size(0), -1)
            outputs = self.model(img)
            loss = self.loss_function(outputs, img)
            running_loss += loss.item()
        epoch_loss = running_loss / counter

        # save image
        if epoch % save_interval == 0:
            outputs = outputs.view(outputs.size(0), 1, 28, 28).cpu().data
            save_image(outputs, f"./sample_pytorch_output/image_val_{epoch}.png")
        return epoch_loss

    def loss_function_sparse(self, image):
        model_children = list(self.model.children())
        values = image
        loss = 0

        for child in model_children:
            values = F.relu((child(values)))
            loss += torch.mean(torch.abs(values))

        return loss
    
# start network
if __name__ == "__main__":
    os.makedirs("sample_pytorch_output", exist_ok=True)
    network = Network()
    network.train(trainloader, testloader, n_epochs=10, batch_size=32, save_interval=2)