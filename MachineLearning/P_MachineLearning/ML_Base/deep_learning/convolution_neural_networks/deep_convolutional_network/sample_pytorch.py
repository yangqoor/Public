import torch 
import torch.nn as nn
import torchvision
import torchvision.transforms as transforms

import numpy as np
import matplotlib.pyplot as plt

# Hyper parameters
n_epochs = 5
num_classes = 10
batch_size = 100
learning_rate = 0.001
interval = 100

# MNIST dataset
train_dataset = torchvision.datasets.MNIST(root='../../../_data', train=True, transform=transforms.ToTensor(), download=True)
test_dataset = torchvision.datasets.MNIST(root='../../../_data', train=False, transform=transforms.ToTensor(), download=True)

# Data loader
train_loader = torch.utils.data.DataLoader(dataset=train_dataset, batch_size=batch_size, shuffle=True)
test_loader = torch.utils.data.DataLoader(dataset=test_dataset, batch_size=batch_size, shuffle=False)

def display_multiple_img(images, predictions, rows=1, cols=1):
    figure, ax = plt.subplots(nrows=rows, ncols=cols)

    for i, image in enumerate(images):
        ax[i].imshow(image[0])
        ax[i].set_title(f"{predictions[i]}")
        ax[i].set_axis_off()
    plt.tight_layout()
    plt.show()

# Convolutional neural network (two convolutional layers)
class ConvNet(nn.Module):
    def __init__(self, num_classes=10):
        super(ConvNet, self).__init__()
        self.layer1 = nn.Sequential(
            nn.Conv2d(1, 16, kernel_size=5, stride=1, padding=2),
            nn.BatchNorm2d(16),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2))
        self.layer2 = nn.Sequential(
            nn.Conv2d(16, 32, kernel_size=5, stride=1, padding=2),
            nn.BatchNorm2d(32),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2))
        self.fc = nn.Linear(7*7*32, num_classes)
        
    def forward(self, x):
        out = self.layer1(x)
        out = self.layer2(out)
        out = out.reshape(out.size(0), -1)
        out = self.fc(out)
        return out

model = ConvNet(num_classes)

# Loss and optimizer
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

# Train the model
total_step = len(train_loader)
for epoch in range(n_epochs):
    loss_batch = 0
    for i, (images, labels) in enumerate(train_loader):
        images = images
        labels = labels
        
        # Forward pass
        outputs = model(images)
        loss = criterion(outputs, labels)
        
        # Backward and optimize
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        loss_batch += loss.item()
    
    print (f'\rEpoch [{epoch+1}/{n_epochs}], loss: {loss_batch}', end="")

# get accucy
for images, labels in test_loader:
    outputs = model(images)
    _, predicted = torch.max(outputs.data, 1)

    total += labels.size(0)
    correct += (predicted == labels).sum().item()
print('Test Accuracy of the model on the 10000 test images: {} %'.format(100 * correct / total))

# result network
for images, labels in test_loader:
    outputs = model(images)
    _, predicted = torch.max(outputs.data, 1)

    maximum = min(10, len(images))
    display_multiple_img(images[:maximum], predicted[:maximum], 1, maximum)
    break