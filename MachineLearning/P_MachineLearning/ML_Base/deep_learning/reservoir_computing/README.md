# Reservoir Computing (RC)
`Reservoir computing` is a framework for computation derived from recurrent neural network theory that maps input signals into higher dimensional computational spaces through the dynamics of a fixed, non-linear system called a reservoir. After the input signal is fed into the reservoir, which is treated as a "black box," a simple readout mechanism is trained to read the state of the reservoir and map it to the desired output. The first key benefit of this framework is that training is performed only at the readout stage, as the reservoir dynamics are fixed. The second is that the computational power of naturally available systems, both classical and quantum mechanical, can be utilized to reduce the effective computational cost.

The subsets of `Reservoir Computing`:  
- [`Echo State Network`](./echo_state_network/README.md)
- [`Extreme Learning Machine`](./extreme_learning_machine/README.md)
- [`Liquid State Machine`](./liquid_state_machine/README.md)

<p align="center">
  <img src="https://www.researchgate.net/publication/334644684/figure/fig1/AS:784034976235520@1563939913442/A-schematic-of-reservoir-computing.png" width="500px">
</p>
<p align="center">
  <img src="https://www.researchgate.net/publication/326730917/figure/fig1/AS:654638390992896@1533089363692/Reservoir-computing-and-temporal-trajectories-A-Brain-data-are-provided-to-a.png" width="500px">
</p>

## Usefull Resources:
+ https://en.wikipedia.org/wiki/Reservoir_computing
+ https://www.youtube.com/watch?v=HfltqZa2Fco
+ https://www.youtube.com/watch?v=1bWjyQ1326g
