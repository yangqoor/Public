# Echo State Network(ESN)
An `Echo State Network` is an instance of the more general concept of Reservoir Computing. The basic idea behind the `ESN` is to get the benefits of a `RNN` (process a sequence of inputs that are dependent on each other, i.e. time dependencies like a signal) but without the problems of training a traditional `RNN` like the vanishing gradient problem.

ESNs achieve this by having a relatively large reservoir of sparsely connected neurons using a sigmoidal transfer function (relative to input size, something like 100-1000 units). The connections in the reservoir are assigned once and are completely random; the reservoir weights do not get trained. Input neurons are connected to the reservoir and feed the input activations into the reservoir - these too are assigned untrained random weights. The only weights that are trained are the output weights which connect the reservoir to the output neurons.

In training, the inputs will be fed to the reservoir and a teacher output will be applied to the output units. The reservoir states are captured over time and stored. Once all of the training inputs have been applied, a simple application of linear regression can be used between the captured reservoir states and the target outputs. These output weights can then be incorporated into the existing network and used for novel inputs.

The idea is that the sparse random connections in the reservoir allow previous states to "echo" even after they have passed, so that if the network receives a novel input that is similar to something it trained on, the dynamics in the reservoir will start to follow the activation trajectory appropriate for the input and in that way can provide a matching signal to what it trained on, and if it is well-trained it will be able to generalize from what it has already seen, following activation trajectories that would make sense given the input signal driving the reservoir.

The advantage of this approach is in the incredibly simple training procedure since most of the weights are assigned only once and at random. Yet they are able to capture complex dynamics over time and are able to model properties of dynamical systems.

## code 
[`python3 sample.py`](./sample.py)  
<!-- [`python3 sample_keras.py`](./sample_keras.py)       -->
<!-- [`python3 sample_pytorch.py`](./sample_pytorch.py)   -->
<!-- [`python3 sample_scratch.py`](./sample_scratch.py)   -->

<p align="center">
  <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT9TgSEuE7swyBtfrteKFLXp90MMdSo6tIlz9aiH9JfkdafZZsG0uI8jdMci0CZUXq17Ic&usqp=CAU"  width="500px">
</p>
<p align="center">
  <img src="https://www.researchgate.net/profile/Yiannis-Demiris/publication/263124732/figure/fig1/AS:650403301576706@1532079639792/Echo-State-Network-ESN-In-the-typical-setup-the-inputs-are-fully-connected-to-a.png"  width="500px">
</p>

## Usefull Resources:
+ https://towardsdatascience.com/gentle-introduction-to-echo-state-networks-af99e5373c68
+ https://stats.stackexchange.com/questions/140652/what-is-an-intuitive-explanation-of-echo-state-networks
+ https://www.youtube.com/watch?v=7dYh1wK_3zE
+ https://www.ai.rug.nl/minds/uploads/PracticalESN.pdf
+ https://en.wikipedia.org/wiki/Echo_state_network#:~:text=The%20echo%20state%20network%20(ESN,with%20typically%201%25%20connectivity).&text=The%20weights%20of%20output%20neurons,or%20reproduce%20specific%20temporal%20patterns.
+ https://github.com/stefanonardo/pytorch-esn
+ https://github.com/nschaetti/EchoTorch