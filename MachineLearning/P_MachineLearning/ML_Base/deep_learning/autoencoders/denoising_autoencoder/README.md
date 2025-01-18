# Denoising Auto Encoder(DAE)
`Denoising autoencoders` are a stochastic version of standard autoencoders that reduces the risk of learning the identity function. `Autoencoders` are a class of neural networks used for feature selection and extraction, also called dimensionality reduction. In general, the more hidden layers in an autoencoder, the more refined this dimensional reduction can be. However, if an autoencoder has more hidden layers than inputs there is a risk the algorithm only learns the identity function during training, the point where the output simply equals the input, and then becomes useless.

Denoising autoencoders attempt to get around this risk of identity-function affiliation by introducing noise, i.e. randomly corrupting input so that the autoencoder must then “denoise” or reconstruct the original input.

## code 
[`python3 sample_keras.py`](./sample_keras.py)  
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
[`python3 sample_scratch.py`](./sample_scratch.py)  

<p align="center">
  <img src="https://miro.medium.com/max/724/1*qKiQ1noZdw8k05-YRIl6hw.jpeg"  width="500px">
</p>
<p align="center">
  <img src="https://images.deepai.org/glossary-terms/e6f368bb361f4f40b24ccde53360f75f/denoising.png"  width="500px">
</p>
<p align="center">
  <img src="https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/6eedff03-6a0e-48f5-8439-0cad8b4826c7/2b20809f-49b6-4df7-b361-a5bcd9d13ced/images/screenshot.jpg" width="500px">
</p>

## Usefull Resources:
+ https://keras.io/examples/vision/autoencoder/
+ https://www.tensorflow.org/tutorials/generative/autoencoder
+ https://medium.com/analytics-vidhya/reconstruct-corrupted-data-using-denoising-autoencoder-python-code-aeaff4b0958e
+ https://deepai.org/machine-learning-glossary-and-terms/denoising-autoencoder
+ https://towardsdatascience.com/denoising-autoencoders-explained-dbb82467fc2