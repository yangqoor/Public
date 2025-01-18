import torch
import torch.nn as nn
import torchvision
import torchvision.transforms as transforms

# Hyper-parameters 
num_classes = 10
num_epochs = 2
batch_size = 100
learning_rate = 0.001

input_size = 28
sequence_length = 28
hidden_size = 128
num_layers = 2

# MNIST dataset 
train_dataset = torchvision.datasets.MNIST(root='../../../_data', train=True, transform=transforms.ToTensor(), download=True)
test_dataset = torchvision.datasets.MNIST(root='../../../_data', train=False, transform=transforms.ToTensor(), download=True)

# Data loader
train_loader = torch.utils.data.DataLoader(dataset=train_dataset, batch_size=batch_size, shuffle=True)
test_loader = torch.utils.data.DataLoader(dataset=test_dataset, batch_size=batch_size, shuffle=False)

# define network
class GRU(nn.Module):
    def __init__(self, input_size, hidden_size, num_layers, num_classes):
        super(GRU, self).__init__()
        self.num_layers = num_layers
        self.hidden_size = hidden_size

        self.gru = nn.GRU(input_size, hidden_size, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_size, num_classes)
        
    def forward(self, x):
        # Set initial hidden states (and cell states for LSTM)
        h0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size) 

        # Forward propagate  
        out, _ = self.gru(x, h0)  
        out = out[:, -1, :]
        return self.fc(out)

model = GRU(input_size, hidden_size, num_layers, num_classes)

# Loss and optimizer
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)  

# Train the model
n_total_steps = len(train_loader)
for epoch in range(num_epochs):
    for i, (images, labels) in enumerate(train_loader):
        images = images.reshape(-1, sequence_length, input_size)
        labels = labels
        
        # Forward pass
        outputs = model(images)
        loss = criterion(outputs, labels)
        
        # Backward and optimize
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        
        if (i+1) % 100 == 0:
            print (f'\rEpoch [{epoch+1}/{num_epochs}], Step [{i+1}/{n_total_steps}], Loss: {loss.item():.4f}', end="")

# network result 
with torch.no_grad():
    n_correct = 0
    n_samples = 0
    for images, labels in test_loader:
        images = images.reshape(-1, sequence_length, input_size)
        labels = labels
        outputs = model(images)
        
        _, predicted = torch.max(outputs.data, 1)
        n_samples += labels.size(0)
        n_correct += (predicted == labels).sum().item()

    acc = 100.0 * n_correct / n_samples
    print(f'Accuracy of the network on the 10000 test images: {acc} %')


# Results:
# Epoch [1/2], Step [100/600], Loss: 0.6701
# Epoch [1/2], Step [200/600], Loss: 0.4207
# Epoch [1/2], Step [300/600], Loss: 0.3609
# Epoch [1/2], Step [400/600], Loss: 0.2697
# Epoch [1/2], Step [500/600], Loss: 0.1372
# Epoch [1/2], Step [600/600], Loss: 0.1876
# Epoch [2/2], Step [100/600], Loss: 0.1166
# Epoch [2/2], Step [200/600], Loss: 0.1644
# Epoch [2/2], Step [300/600], Loss: 0.1299
# Epoch [2/2], Step [400/600], Loss: 0.0698
# Epoch [2/2], Step [500/600], Loss: 0.0248
# Epoch [2/2], Step [600/600], Loss: 0.0699
# Accuracy of the network on the 10000 test images: 97.15 %