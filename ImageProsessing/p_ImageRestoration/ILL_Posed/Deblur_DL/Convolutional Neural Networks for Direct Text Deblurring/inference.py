

import L15
import matplotlib.pyplot as plt
import numpy as np
import os
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms, datasets, models
from collections import defaultdict
import torch.nn.functional as F
from torch.nn.functional import mse_loss
import torch
import torch.nn as nn
import torch.optim as optim
from torch.optim import lr_scheduler
import time
import copy
import h5py
import cv2
import re


# In[2]:


device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = L15.L15()
model.load_state_dict(torch.load("model.pth", map_location=device))
start = time.time()


# In[40]:


def img_mask(image,mask):
    image = re.sub(r"\\", r"\\\\", image)
    mask = re.sub(r"\\", r"\\\\", mask)
    image = torch.Tensor(cv2.cvtColor(cv2.imread(image), cv2.COLOR_BGR2RGB))
    mask = torch.Tensor(cv2.cvtColor(cv2.imread(mask), cv2.COLOR_BGR2RGB))
    random_number = np.random.randint(0, 235)
    image = image[random_number:random_number + 64, random_number:random_number + 64]/255.0
    mask = mask[random_number:random_number + 64, random_number:random_number + 64]/255.0
    return [image, mask]


# In[41]:


img,mask = img_mask(".\data\data\\0000000_blur.png",".\data\data\\0000000_orig.png")
#img_tensor = torch.from_numpy(img_array)
print(img.permute(2,0,1).unsqueeze(0).shape)
print(mask.shape)


# In[65]:


pred = (model(img.permute(2,0,1).unsqueeze(0)).detach()).cpu().numpy()
pred = np.squeeze(pred, axis=0)
print(pred.shape)


# In[66]:


pred = np.rollaxis(pred, 0, 3)
print(pred.shape)

print(time.time() - start)

# In[47]:


plt.figure()
plt.imshow(img, interpolation="bicubic")
plt.title("Blur")
#plt.show()


# In[48]:


plt.figure()
plt.imshow(mask, interpolation="bicubic")
plt.title("Original")
#plt.show()


# In[67]:

plt.figure()
plt.imshow(pred, interpolation="bicubic")
plt.title("Prediction")
plt.show()