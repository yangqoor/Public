import numpy as np
import sys, os
import torch
import torch.utils.data
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import matplotlib.pyplot as plt
from torch.autograd import Variable
from torchvision import datasets, transforms
from torchvision.utils import make_grid, save_image


n_epochs = 1000
batch_size = 64

train_loader = torch.utils.data.DataLoader(
    datasets.MNIST("../../../_data", train=True, download=True, transform=transforms.Compose([transforms.ToTensor()])),
    batch_size=batch_size
)
test_loader = torch.utils.data.DataLoader(
    datasets.MNIST("../../../_data", train=False, transform=transforms.Compose([transforms.ToTensor()])),
    batch_size=batch_size
)

class RBM(nn.Module):
    def __init__(self, n_visible_units=784, n_hidden_units=500, kernel=5):
        super(RBM, self).__init__()
        self.W = nn.Parameter(torch.randn(n_hidden_units, n_visible_units) * 1e-2)
        self.bias_visible = nn.Parameter(torch.zeros(n_visible_units))
        self.bias_hidden = nn.Parameter(torch.zeros(n_hidden_units))

        self.kernel = kernel
    
    def sample_from_prediction(self, prediction):
        return F.relu(torch.sign(prediction - Variable(torch.rand(prediction.size()))))

    def visible_to_hidden(self, visible):
        pred_hidden = torch.sigmoid(F.linear(visible, self.W, self.bias_hidden))
        sample_hidden = self.sample_from_prediction(pred_hidden)
        return pred_hidden, sample_hidden
    
    def hidden_to_visible(self, hidden):
        pred_visible = torch.sigmoid(F.linear(hidden, self.W.t(), self.bias_visible))
        sample_visible = self.sample_from_prediction(pred_visible)
        return pred_visible, sample_visible

    def forward(self, visible):
        _, hidden = self.visible_to_hidden(visible)

        for _ in range(self.kernel):
            _, v_ = self.hidden_to_visible(hidden)
            _, hidden = self.visible_to_hidden(v_)
        
        return visible, v_
    
    def free_energy(self, visible):
        vbias_term = visible.mv(self.bias_visible)
        wx_b = F.linear(visible, self.W, self.bias_hidden)
        hidden_term = wx_b.exp().add(1).log().sum(1)

        return (-hidden_term - vbias_term).mean()
    
def save_image(epoch, img):
    image = np.transpose(img.numpy(),(1,2,0))
    plt.imshow(image)
    plt.imsave(f"./sample_pytorch_output/image_{epoch}.png",image)

if __name__ == "__main__":
    os.makedirs("sample_pytorch_output", exist_ok=True)

    network = RBM(kernel=1)
    train_optimizer = optim.SGD(network.parameters(), 0.1)

    for epoch in range(n_epochs):
        loss_ = []
        for _, (data, target) in enumerate(train_loader):
            data = Variable(data.view(-1, 784))
            sample_data = data.bernoulli()

            v, v1 = network(sample_data)
            loss = network.free_energy(v) - network.free_energy(v1)
            loss_.append(loss.data)

            train_optimizer.zero_grad()
            loss.backward()
            train_optimizer.step()
        
        print(f"[{epoch}/{n_epochs}] loss: {np.mean(loss_)}")
        image = make_grid(v1.view(32,1,28,28).data)
        save_image(epoch, image)

    plt.show()
