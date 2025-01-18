# Long Short Term Memory (LSTM)
[`Long Short Term Memory(LSTM)`](https://colah.github.io/posts/2015-08-Understanding-LSTMs/) networks are a special kind of `RNN`.  
Capable of learning long-term dependencies. Designed to avoid the long-term dependency problem. Remembering information for long periods of time is practically their default behavior. `LSTM` have this chain like structure(see 3th image), but the repeating module has a different structure. Instead of having a single neural network layer, there are four, interacting in a very special way, that makes the different from [`vanilla RNN`](../Recurrent_Neural_Network(RNN)/README.md).  

## code 
[`python3 sample_keras.py`](./sample_keras.py)  
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
<!-- [`python3 sample_scratch.py`](./sample_scratch.py)   -->

<p align="center">
  <img src="https://hackernoon.com/hn-images/1*g4jsLedfzsSFtuqVCfQXsw.png" width="750">
</p>
<p align="center">
  <img src="https://datascience-enthusiast.com/figures/LSTM.png" width="750">
</p>
<p align="center">
  <img src="https://github.com/navjindervirdee/neural-networks/blob/master/Recurrent%20Neural%20Network/LSTM.JPG?raw=true" width="750">
</p>

## Usefull Resources:
+ https://colah.github.io/posts/2015-08-Understanding-LSTMs/  
+ https://keras.io/examples/generative/lstm_character_level_text_generation/
+ https://medium.com/mlreview/understanding-lstm-and-its-diagrams-37e2f46f1714   
+ https://github.com/nicklashansen/rnn_lstm_from_scratch/blob/master/RNN_LSTM_from_scratch.ipynb  
+ https://github.com/jaungiers/LSTM-Neural-Network-for-Time-Series-Prediction  
+ https://www.altumintelligence.com/articles/a/Time-Series-Prediction-Using-LSTM-Deep-Neural-Networks  
+ https://towardsdatascience.com/illustrated-guide-to-lstms-and-gru-s-a-step-by-step-explanation-44e9eb85bf21  
+ https://aditi-mittal.medium.com/understanding-rnn-and-lstm-f7cdf6dfc14e  
+ https://ahmetozlu93.medium.com/long-short-term-memory-lstm-networks-in-a-nutshell-363cd470ccac  
+ https://purnasaigudikandula.medium.com/recurrent-neural-networks-and-lstm-explained-7f51c7f6bbb9  