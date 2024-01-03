# Restricted Boltzmann Machine(RBM)
`Restricted Boltzmann Machines`, or `RBMs`, are two-layer generative neural networks that learn a probability distribution over the inputs. They are a special class of Boltzmann Machine in that they have a restricted number of connections between visible and hidden units. Every node in the visible layer is connected to every node in the hidden layer, but no nodes in the same group are connected. RBMs are usually trained using the contrastive divergence learning procedure.

How are Boltzmann Machines used?
Boltzmann machines solve two separate but crucial deep learning problems:

`Search queries:` The weighting on each layer’s connections are fixed and represent some form of a cost function. The Boltzmann machine’s stochastic rules allow it to sample any binary state vectors that have the lowest cost function values.

`Training problems:` Given a set of binary data vectors, the machine must learn to predict the output vectors with high probability. The first step is to determine which layer connection weights have the lowest cost function values, relative to all the other possible binary vectors. The Boltzmann technique accomplishes this by continuously updating its own weights as each feature is processed, instead of treating the weights as a fixed value.

How ever for this problem we are using nowadays `Auto Encoders` that will fix this problems better in a shorter period of time.  
The reason i mentioned this stucture is to get the gasph around it, maybe in the future been used for solving problems with this unique structure.

# Code 
[`python3 sample_scratch.py`](./sample_scratch.py)  
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
<!-- [`python3 sample_keras.py`](./sample_keras.py) -->

<p align="center">
  <img src="https://lh4.googleusercontent.com/3dzBOOhDdpxw4EPbt9viT-A8ONmqgrqF61pJs6M7Jpn-LIQUDalZ4vpYg0e9XpPlB6y78H40Ws9NSdxCdpRdb9m3mY1t_FxcnQrEodGzdmPjBW7C4jM0Oz6GeI48Jz_dqQJwr7h_SlVr14VPTw"  width="500px">
</p>
<p align="center">
  <img src="https://lh5.googleusercontent.com/hRFe-gV4V461pDGPJ8_oamG6YqgDJRL7Q1nBvaP4dM3kQxLj72bl3vyMr_feqFPpjOpARHX3jnJLWyP6KFTMNCZDrvvE_wBuK1KoMqRqqbbb34CySo3Kd78ERbJoGukYBUNy4so2tQlqypEnyQ"  width="500px">
</p>
<p align="center">
  <img src="https://ars.els-cdn.com/content/image/1-s2.0-S1053811914002080-gr2.jpg"  width="500px">
</p>

## Usefull Resources:
+ https://blog.paperspace.com/beginners-guide-to-boltzmann-machines-pytorch/
+ https://github.com/GabrielBianconi
+ https://towardsdatascience.com/restricted-boltzmann-machine-as-a-recommendation-system-for-movie-review-part-2-9a6cab91d85b (use incognito)
+ https://christian-igel.github.io/paper/TRBMAI.pdf
+ https://www.cs.toronto.edu/~hinton/absps/guideTR.pdf
+ https://www.youtube.com/watch?v=3Cp_pjPRmt8
+ https://deepai.org/machine-learning-glossary-and-terms/boltzmann-machine
+ https://en.wikipedia.org/wiki/Boltzmann_machine  
+ https://www.mygreatlearning.com/blog/understanding-boltzmann-machines/  
+ https://adityashrm21.github.io/Restricted-Boltzmann-Machines/
+ https://www.youtube.com/watch?v=Fkw0_aAtwIw
+ https://www.csrc.ac.cn/upload/file/20170703/1499052743888438.pdf
+ https://www.kaggle.com/residentmario/restricted-boltzmann-machines-and-pretraining?select=train.csv
+ https://github.com/HismaelOliveira/RBM
+ https://www.edureka.co/blog/restricted-boltzmann-machine-tutorial/