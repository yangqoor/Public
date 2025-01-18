# Recurrent Neural Network(RNN)
`Recurrent Neural Network` is a generalization of feedforward neural network that has an internal memory. `RNN` is recurrent in nature as it performs the same function for every input of data while the output of the current input depends on the past one computation. After producing the output, it is copied and sent back into the recurrent network. For making a decision, it considers the current input and the output that it has learned from the previous input.

Unlike `feedforward neural networks`, `RNNs` can use their internal state (memory) to process sequences of inputs. This makes them applicable to tasks such as unsegmented, connected handwriting recognition or speech recognition. In other neural networks, all the inputs are independent of each other. But in `RNN`, all the inputs are related to each other.

## code 
[`python3 sample_keras.py`](./sample_keras.py)  
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
[`python3 sample_scratch.py`](./sample_scratch.py)  

<p align="center">
  <img src="https://miro.medium.com/max/627/1*go8PHsPNbbV6qRiwpUQ5BQ.png" width="750">
</p>
<p align="center">
  <img src="https://miro.medium.com/max/700/1*6NpUWeBwjBWLqeq8fELvAw.jpeg" width="750">
</p>
<p align="center">
  <img src="https://miro.medium.com/max/700/1*t2Fp9tDJFh7SZBY4eV_k0g.png" width="750">
</p>

## Usefull Resources:
+ https://www.youtube.com/watch?v=6niqTuYFZLQ
+ https://victorzhou.com/blog/intro-to-rnns/
+ https://medium.com/x8-the-ai-community/building-a-recurrent-neural-network-from-scratch-f7e94251cc80
+ https://medium.com/smileinnovation/training-neural-network-with-image-sequence-an-example-with-video-as-input-c3407f7a0b0f
+ http://www.wildml.com/2015/09/recurrent-neural-networks-tutorial-part-1-introduction-to-rnns/
+ http://www.wildml.com/2015/09/recurrent-neural-networks-tutorial-part-2-implementing-a-language-model-rnn-with-python-numpy-and-theano/
+ https://github.com/buomsoo-kim/Easy-deep-learning-with-Keras/blob/master/1.%20MLP/1-Basics-of-MLP/1-1-regression.py
+ https://github.com/revsic/numpy-rnn/blob/master/RNN_numpy.ipynb
+ https://iamtrask.github.io/2015/11/15/anyone-can-code-lstm/
+ https://blog.floydhub.com/a-beginners-guide-on-recurrent-neural-networks-with-pytorch/  
+ http://www.dinalherath.com/2019/rnn/

