import torch
import torch.nn as nn
import torch.nn.functional as F
from torchvision import datasets, models, transforms

import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

# image
pil_image = Image.open('./images/elephant.jpg')
transform = transforms.ToTensor()
img = transform(pil_image)
img = img.unsqueeze(0)

# Define filters(weights)
filter_array = np.array([
    [-1, -0.5, 0, 0.5, 1],
    [-1, -0.5, 0, 0.5, 1],
    [-1, -0.5, 0, 0.5, 1],
    [-1, -0.5, 0, 0.5, 1],
    [-1, -0.5, 0, 0.5, 1]
])

filter_1, filter_2, filter_3, filter_4 = filter_array, -filter_array, filter_array.T, -filter_array
filters = np.array([filter_1, filter_2, filter_3, filter_4])

# # display Filters
# fig = plt.figure(figsize=(12, 6))
# fig.subplots_adjust(left=0, right=0.5, bottom=0.8, top=1, hspace=0.05, wspace=0.05)
# for i in range(4):
#     ax = fig.add_subplot(1, 4, i+1, xticks=[], yticks=[])
#     ax.imshow(filters[i], cmap="hot")
#     ax.set_title("Filter %s" % str(i+1))
# plt.show()


class Network(nn.Module):
    def __init__(self, wt1, wt2):
        super(Network, self).__init__()

        # filtered by
        self.conv1 = nn.Conv2d(3, 4, kernel_size=5, stride=1, dilation=1, bias=False)
        self.pool1 = nn.MaxPool2d(2, 2)

        self.conv2 = nn.Conv2d(4, 4, kernel_size=5, bias=False)
        self.pool2 = nn.MaxPool2d(2, 2)

        # Set filter weights
        with torch.no_grad():
            self.conv1.wt1 = torch.nn.Parameter(wt1)
            self.conv2.wt2 = torch.nn.Parameter(wt2)
        
    def forward(self, x):
        # calculates the output of a convolutional layer
        # pre- and post-activation
        conv1_x = self.conv1(x)
        activated1_x = F.relu(conv1_x)

        # apply pooling 
        pooled1_x = self.pool1(activated1_x)
        conv2_x = self.conv2(pooled1_x)
        activated2_x = F.relu(conv2_x)
        pooled2_x = self.pool2(activated2_x)

        # returns all layers
        return conv1_x, activated1_x, pooled1_x, conv2_x, activated2_x, pooled2_x

def visualize_layer(layer, n_filters=4):
    fig = plt.figure()

    for i in range(n_filters):
        ax = fig.add_subplot(1, n_filters, i+1)
        ax.imshow(np.squeeze(layer[0, i].data.numpy()))
        ax.set_title("Filter %s" % str(i+1))
    
wt1 = torch.from_numpy(filters).unsqueeze(1).type(torch.FloatTensor).repeat(1, 2, 3, 1)
wt2 = torch.from_numpy(filters).unsqueeze(1).type(torch.FloatTensor).repeat(3, 1, 1, 2)
model = Network(wt1, wt2)

# Compute output
conv1_x, activated1_layer, pooled1_layer, conv2_x, activated2_layer, pooled2_layer = model.forward(img)
visualize_layer(conv1_x)
visualize_layer(activated1_layer)

visualize_layer(conv2_x)
visualize_layer(activated2_layer)

plt.show()