# Radial Basis Network(RBF)
`Radial basis function (RBF)` networks are a commonly used type of artificial neural network for function approximation problems. Radial basis function networks are distinguished from other neural networks due to their universal approximation and faster learning speed. A brief description of the `RBF` network is presented as follows. The training of the RBF model is terminated once the calculated error reached the desired values (i.e. 0.01) or number of training iterations (i.e. 500) already was completed. An RBF network with a specific number of nodes (i.e. 10) in its hidden layer is chosen. A Gaussian function is used as the transfer function in computational units. Depending on the case, it is typically observed that the `RBF` network required less time to reach the end of training compared to `MLP`. These chosen MLP and RBF networks are later examined in the next chapters under new test conditions. The agreement between the model predictions and the experimental observations will be investigated and the results of the two models will be compared. The final model is then chosen based on the least computed error.

## code 
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
[`python3 sample_sklearn.py`](./sample_sklearn.py)  
[`python3 sample_scratch.py`](./sample_scratch.py)  

<p align="center">
  <img src="https://miro.medium.com/max/4148/1*kf0_Gafc-PbrHO88iOZVJA.png" width="500">
  <img src="https://www.researchgate.net/publication/333469185/figure/fig2/AS:764122706763776@1559192458216/Architecture-of-the-RBF-neural-network-RBF-radial-basis-function.ppm" width="500">
</p>

## Usefull Resources:
+ https://towardsdatascience.com/radial-basis-functions-neural-networks-all-we-need-to-know-9a88cc053448 (readable in incognito mode)
+ https://mccormickml.com/2013/08/15/radial-basis-function-network-rbfn-tutorial/  
+ https://github.com/oarriaga/RBF-Network  
+ https://scikit-learn.org/stable/auto_examples/gaussian_process/plot_gpr_noisy_targets.html  
+ https://en.wikipedia.org/wiki/Radial_basis_function_network  
+ https://github.com/MNoumanAbbasi/RBF-Network-Handwritten-Digits  
+ https://www.dtreg.com/solution/rbf-neural-networks