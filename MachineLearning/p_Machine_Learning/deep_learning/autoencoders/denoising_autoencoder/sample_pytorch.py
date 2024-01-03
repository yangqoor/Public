import numpy as np
from tensorflow.keras.datasets import mnist
import matplotlib.pyplot as plt
from tqdm import tqdm
from torchvision import transforms
import torch.nn as nn
from torch.utils.data import DataLoader,Dataset
import torch
import torch.optim as optim
from torch.autograd import Variable

class noising_dataset(Dataset):
      
  def __init__(self,datasetnoised,datasetclean,labels,transform):
    self.noise=datasetnoised
    self.clean=datasetclean
    self.labels=labels
    self.transform=transform
  
  def __len__(self):
    return len(self.noise)
  
  def __getitem__(self,idx):
    xNoise=self.noise[idx]
    xClean=self.clean[idx]
    y=self.labels[idx]
    
    if self.transform != None:
      xNoise=self.transform(xNoise)
      xClean=self.transform(xClean)
      
    
    return (xNoise,xClean,y)

class DenoisingNetwork(nn.Module):
  def __init__(self):
    super(DenoisingNetwork,self).__init__()
    self.encoder=nn.Sequential(
      nn.Linear(28*28,256),
      nn.ReLU(True),
      nn.Linear(256,128),
      nn.ReLU(True),
      nn.Linear(128,64),
      nn.ReLU(True)
    )
    
    self.decoder=nn.Sequential(
      nn.Linear(64,128),
      nn.ReLU(True),
      nn.Linear(128,256),
      nn.ReLU(True),
      nn.Linear(256,28*28),
      nn.Sigmoid(),
    )
    
 
  def forward(self,x):
    x=self.encoder(x)
    x=self.decoder(x)
    
    return x

# data
(xtrain, ytrain), (xtest, ytest) = mnist.load_data()
traindata=np.zeros((60000,28,28))
testdata = np.zeros((10000,28,28))

def add_noise(img):    
    row, col = 28, 28
    img = img.astype(np.float32)

    mean = 0
    var = 10
    sigma=var ** .5
    noise=np.random.normal(-5.9,5.9,img.shape)
    noise=noise.reshape(row,col)
    img = img + noise
    return img

for idx in tqdm(range(len(xtest))):
    traindata[idx] = add_noise(xtrain[idx])
    testdata[idx] = add_noise(xtest[idx])
    
trainset=noising_dataset(traindata,xtrain,ytrain,transforms.Compose([ transforms.ToTensor() ]))
testset=noising_dataset( testdata, xtest, ytest,transforms.Compose([ transforms.ToTensor() ]))
trainloader=DataLoader(trainset,batch_size=32,shuffle=True)
testloader=DataLoader(testset,batch_size=1,shuffle=True)

# showing images with gaussian noise
f, axes=plt.subplots(2)
axes[0].imshow(xtrain[0],cmap="gray")
axes[0].set_title("Original Image")
axes[1].imshow(traindata[0],cmap="gray")
axes[1].set_title("Noised Image")
plt.show()

# settings
batch_size = 32
n_epochs = 200
l=len(trainloader)
losslist=list()
epochloss=0
running_loss=0

# define network
network = DenoisingNetwork().to("cpu")
optimizer=optim.SGD(network.parameters(),lr=0.01,weight_decay=1e-5)
criterion=nn.MSELoss()

# train network
for epoch in range(n_epochs):
    for dirty, clean, label in tqdm((trainloader)):
        dirty = dirty.view(dirty.size(0),-1).type(torch.FloatTensor).to("cpu")
        clean = clean.view(clean.size(0),-1).type(torch.FloatTensor).to("cpu")
        
        #-----------------Forward Pass----------------------
        output = network(dirty)
        loss = criterion(output,clean)

        #-----------------Backward Pass---------------------
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        
        running_loss += loss.item()
        epochloss += loss.item()
        
    #-----------------Log-------------------------------
    losslist.append(running_loss/l)
    running_loss=0
    print(f"[{epoch}/{n_epochs}], loss:{loss.item()}")

# network results
plt.plot(range(len(losslist)),losslist)
f,axes= plt.subplots(6,3,figsize=(20,20))
axes[0,0].set_title("Original Image")
axes[0,1].set_title("Dirty Image")
axes[0,2].set_title("Cleaned Image")

test_imgs=np.random.randint(0,10000,size=6)
for idx in range((6)):
    dirty=testset[test_imgs[idx]][0]
    clean=testset[test_imgs[idx]][1]
    label=testset[test_imgs[idx]][2]
    dirty=dirty.view(dirty.size(0),-1).type(torch.FloatTensor)
    dirty=dirty.to("cpu")
    output=network(dirty)
    
    output=output.view(1,28,28)
    output=output.permute(1,2,0).squeeze(2)
    output=output.detach().cpu().numpy()
    
    dirty=dirty.view(1,28,28)
    dirty=dirty.permute(1,2,0).squeeze(2)
    dirty=dirty.detach().cpu().numpy()
    
    clean=clean.permute(1,2,0).squeeze(2)
    clean=clean.detach().cpu().numpy()
    
    axes[idx,0].imshow(clean,cmap="gray")
    axes[idx,1].imshow(dirty,cmap="gray")
    axes[idx,2].imshow(output,cmap="gray")

plt.show()