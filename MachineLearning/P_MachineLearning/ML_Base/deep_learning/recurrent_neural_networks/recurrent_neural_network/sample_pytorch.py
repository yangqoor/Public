import torch
import torch.nn as nn
from torch.nn import functional as F
from torch.autograd import Variable
from torch import optim
import numpy as np
import math, random
import matplotlib.pyplot as plt

class Network(nn.Module):
    def __init__(self, hidden_size, n_layers, batch_size):
        super(Network, self).__init__()
        self.hidden_size = hidden_size
        self.n_layers = n_layers
        self.batch_size = batch_size
        self.rnn = nn.RNN(hidden_size, hidden_size, 2, batch_first=True)
        self.out = nn.Linear(hidden_size, hidden_size) # 10 in and 10 out

    def step(self, input, hidden=None):
        output, hidden = self.rnn(input, hidden)
        output = self.out(output.squeeze(1))
        return output, hidden

    def forward(self, inputs, hidden=None):
        hidden = self.__init__hidden()
        output, hidden = self.rnn(inputs.float(), hidden.float())
        output = self.out(output.float());
        return output, hidden

    def __init__hidden(self):
       hidden = torch.zeros(self.n_layers, self.batch_size, self.hidden_size, dtype=torch.float64)
       return hidden

# generating a noisy multi-sin wave data
def sine_2(X, signal_freq=60.):
    return (np.sin(2 * np.pi * (X) / signal_freq) + np.sin(4 * np.pi * (X) / signal_freq)) / 2.0

def noisy(Y, noise_range=(-0.05, 0.05)):
    noise = np.random.uniform(noise_range[0], noise_range[1], size=Y.shape)
    return Y + noise

def sample(sample_size):
    random_offset = random.randint(0, sample_size)
    X = sine_2(np.arange(sample_size) + random_offset)
    Y = noisy(X)

    data = lambda data: np.array([data[0:10], data[10:20], data[20:30], data[30:40], data[40:50]], dtype=np.double)
    return Variable(torch.from_numpy(data(X)).unsqueeze(2)), Variable(torch.from_numpy(data(Y)).unsqueeze(2).float())

def generate_data(batch_size, amount=50):
    dataset = [ sample(batch_size) for i in range(amount) ]
    return dataset


n_epochs = 100
batch_size = 50
seq_size = 10

# data
dataset = generate_data(batch_size)



# define model
network = Network(hidden_size=1, n_layers=2, batch_size=int(batch_size / seq_size))
optimizer = optim.SGD(network.parameters(), lr=0.01)
loss_function = nn.MSELoss()
loss_history = np.zeros(n_epochs)

# train network
for epoch in range(n_epochs):
    for i, data in enumerate(dataset):
        x_train, y_train = data
        optimizer.zero_grad()

        outputs, hidden = network(x_train.double(), None)
        
        loss = loss_function(outputs, y_train)
        loss_history[epoch] += loss
        loss.backward()
        optimizer.step()

        if i % 10 == 0:
            plt.clf();
            plt.ion()
            plt.title(F"[{epoch}/{n_epochs}] loss:%.2f" % loss)
            plt.plot(torch.flatten(outputs.detach()),'r-',linewidth=1,label='Output')
            plt.plot(torch.flatten(y_train),'c-',linewidth=1,label='Label')
            plt.plot(torch.flatten(x_train),'g-',linewidth=1,label='Input')
            plt.draw();
            plt.pause(0.05);

    # network result
    print(f"\r[{epoch}/{n_epochs}] loss:{loss}", end="")
    