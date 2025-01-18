# Double Deep Q-Learning (DDQN)
[`Deep Q-Learning`](../deep_q_learning/README.md) since Q-learning involves learning estimates from estimates, such overestimation can be problematic. 
The solution involves using two separate Q-value estimators, each of which is used to update the other. Using these independent estimators, we can unbiased Q-value estimates of the actions selected using the opposite estimator. We can thus avoid maximization bias by disentangling our updates from biased estimates.

Therefore `Double Deep Q-Learning` is been invented to fix this issue.

## Code
[`python sample_keras.py`](./sample_keras.py)
<p align="center">
  <img src="https://www.researchgate.net/profile/Xianfu-Chen-2/publication/325194373/figure/fig2/AS:627197786218496@1526547013060/Double-deep-Q-network-DQN-based-reinforcement-learning-DARLING-for-stochastic.png" width="500px">
</p>
<p align="center">
  <img src="https://github.com/chinancheng/DDQN.pytorch/raw/master/assets/DDQN-algo.png" width="750">
</p>

## Usefull Resources:
+ https://medium.com/@qempsil0914/deep-q-learning-part2-double-deep-q-network-double-dqn-b8fc9212bbb2
+ https://ai.stackexchange.com/questions/21515/is-there-any-good-reference-for-double-deep-q-learning
+ https://unnatsingh.medium.com/deep-q-network-with-pytorch-d1ca6f40bfda
+ https://aamrani1999.medium.com/double-deep-q-networks-f6cf5b1b249
+ https://towardsdatascience.com/double-deep-q-networks-905dd8325412
+ https://github.com/chinancheng/DDQN.pytorch
+ https://github.com/germain-hug/Deep-RL-Keras