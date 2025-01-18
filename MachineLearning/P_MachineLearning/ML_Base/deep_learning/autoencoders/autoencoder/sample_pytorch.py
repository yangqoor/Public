import os 
import torch 
import torchvision
import torch.nn as nn
import torchvision.transforms as transforms
import torch.optim as optim
import matplotlib.pyplot as plt
import torch.nn.functional as F

from torchvision import datasets
from torch.utils.data import DataLoader
from torchvision.utils import save_image

# constants
n_epochs = 50
learning_rate = 1e-3
batch_size = 128

class AutoEncoder(nn.Module):
    def __init__(self, n_inputs=[784, 256, 128, 64, 32, 16]):
        super(AutoEncoder, self).__init__()
        
        self.encoders = nn.ModuleList()
        for i in range(0, len(n_inputs)-1):
            self.encoders.append( nn.Linear(in_features=n_inputs[i], out_features=n_inputs[i+1]) )

        self.decoders = nn.ModuleList()
        for i in reversed(range(1, len(n_inputs))):
            self.decoders.append( nn.Linear(in_features=n_inputs[i], out_features=n_inputs[i-1]) )

    def forward(self, x):
        for encoder in self.encoders:
            x = F.relu(encoder(x))
        
        for decoder in self.decoders:
            x = F.relu(decoder(x))

        return x

def save_decoded_image(img, epoch):
    save_image(img.view(img.size(0), 1, 28, 28), f"./sample_pytorch_output/linear_ae_image{epoch}.png")

def make_dir():
    image_dir = "./sample_pytorch_output"
    if not os.path.exists(image_dir):
        os.makedirs(image_dir)

# data
transform = transforms.Compose([
    transforms.ToTensor()
])
trainset = datasets.FashionMNIST( root='../../../_data', train=True, download=True, transform=transform)
testset = datasets.FashionMNIST( root='../../../_data', train=False, download=True, transform=transform)
trainloader = DataLoader(trainset, batch_size=batch_size, shuffle=True)
testloader = DataLoader(testset, batch_size=batch_size, shuffle=True)

# settings
make_dir()

_, image_w, image_h = trainloader.dataset[0][0].shape
total_pixels = (image_w * image_h)# 28 * 28 = 784

# define network
net = AutoEncoder(n_inputs=[total_pixels, 256, 128, 64, 32, 16])
print(net)

def fit(net, trainloader, n_epochs, optimizer, loss_function=nn.MSELoss()):
    train_loss = []
    for epoch in range(n_epochs):
        running_loss = 0.0
        for data in trainloader:
            img, _ = data
            img = img.view(img.size(0), -1)
            optimizer.zero_grad()

            outputs = net(img)
            loss = loss_function(outputs, img)
            loss.backward()
            
            optimizer.step()
            running_loss += loss.item()

        loss = running_loss / len(trainloader)
        train_loss.append(loss)
        print(f"\r[{epoch+1}/{n_epochs}] loss: {loss}", end="")

        if epoch % 5 == 0:
            save_decoded_image(outputs.cpu().data, epoch)
    return train_loss

def test_image_reconstruction(net, testloader):
    for batch in testloader:
        img, _ = batch
        img = img.view(img.size(0), -1)

        outputs = net(img)
        outputs = outputs.view(outputs.size(0), 1, 28, 28).cpu().data
        save_image(outputs, "./sample_pytorch_output/fashionmnist_reconstruction.png")
        break

# train network
train_loss = fit(net, trainloader, n_epochs, optimizer=optim.Adam(net.parameters(), lr=learning_rate))

# network results
plt.figure()
plt.plot(train_loss)
plt.title("Train Loss")
plt.xlabel("Epochs")
plt.ylabel("Loss")
plt.savefig("./sample_pytorch_output/deep_ae_fashionmnist_loss.png")

# test the network
test_image_reconstruction(net, testloader)

