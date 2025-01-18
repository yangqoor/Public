# Auto Encoder(AE)
The [`Autoencoder`](https://towardsdatascience.com/deep-inside-autoencoders-7e41f319999f) consists of only one hidden layer. The number of neurons in the hidden layer is less than the number of neurons in the input (or output) layer. This results in producing a bottleneck effect on the flow of information in the network, and therefore we can think of the hidden layer as a bottleneck layer, restricting the information that would be stored. Learning in the autoencoder consists of developing a compact representation of the input signal at the hidden layer so that the output layer can faithfully reproduce the original input

## code 
[`python3 sample_keras.py`](./sample_keras.py)  
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
[`python3 sample_scratch.py`](./sample_scratch.py)  

<p align="center">
  <img src="https://www.oreilly.com/library/view/tensorflow-1x-deep/9781788293594/assets/7ca4c522-394e-49e6-bd32-e6679893f099.png"  width="500px">
</p>
<p align="center">
  <img src="https://paperswithcode.com/media/methods/Autoencoder_schema.png"  width="500px">
</p>
<p align="center">
  <img src="https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/017c0e39-186c-4d35-b46a-cada01ccffce/83c02c60-b3b5-45c0-b915-0b8ab9ffe7e9/images/screenshot.jpg"  width="500px">
</p>

## Usefull Resources:
+ https://analyticsindiamag.com/how-to-implement-convolutional-autoencoder-in-pytorch-with-cuda/
+ https://github.com/L1aoXingyu/pytorch-beginner/blob/master/08-AutoEncoder/simple_autoencoder.py
+ https://www.cs.toronto.edu/~lczhang/360/lec/w05/autoencoder.html
+ https://towardsdatascience.com/deep-inside-autoencoders-7e41f319999f  
+ https://blog.keras.io/building-autoencoders-in-keras.html  
+ https://www.mygreatlearning.com/blog/autoencoder/
+ https://debuggercafe.com/implementing-deep-autoencoder-in-pytorch/
