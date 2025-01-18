# Liquid State Machine(LSM)
A liquid `state machine (LSM)` is a type of reservoir computer that uses a `spiking neural network`. An `LSM` consists of a large collection of units. Each unit receives time varying input from external sources (the inputs) as well as from other units. Nodes are randomly connected to each other. The recurrent nature of the connections turns the time varying input into a spatio-temporal pattern of activations in the network units. The spatio-temporal patterns of activation are read out by linear discriminant units.

`LSMs` have been put forward as a way to explain the operation of brains. `LSMs` are argued to be an improvement over the theory of artificial neural networks because:
```
  Circuits are not hard coded to perform a specific task.
  Continuous time inputs are handled "naturally".
  Computations on various time scales can be done using the same network.
  The same network can perform multiple computations.
  Criticisms of LSMs as used in computational neuroscience are that
    
  LSMs don't actually explain how the brain functions. 
  At best they can replicate some parts of brain functionality.
  There is no guaranteed way to dissect a working network and figure out 
  how or what computations are being performed.
  Very little control over the process.
```

## code 
```python
# todo

# All problems you can solve with this model we can use `Recurrent Neural Networks` for, 
# and `RNNs` do fix the problem way faster these days.  
# This is based more on the brain structure than the `Recurrent Neural Networks`. 
# In the future when we have better algorithms to use in this model 
# may lead us to a break through a new level of Machine Learning.
```
<!-- [`python3 sample_keras.py`](./sample_keras.py)   -->
<!-- [`python3 sample_pytorch.py`](./sample_pytorch.py)   -->
<!-- [`python3 sample_scratch.py`](./sample_scratch.py)   -->

<p align="center">
  <img src="https://repository-images.githubusercontent.com/125704803/be146080-3acb-11ea-87a1-f2d1beb986b8"  width="500px">
</p>
<p align="center">
  <img src="https://d3i71xaburhd42.cloudfront.net/4c155bb169547845abf904ccae190d276966c9df/6-Figure1.4-1.png"  width="500px">
</p>
<p align="center">
  <img src="https://www.frontiersin.org/files/Articles/454715/fnins-13-00504-HTML/image_m/fnins-13-00504-g001.jpg"  width="500px">
</p>

## Usefull Resources:
+ https://www.ai.rug.nl/~mwiering/thesis_kok.pdf
+ https://stackoverflow.com/questions/28326776/liquid-state-machine-how-it-works-and-how-to-use-it
+ https://arxiv.org/ftp/arxiv/papers/1910/1910.03354.pdf
+ https://igi-web.tugraz.at/PDF/189.pdf
+ https://www.osti.gov/servlets/purl/1405258
+ https://github.com/IGITUGraz/LSM