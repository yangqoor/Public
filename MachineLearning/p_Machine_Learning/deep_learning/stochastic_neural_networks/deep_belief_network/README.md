# Deep Belief Network(DBN)
`Deep Belief Networks (DBNs)` is the technique of stacking many individual unsupervised networks that use each network’s hidden layer as the input for the next layer. Usually, a “stack” of restricted Boltzmann machines (RBMs) or autoencoders are employed in this role. The ultimate goal is to create a faster unsupervised training procedure that relies on contrastive divergence for each sub-network. 

How are Deep Belief Network’s used?
The lowest visible layer is called the training set. From there, each layer can communicate with the previous and subsequent layers. However, the nodes of any particular layer cannot communicate laterally with each other.

In supervised learning, this stack usually ends with a final classification layer and in unsupervised learning it often ends with an input for cluster analysis. 

Except for the first and last layers, each level in a DBN serves a dual role function: it’s the hidden layer for the nodes that came before and the visible (output) layer for the nodes that come next.

## code 
<!-- [`python3 sample_scratch.py`](./sample_scratch.py)   -->
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
<!-- [`python3 sample_keras.py`](./sample_keras.py) (todo) -->

<p align="center">
  <img src="https://agollp.files.wordpress.com/2013/12/dbm.jpg"  width="500px">
</p>
<p align="center">
  <img src="https://miro.medium.com/max/1138/0*02BGiVqditdP8e32.gif"  width="500px">
</p>

## Usefull Resources:
+ https://en.wikipedia.org/wiki/Deep_belief_network
+ https://medium.com/@icecreamlabs/deep-belief-networks-all-you-need-to-know-68aa9a71cc53