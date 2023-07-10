import matplotlib.pyplot as plt
import torch
import torchvision
import os
import torch.utils.data as Data
import torch.nn as nn
import numpy as np
import torch.nn.functional as F
import time
from torchvision import transforms
import os

os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'

BATCH_SIZE = 200
EPOCH = 100
LR = 0.01

DOWNLOAD_CIFAR10 = False
if not(os.path.exists('./CIFAR10/')) or not os.listdir('./CIFAR10/'):
    DOWNLOAD_CIFAR10 = True


train_data = torchvision.datasets.CIFAR10(
    root='./CIFAR10',
    train=True,
    transform=torchvision.transforms.ToTensor(),
    download=DOWNLOAD_CIFAR10
)

print(train_data.data.shape)
print(train_data.targets.__len__())
# plt.imshow(train_data.data[0])
# plt.show()

train_loader = Data.DataLoader(dataset=train_data, batch_size=BATCH_SIZE, shuffle=True)
test_data = torchvision.datasets.CIFAR10(root='./CIFAR10', train=False, transform=transforms.ToTensor())
test_loader = Data.DataLoader(dataset=test_data, batch_size=BATCH_SIZE, shuffle=True)

# test_x = torch.from_numpy(test_loader.data).type(torch.FloatTensor).permute(0, 3, 1, 2)
# test_y = test_loader.targets


class CNN(nn.Module):
    def __init__(self):
        super(CNN, self).__init__()
        self.conv1 = nn.Sequential(
            nn.Conv2d(3, 64, 3, 1, 1),
            nn.BatchNorm2d(64),
            nn.ReLU()
        )
        # after convolution layer 1, the shape is 64x32x32.

        self.conv2 = nn.Sequential(
            nn.Conv2d(64, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU()
        )
        # after convolution layer 2, the shape is 128x32x32.

        self.conv3 = nn.Sequential(
            nn.Conv2d(128, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU()
        )

        self.conv4 = nn.Sequential(
            nn.Conv2d(128, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )
        # after convolution layer 4, the shape is 128x16x16.

        self.conv5 = nn.Sequential(
            nn.Conv2d(128, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU()
        )

        self.conv6 = nn.Sequential(
            nn.Conv2d(128, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU()
        )

        self.conv7 = nn.Sequential(
            nn.Conv2d(128, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )

        # after convolution layer 7, the shape is 128x8x8.

        self.conv8 = nn.Sequential(
            nn.Conv2d(128, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU()
        )

        self.conv9 = nn.Sequential(
            nn.Conv2d(128, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )
        # after convolution layer 9, the shape is 128x4x4.

        self.conv10 = nn.Sequential(
            nn.Conv2d(128, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU()
        )

        self.conv11 = nn.Sequential(
            nn.Conv2d(128, 128, 1, 1, 0),
            nn.BatchNorm2d(128),
            nn.ReLU()
        )
        # after convolution layer 11, the shape is 128x4x4.

        self.conv12 = nn.Sequential(
            nn.Conv2d(128, 128, 1, 1, 0),
            nn.BatchNorm2d(128),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )
        # after convolution layer 12, the shape is 128x2x2.

        self.conv13 = nn.Sequential(
            nn.Conv2d(128, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )
        # after convolution layer 12, the shape is 128x1x1.

        self.linear = nn.Linear(128 * 1 * 1, 10)

    def forward(self, x):
        x = self.conv1(x)
        x = self.conv2(x)
        x = self.conv3(x)
        x = self.conv4(x)
        x = self.conv5(x)
        x = self.conv6(x)
        x = self.conv7(x)
        x = self.conv8(x)
        x = self.conv9(x)
        x = self.conv10(x)
        x = self.conv11(x)
        x = self.conv12(x)
        x = self.conv13(x)
        x = x.view(x.size(0), -1)

        output_layer = self.linear(x)
        return output_layer


gpus = [0]
cuda_gpu = torch.cuda.is_available()
cnn = CNN()
# print(cnn)

if cuda_gpu:
    cnn = torch.nn.DataParallel(cnn, device_ids=gpus).cuda()

optimizer = torch.optim.Adam(cnn.parameters(), lr=LR)
loss_func = nn.CrossEntropyLoss()

time_start = time.time()
for epoch in range(EPOCH):
    for step, (b_x, b_y) in enumerate(train_loader):
        if cuda_gpu:
            b_x = b_x.cuda()
            b_y = b_y.cuda()
        output = cnn(b_x)
        loss = loss_func(output, b_y)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        if step % 50 == 0:
            accuracy = 0
            for test_step, (test_x, test_y) in enumerate(test_loader):
                if cuda_gpu:
                    test_x = test_x.cuda()
                test_out = cnn(test_x)
                pred_y = torch.max(test_out, 1)[1].data
                if cuda_gpu:
                    pred_y = pred_y.cpu().numpy()
                else:
                    pred_y = pred_y.numpy()
                accuracy += float((pred_y == np.array(test_y)).astype(int).sum()) / float(len(test_y))
            print('Epoch: ', epoch, '| train loss: %.4f' % loss.data, '| test accuracy: %.2f' % (accuracy/(test_step+1)))

time_end = time.time()
print("all time consume: ", time_end-time_start)
