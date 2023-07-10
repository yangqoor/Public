import torch
import os
import torchvision
import matplotlib.pyplot as plt
import torch.utils.data as Data
import torch.nn as nn
import time

from torch.utils.tensorboard import SummaryWriter


EPOCH = 1
BATCH_SIZE = 50
LR = 0.00005
DOWNLOAD_MNIST = False


if not(os.path.exists('./mnist/')) or not os.listdir('./mnist/'):
    DOWNLOAD_MNIST = True


train_data = torchvision.datasets.MNIST(
    root='./mnist',
    train=True,
    transform=torchvision.transforms.ToTensor(),
    download=DOWNLOAD_MNIST
)


print(train_data.data.size())
print(train_data.targets.size())
# plt.imshow(train_data.data[100].numpy(), cmap='gray')
# plt.title('%i' % train_data.targets[100])
# plt.show()


train_loader = Data.DataLoader(dataset=train_data, batch_size=BATCH_SIZE, shuffle=True)
test_data = torchvision.datasets.MNIST(root='./mnist', train=False, transform=torchvision.transforms.ToTensor())
test_x = torch.unsqueeze(test_data.data, dim=1)/255.
test_y = test_data.targets


class CNN(nn.Module):
    def __init__(self):
        super(CNN, self).__init__()
        self.conv1 = nn.Sequential(
            nn.Conv2d(
                in_channels=1,
                out_channels=16,
                kernel_size=5,
                stride=2,
                padding=2,
            ),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )

        self.conv2 = nn.Sequential(
            nn.Conv2d(16, 32, 5, 1, 2),
            nn.ReLU(),
            # nn.MaxPool2d(2)
        )

        self.out = nn.Linear(32 * 7 * 7, 10)

    def forward(self, x):
        x = self.conv1(x)
        x = self.conv2(x)
        x = x.view(x.size(0), -1)
        output = self.out(x)
        return output

gpus = [0]
cuda_gpu = torch.cuda.is_available()
cnn = CNN()
# print(cnn)

if cuda_gpu:
    cnn = torch.nn.DataParallel(cnn, device_ids=gpus).cuda()

optimizer = torch.optim.Adam(cnn.parameters(), lr=LR)
loss_func = nn.CrossEntropyLoss()


time_start = time.time()
writer = SummaryWriter('tb_mnist')
for epoch in range(EPOCH):
    for step, (b_x, b_y) in enumerate(train_loader):
        # print(b_x.shape); break

        if cuda_gpu:
            b_x = b_x.cuda()
            b_y = b_y.cuda()

        output = cnn(b_x)
        loss = loss_func(output, b_y)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        if step % 50 == 0:
            test_output = cnn(test_x)
            pred_y = torch.max(test_output, 1)[1].data

            if cuda_gpu:
                pred_y = pred_y.cpu().numpy()
            else:
                pred_y = pred_y.numpy()

            accuracy = float((pred_y == test_y.data.numpy()).astype(int).sum()) / float(test_y.size(0))
            print('Epoch: ', epoch, '| train loss: %.4f' % loss.data, '| test accuracy: %.2f' % accuracy)

            writer.add_scalar("Train/Accuracy", accuracy, step)

        writer.add_scalar("Train/Loss", loss.item(), step)


time_end = time.time()
print("all time spent: ", time_end-time_start)
