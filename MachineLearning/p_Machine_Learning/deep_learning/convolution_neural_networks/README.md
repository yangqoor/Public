# Convolution Neural Networks (CNNs)
[`Convolutional neural networks (CNNs, or ConvNets)`](https://www.cs.ryerson.ca/~aharley/vis/conv/flat.html) is a class of deep neural network, most commonly applied to analyze visual imagery. They are also known as shift invariant or space invariant artificial neural networks (SIANN), based on the shared-weight architecture of the convolution kernels or filters that slide along input features and provide translation equivariant responses known as feature maps. They have been used in applications like image and video recognition, recommender systems, image classification, image segmentation, medical image analysis, natural language processing, brain-computer interfaces, and financial time series.

`CNNs` are regularized versions of multilayer perceptrons. Multilayer perceptrons usually mean fully connected networks, that is, each neuron in one layer is connected to all neurons in the next layer. The "full connectivity" of these networks make them prone to overfitting data. Typical ways of regularization, or preventing overfitting, include: penalizing parameters during training (such as weight decay) or trimming connectivity (skipped connections, dropout, etc.) `CNNs` take a different approach towards regularization: they take advantage of the hierarchical pattern in data and assemble patterns of increasing complexity using smaller and simpler patterns embossed in their filters. Therefore, on a scale of connectivity and complexity, `CNNs` are on the lower extreme.

(best way to learn is from top to bottom).  
The subsets of `Convolution Neural Networks`:  
- [`Deep Convolutional Network`](./deep_convolutional_network/README.md)
- [`Deep Convolutional Inverse Graphics Network`](./deep_convolutional_inverse_graphics_network/README.md)
- [`Deconvolutional Network`](./deconvolutional_network/README.md)

<p align="center">
  <img src="https://images.deepai.org/user-content/7398488153-thumb-4335.svg" width="500px">
</p>
<p align="center">
  <img src="https://www.pyimagesearch.com/wp-content/uploads/2021/05/Convolutional-Neural-Networks-CNNs-and-Layer-Types.png" width="500px">
</p>
<p align="center">
  <img src="https://ujwlkarn.files.wordpress.com/2016/08/conv_all.png?w=1024" width="500px">
</p>

## Usefull Resources:
+ https://en.wikipedia.org/wiki/Convolutional_neural_network
+ https://deepai.org/machine-learning-glossary-and-terms/convolutional-neural-network
+ https://www.topbots.com/important-cnn-architectures/
+ https://stanford.edu/~shervine/teaching/cs-230/cheatsheet-convolutional-neural-networks
+ https://ujjwalkarn.me/2016/08/11/intuitive-explanation-convnets/
+ https://towardsdatascience.com/convolutional-neural-networks-explained-9cc5188c4939
+ https://towardsdatascience.com/visualizing-convolution-neural-networks-using-pytorch-3dfa8443e74e (use incognito)