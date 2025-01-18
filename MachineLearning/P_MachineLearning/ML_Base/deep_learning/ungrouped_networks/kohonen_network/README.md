# Kohonen Network(KN)
The objective of a `Kohonen network` is to map input vectors (patterns) of arbitrary dimension N onto a discrete map with 1 or 2 dimensions. Patterns close to one another in the input space should be close to one another in the map: they should be topologically ordered. A Kohonen network is composed of a grid of output units and N input units. The input pattern is fed to each output unit. The input lines to each output unit are weighted. These weights are initialised to small random numbers.

In all the forms of learning we have met so far the answer that the network is supposed to give for the training examples is known. That type of learning requires a teacher who knows the correct classification for the input patterns in the training set. The objective is typically to generalise from these to other, previously unseen examples: giving more or less correct answers without intervention. In `unsupervised learning` the aim is rather different. The objective is, put most simply, to find the natural structure inherent in the input data. There are a number of `unsupervised learning` schemes, including competitive learning, adaptive resonance theory and `Self-Organising Feature Maps (SOFMs)`. A well known type of `SOFM` is a `Kohonen network`.

## code 
<!-- [`python3 sample_keras.py`](./sample_keras.py)       -->
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
<!-- [`python3 sample_scratch.py`](./sample_scratch.py)   -->

<p align="center">
  <img src="https://miro.medium.com/max/5822/1*F5_SVcLW-9AGkc6vrSwJiw.png"  width="500px">
</p>
<p align="center">
  <img src="https://lh3.googleusercontent.com/proxy/ItNjlbuGrn8lDVOAGyb5rmenYLJpmyr1CGggtatIfUmIQMQd1ajnuf09NibwpxsRS4eZNWqN3-hjl5uHcuCW_vgFnESSPJ5Yg2R_khxaU4QOTfX3"  width="500px">
</p>

## Usefull Resources:
+ http://primo.ai/index.php?title=Kohonen_Network_(KN)/Self_Organizing_Maps_(SOM)
+ https://www.youtube.com/watch?v=g8O6e9C_CfY
+ https://www.ibm.com/docs/en/spss-modeler/18.1.1?topic=models-kohonen-node
+ https://www.cs.bham.ac.uk/~jlw/sem2a2/Web/Kohonen.htm
+ https://page.mi.fu-berlin.de/rojas/neural/chapter/K15.pdf
+ https://towardsdatascience.com/kohonen-self-organizing-maps-a29040d688da (use incognito)
+ https://github.com/EklavyaFCB/EMNIST-Kohonen-SOM
+ https://codesachin.wordpress.com/2015/11/28/self-organizing-maps-with-googles-tensorflow/