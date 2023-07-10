import torchvision
import torch
import os
import torch.utils.data as Data
import numpy as np
from torchvision import transforms
from torch import nn
import time

os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'

BATCH_SIZE = 200
EPOCH = 100
LR = 0.1

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


class VGG(nn.Module):
    def __init__(self):
        super(VGG, self).__init__()
        self.conv1 = nn.Sequential(
            # nn.Conv2d(3, 64, 3, 1, 1),
            # nn.BatchNorm2d(64),
            # nn.ReLU()
            *[nn.Conv2d(3, 64, 3, 1, 1), nn.BatchNorm2d(64), nn.ReLU()]
        )
        # after convolution layer 1, the shape is 64x32x32.

        self.conv2 = nn.Sequential(
            nn.Conv2d(64, 64, 3, 1, 1),
            nn.BatchNorm2d(64),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )
        # after convolution layer 2, the shape is 64x16x16.

        self.conv3 = nn.Sequential(
            nn.Conv2d(64, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU()
        )
        # after convolution layer 3, the shape is 128x16x16.

        self.conv4 = nn.Sequential(
            nn.Conv2d(128, 128, 3, 1, 1),
            nn.BatchNorm2d(128),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )
        # after convolution layer 4, the shape is 128x8x8.

        self.conv5 = nn.Sequential(
            nn.Conv2d(128, 256, 3, 1, 1),
            nn.BatchNorm2d(256),
            nn.ReLU()
        )
        # after convolution layer 5, the shape is 256x8x8.

        self.conv6 = nn.Sequential(
            nn.Conv2d(256, 256, 3, 1, 1),
            nn.BatchNorm2d(256),
            nn.ReLU()
        )
        # after convolution layer 6, the shape is 256x8x8.

        self.conv7 = nn.Sequential(
            nn.Conv2d(256, 256, 3, 1, 1),
            nn.BatchNorm2d(256),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )
        # after convolution layer 7, the shape is 256x4x4.

        self.conv8 = nn.Sequential(
            nn.Conv2d(256, 512, 3, 1, 1),
            nn.BatchNorm2d(512),
            nn.ReLU()
        )
        # after convolution layer 8, the shape is 512x4x4.

        self.conv9 = nn.Sequential(
            nn.Conv2d(512, 512, 3, 1, 1),
            nn.BatchNorm2d(512),
            nn.ReLU()
        )
        # after convolution layer 9, the shape is 512x4x4.

        self.conv10 = nn.Sequential(
            nn.Conv2d(512, 512, 3, 1, 1),
            nn.BatchNorm2d(512),
            nn.ReLU(),
            nn.MaxPool2d(2)
        )
        # after convolution layer 10, the shape is 512x2x2.

        self.conv11 = nn.Sequential(
            nn.Conv2d(512, 512, 3, 1, 1),
            nn.BatchNorm2d(512),
            nn.ReLU()
        )
        # after convolution layer 11, the shape is 512x2x2.

        self.conv12 = nn.Sequential(
            nn.Conv2d(512, 512, 3, 1, 1),
            nn.BatchNorm2d(512),
            nn.ReLU()
        )
        # after convolution layer 12, the shape is 512x2x2.

        self.conv13 = nn.Sequential(
            # nn.Conv2d(512, 512, 3, 1, 1),
            # nn.BatchNorm2d(512),
            # nn.ReLU(),
            # nn.MaxPool2d(2)
        )
        # after convolution layer 13, the shape is 512x1x1.

        self.out = nn.Sequential(
            nn.Dropout(),
            nn.Linear(512, 512),
            nn.ReLU(),
            nn.Dropout(),
            nn.Linear(512, 512),
            nn.ReLU(),
            nn.Linear(512, 10)
        )

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

        output = self.out(x)
        return output


gpus = [0]
cuda_gpu = torch.cuda.is_available()
vgg = VGG()

if cuda_gpu:
    vgg = torch.nn.DataParallel(vgg, device_ids=gpus).cuda()


optimizer = torch.optim.SGD(vgg.parameters(), lr=LR)
loss_func = nn.CrossEntropyLoss()


time_start = time.time()
for epoch in range(EPOCH):
    for step, (b_x, b_y) in enumerate(train_loader):
        if cuda_gpu:
            b_x = b_x.cuda()
            b_y = b_y.cuda()
        output = vgg(b_x)
        loss = loss_func(output, b_y)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        if step % 50 == 0:
            LR *= 0.99
            accuracy = 0
            for test_step, (test_x, test_y) in enumerate(test_loader):
                if cuda_gpu:
                    test_x = test_x.cuda()
                test_out = vgg(test_x)
                pred_y = torch.max(test_out, 1)[1].data
                if cuda_gpu:
                    pred_y = pred_y.cpu().numpy()
                else:
                    pred_y = pred_y.numpy()
                accuracy += float((pred_y == np.array(test_y)).astype(int).sum()) / float(len(test_y))
            print('Epoch: ', epoch, '| train loss: %.4f' % loss.data, '| test accuracy: %.2f' % (accuracy/(test_step+1)))

time_end = time.time()
print("all time consume: ", time_end-time_start)
