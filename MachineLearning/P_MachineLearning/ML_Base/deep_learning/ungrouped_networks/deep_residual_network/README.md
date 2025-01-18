# Deep Residual Network (ResNet)
In deep learning networks, a residual learning framework helps to preserve good results through a network with many layers. One problem commonly cited by professionals is that with deep networks composed of many dozens of layers, accuracy can become saturated, and some degradation can occur. Some talk about a different problem called "vanishing gradient" in which the gradient fluctuations become too small to be immediately useful.

The deep residual network deals with some of these problems by using residual blocks, which take advantage of residual mapping to preserve inputs. By utilizing deep residual learning frameworks, engineers can experiment with deeper networks that have specific training challenges.

## code 
[`python3 sample_keras.py`](./sample_keras.py)      
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
<!-- [`python3 sample_scratch.py`](./sample_scratch.py)   -->

<p align="center">
  <img src="https://www.programmersought.com/images/701/e2155882444d8fac8959ef4722e73025.JPEG"  width="500px">
</p>
<p align="center">
  <img src="https://neurohive.io/wp-content/uploads/2019/01/resnet-e1548261477164.png"  width="500px">
</p>

## Usefull Resources:
+ https://en.wikipedia.org/wiki/Residual_neural_network
+ https://medium.com/@waya.ai/deep-residual-learning-9610bb62c355
+ https://towardsdatascience.com/residual-network-implementing-resnet-a7da63c7b278 (use incognito)
+ https://github.com/pytorch/vision/blob/master/torchvision/models/resnet.py
+ https://towardsdatascience.com/hitchhikers-guide-to-residual-networks-resnet-in-keras-385ec01ec8ff (use incognito)
+ https://machinelearningknowledge.ai/keras-implementation-of-resnet-50-architecture-from-scratch/