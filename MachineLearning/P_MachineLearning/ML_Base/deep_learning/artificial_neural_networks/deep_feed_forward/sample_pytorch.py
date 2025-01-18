import torch
import torch.nn as nn
import torchvision.transforms as transforms
import torchvision.datasets as dsets

# datasets
train_dataset = dsets.MNIST(root='../../../_data', train=True, transform=transforms.ToTensor(), download=True)
test_dataset = dsets.MNIST(root='../../../_data', train=False, transform=transforms.ToTensor())

# normalize dataset
batch_size = 100
n_iters = 3000
n_epochs = int(n_iters / (len(train_dataset) / batch_size))

train_loader = torch.utils.data.DataLoader(dataset=train_dataset, batch_size=batch_size, shuffle=True)
test_loader = torch.utils.data.DataLoader(dataset=test_dataset, batch_size=batch_size, shuffle=False)

class FeedforwardNeuralNetModel(nn.Module):
    def __init__(self, input_dim, hidden_dim, output_dim):
        super(FeedforwardNeuralNetModel, self).__init__()
        # Linear function
        self.fc1 = nn.Linear(input_dim, hidden_dim) 

        # Non-linearity
        self.tanh = nn.Tanh()

        # Linear function (readout)
        self.fc2 = nn.Linear(hidden_dim, output_dim)  

    def forward(self, x):
        # Linear function
        out = self.fc1(x)
        
        # Non-linearity
        out = self.tanh(out)
        
        # Linear function (readout)
        out = self.fc2(out)
        return out

# define network
learning_rate = 0.1
input_dim = 28*28
hidden_dim = 100
output_dim = 10

network = FeedforwardNeuralNetModel(input_dim, hidden_dim, output_dim)

criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.SGD(network.parameters(), lr=learning_rate)

# trian network
for epoch in range(n_epochs):
    for i, (images, labels) in enumerate(train_loader):
        # Load images with gradient accumulation capabilities
        images = images.view(-1, 28*28).requires_grad_()

        # Clear gradients w.r.t. parameters
        optimizer.zero_grad()

        # Forward pass to get output/logits
        outputs = network(images)

        # Calculate Loss: softmax --> cross entropy loss
        loss = criterion(outputs, labels)

        # Getting gradients w.r.t. parameters
        loss.backward()

        # Updating parameters
        optimizer.step()

        if epoch % 500 == 0:
            # Calculate Accuracy         
            correct = 0
            total = 0

            # Iterate through test dataset
            for images, labels in test_loader:
                # Load images with gradient accumulation capabilities
                images = images.view(-1, 28*28).requires_grad_()

                # Forward pass only to get logits/output
                outputs = network(images)

                # Get predictions from the maximum value
                _, predicted = torch.max(outputs.data, 1)

                # Total number of labels
                total += labels.size(0)

                # Total correct predictions
                correct += (predicted == labels).sum()

            accuracy = 100 * correct / total

            # Print Loss

            print(f'[{epoch}/{n_epochs}] Loss: {loss.item()}. Accuracy: {accuracy}')