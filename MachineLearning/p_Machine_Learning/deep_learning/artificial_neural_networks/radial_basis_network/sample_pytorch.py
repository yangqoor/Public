import sys
import numpy as np
import matplotlib.pyplot as plt

import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader

# activation function
def gaussian(alpha):
    phi = torch.exp(-1*alpha.pow(2))
    return phi

def generate_data(batch_size):    
    batch_center = batch_size // 2
    # data
    x_mesh, y_mesh = np.meshgrid(np.linspace(-1, 1, 100), np.linspace(-1, 1, 100))
    values = np.append(
        x_mesh.ravel().reshape(x_mesh.ravel().shape[0], 1), 
        y_mesh.ravel().reshape(y_mesh.ravel().shape[0], 1), axis=1
    )

    x = np.random.uniform(-1, 1, (batch_size, 2))
    for i in range(batch_size):
        xx = 0.5 * np.cos(np.pi * x[i,0])
        yy = 0.5 * np.cos(4 * np.pi * (x[i,0]+1))

        if i < batch_center:
            x[i,1] = np.random.uniform(-1, xx + yy)
        else:
            x[i,1] = np.random.uniform(xx + yy, 1)

    x_train = torch.from_numpy(x).float()
    y_train = torch.cat((torch.zeros(batch_center,1), torch.ones(batch_center,1)), dim=0)

    return (x_train, y_train), (values)

def display_predictions(values, batch_size):
    batch_center = batch_size // 2
        
    # Plotting the ideal and learned decision boundaries
    preds = (torch.sigmoid(network(torch.from_numpy(values).float()))).data.numpy()
    ideal_0 = values[np.where(values[:,1] <= 0.5*np.cos(np.pi*values[:,0]) + 0.5*np.cos(4*np.pi*(values[:,0]+1)))[0]]
    ideal_1 = values[np.where(values[:,1] > 0.5*np.cos(np.pi*values[:,0]) + 0.5*np.cos(4*np.pi*(values[:,0]+1)))[0]]
    area_0 = values[np.where(preds[:, 0] <= 0.5)[0]]
    area_1 = values[np.where(preds[:, 0] > 0.5)[0]]

    fig, ax = plt.subplots(figsize=(16,8), nrows=1, ncols=2)
    ax[0].scatter(x[:batch_center,0], x[:batch_center,1], c='dodgerblue')
    ax[0].scatter(x[batch_center:,0], x[batch_center:,1], c='orange', marker='x')
    ax[0].scatter(ideal_0[:, 0], ideal_0[:, 1], alpha=0.1, c='dodgerblue')
    ax[0].scatter(ideal_1[:, 0], ideal_1[:, 1], alpha=0.1, c='orange')
    ax[0].set_xlim([-1,1])
    ax[0].set_ylim([-1,1])
    ax[0].set_title('Ideal Decision Boundary')

    ax[1].scatter(x[:batch_center,0], x[:batch_center,1], c='dodgerblue')
    ax[1].scatter(x[batch_center:,0], x[batch_center:,1], c='orange', marker='x')
    ax[1].scatter(area_0[:, 0], area_0[:, 1], alpha=0.1, c='dodgerblue')
    ax[1].scatter(area_1[:, 0], area_1[:, 1], alpha=0.1, c='orange')
    ax[1].set_xlim([-1,1])
    ax[1].set_ylim([-1,1])
    ax[1].set_title('RBF Decision Boundary')

    plt.show()

class MyDataset(Dataset):
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __len__(self):
        return self.x.size(0)
    
    def __getitem__(self, idx):
        x = self.x[idx]
        y = self.y[idx]
        return (x, y)

class RBF(nn.Module):
    def __init__(self, in_features, out_features, activation=gaussian):
        super(RBF, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.activation = activation

        self.centres = nn.Parameter(torch.Tensor(out_features, in_features))
        self.log_sigmas = nn.Parameter(torch.Tensor(out_features))
        self.reset_parameters()
    
    def reset_parameters(self):
        nn.init.normal_(self.centres, 0, 1)
        nn.init.constant_(self.log_sigmas, 0)

    def forward(self, input):
        size = (input.size(0), self.out_features, self.in_features)
        x = input.unsqueeze(1).expand(size)
        c = self.centres.unsqueeze(0).expand(size)
        distances = (x - c).pow(2).sum(-1).pow(0.5) / torch.exp(self.log_sigmas).unsqueeze(0)
        return self.activation(distances)

class Network(nn.Module):    
    def __init__(self, input_dim, hidden_dim, output_dim, loss_function):
        super(Network, self).__init__()
        self.loss_function = loss_function

        self.rbf = RBF(input_dim, hidden_dim)
        self.linear = nn.Linear(hidden_dim, output_dim)
    
    def forward(self, x):
        out = self.rbf(x)
        out = self.linear(out)
        return out
    
    def fit(self, x, y, n_epochs, batch_size, lr):
        self.train()

        trainset = MyDataset(x, y)
        trainloader = DataLoader(trainset, batch_size=batch_size, shuffle=True)
        optimiser = torch.optim.Adam(self.parameters(), lr=lr)

        for epoch in range(n_epochs):
            current_loss = 0
            for n_batch, (x_batch, y_batch) in enumerate(trainloader):
                optimiser.zero_grad()
                y_hat = self.forward(x_batch)
                loss = self.loss_function(y_hat, y_batch)
                current_loss += (1/(n_batch+1)) * (loss.item() - current_loss)
                
                # backward
                loss.backward()
                optimiser.step()
                print(f"\r[{epoch}/{n_epochs}] Loss: {current_loss}", end="")

if __name__ == "__main__":
    # settings
    n_epochs = 5000
    batch_size = 200
    learning_rate = 0.01

    # data
    (x_train, y_train), (values) = generate_data(batch_size)

    # define network
    network = Network(input_dim=2, hidden_dim=40, output_dim=1, loss_function=nn.BCEWithLogitsLoss())
    network.fit(x_train, y_train, n_epochs, batch_size, learning_rate)
    network.eval()

    # display predictions
    display_predictions(values, batch_size)
