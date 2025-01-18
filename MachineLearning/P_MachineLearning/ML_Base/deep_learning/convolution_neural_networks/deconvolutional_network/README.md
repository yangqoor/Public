# Deconvolutional Network(DN)
(a.k.a. transposed convolutions or fractionally strided convolutions)  

`Deconvolutional Network` can be described many different ways. Many of these tools use the same types of filters as convolutional neural networks but use them differently. Professionals utilize ideas like backpropagation and reverse filtering along with techniques like striding and padding to build transposed convolutional models.

In a very simplistic sense, one could say that professionals might “run a CNN backward,” but the actual mechanics of deconvolutional neural networks are much more sophisticated than that. Another part of convolutional and deconvolutional neural networks involves creating a hierarchy – for example, an initial network model might do the primary learning and another model might visually segment the target image. Generally, the DNN involves mapping matrices of pixel values and running a “feature selector” or other tool over an image. All of this serves the purpose of training machine learning programs, particularly in image processing and computer vision.

## code 
[`python3 sample_keras.py`](./sample_keras.py)  
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
<!-- [`python3 sample_scratch.py`](./sample_scratch.py)   -->

<p align="center">
  <img src="https://miro.medium.com/max/2294/1*LW8Anre45o9nfamxIVTY8Q.png"  width="500px">
</p>
<p align="center">
  <img src="https://miro.medium.com/max/800/1*rKutroE_W1rEjd2BIVssUQ.png"  width="500px">
</p>
<p align="center">
  <img src="https://miro.medium.com/max/1050/1*AeknLPTWGXsUDKCZA9pb5A.png"  width="500px">
</p>

## Usefull Resources:
+ https://iksinc.online/2020/03/09/convolution-and-deconvolution-revisited/
+ https://uvadlc-notebooks.readthedocs.io/en/latest/tutorial_notebooks/tutorial9/AE_CIFAR10.html
+ https://distill.pub/2016/deconv-checkerboard/
+ https://d2l.ai/chapter_computer-vision/transposed-conv.html
+ https://datascience.stackexchange.com/questions/6107/what-are-deconvolutional-layers
+ https://medium.com/machinelearningadvantage/here-are-the-mind-blowing-things-a-deconvolutional-neural-network-can-do-2fc99e008fe4 (use incognito)
+ https://towardsdatascience.com/types-of-convolutions-in-deep-learning-717013397f4d
+ https://arxiv.org/pdf/1603.07285v1.pdf
+ https://cs.nyu.edu/~fergus/drafts/utexas2.pdf
+ http://72.42.81.168/Deconvolutional%20Networks.pdf