# Gated Recurrent Unit (GRU)
A `Gated Recurrent Unit` has two gates, a reset gate r, and an update gate z. Intuitively, the reset gate determines how to combine the new input with the previous memory, and the update gate defines how much of the previous memory to keep around. If we set the reset to all 1’s and  update gate to all 0’s we arrive at our plain RNN model.

### GRU vs LSTM
Now that you’ve seen two models  to combat the vanishing gradient problem you may be wondering: Which one to use? GRUs are quite new (2014), and their tradeoffs haven’t been fully explored yet.  According to empirical evaluations in Empirical Evaluation of Gated Recurrent Neural Networks on Sequence Modeling  and An Empirical Exploration of Recurrent Network Architectures, there isn’t a clear winner. In many tasks both architectures yield comparable performance and tuning hyperparameters like layer size is probably more important than picking the ideal architecture. GRUs have fewer parameters (U and W are smaller) and thus may train a bit faster or need less data to generalize. On the other hand, if you have enough data, the greater expressive power of LSTMs may lead to better results.

## code 
[`python3 sample_keras.py`](./sample_keras.py)  
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
<!-- [`python3 sample_scratch.py`](./sample_scratch.py)   -->

<p align="center">
  <img src="https://miro.medium.com/max/3032/1*yBXV9o5q7L_CvY7quJt3WQ.png" width="750">
</p>
<p align="center">
  <img src="https://cdn-images-1.medium.com/max/800/1*9z1Jrl8K99TorEQfsOTjpA.png" width="750">
</p>
<p align="center">
  <img src="https://miro.medium.com/max/1313/1*7oE-4Wg6bZ7u8yDf5cjJPA.png" width="750">
</p>

## Usefull Resources:
+ https://medium.com/analytics-vidhya/lstm-and-gru-a-step-further-into-the-world-of-gated-rnns-99d07dac6b91 (use incognito to open)
+ https://towardsdatascience.com/understanding-gru-networks-2ef37df6c9be
+ https://medium.com/@zeeshanmulla/lstm-gru-rnn-let-me-tell-what-to-understand-in-this-neural-network-deep-learning-5c8f78815b71  
+ https://d2l.ai/chapter_recurrent-modern/gru.html
+ http://www.wildml.com/2015/10/recurrent-neural-network-tutorial-part-4-implementing-a-grulstm-rnn-with-python-and-theano/
+ https://www.analyticsvidhya.com/blog/2021/03/introduction-to-gated-recurrent-unit-gru/
+ https://analyticsindiamag.com/gated-recurrent-unit-what-is-it-and-how-to-learn/