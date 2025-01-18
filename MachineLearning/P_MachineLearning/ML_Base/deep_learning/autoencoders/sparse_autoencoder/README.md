# Sparse Auto Encoder(SAE)
In `sparse autoencoders` with a sparsity enforcer that directs a single layer network to learn code dictionary which minimizes the error in reproducing the input while constraining number of code words for reconstruction.

The `sparse autoencoder` consists of a single hidden layer, which is connected to the input vector by a weight matrix forming the encoding step. The hidden layer outputs to a reconstruction vector, using a tied weight matrix to form the decoder.

`Sparse autoencoders` are used to learn features from another task, such as classiﬁcation. A regularized autoencoder to be sparse must respond to unique statistical features of the trained dataset, instead of simply acting as an identity function.

## code 
[`python3 sample_keras.py`](./sample_keras.py)  
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
<!-- [`python3 sample_scratch.py`](./sample_scratch.py) -->

<p align="center">
  <img src="https://miro.medium.com/max/700/1*7H9VQlN94-wv7Ianqt6GZg.png" width="500px">
</p>
<p align="center">
  <img src="https://ars.els-cdn.com/content/image/1-s2.0-S0262885617300136-gr1.jpg" width="500px">
</p>
<p align="center">
  <img src="https://blog.keras.io/img/ae/jigsaw-puzzle.png" width="500px">
</p>

## Usefull Resources:
+ https://stats.stackexchange.com/questions/118199/what-are-the-differences-between-sparse-coding-and-autoencoder
+ https://www.hindawi.com/journals/jcse/2018/8676387/
+ https://medium.com/@venkatakrishna.jonnalagadda/sparse-stacked-and-variational-autoencoder-efe5bfe73b64
+ https://web.stanford.edu/class/cs294a/sparseAutoencoder.pdf
+ https://github.com/jadhavhninad/Sparse_autoencoder
+ https://www.jeremyjordan.me/autoencoders/