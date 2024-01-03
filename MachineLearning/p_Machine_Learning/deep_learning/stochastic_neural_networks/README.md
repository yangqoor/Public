# Stochastic Neural Networks(SNNs)
Stochastic neural networks are a type of artificial neural networks built by introducing random variations into the network, either by giving the network's neurons stochastic transfer functions, or by giving them stochastic weights. This makes them useful tools for optimization problems, since the random fluctuations help it escape from local minima.

An example of a neural network using stochastic transfer functions is a Boltzmann machine. Each neuron is binary valued, and the chance of it firing depends on the other neurons in the network. 
(`Markov Decision Process(MDP)` is the mathematical framework for `Reinforcement Learning`)



(best way to learn is from top to bottom).  
The subsets of `Stochastic Neural Networks`:  
- [`Deep Belief Network`](./Deep_Belief_Network/README.md)
- [`Restricted Boltzmann Machine`](./Restricted_Boltzmann_Machine/README.md)

<p align="center">
  <img src="https://www.researchgate.net/publication/330246603/figure/fig1/AS:713162357751811@1547042564883/Architecture-of-a-deep-belief-network-DBN.png" width="500px">
</p>
<p align="center">
  <img src="https://i1.wp.com/vinodsblog.com/wp-content/uploads/2020/07/RBM-AILabPage.png?fit=1999%2C1125&ssl=1" width="500px">
</p>

## Usefull Resources:
+ https://en.wikipedia.org/wiki/Stochastic_neural_network
+ https://link.springer.com/article/10.1007/BF01759054 
+ https://github.com/mehulrastogi
+ https://github.com/mehulrastogi/Deep-Belief-Network-pytorch
+ https://github.com/wmingwei/restricted-boltzmann-machine-deep-belief-network-deep-boltzmann-machine-in-pytorch