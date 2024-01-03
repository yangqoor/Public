# Deep Deterministic Policy Gradient (DDPG)
`Deep Deterministic Policy Gradient (DDPG)` is a reinforcement learning technique that combines both Q-learning and Policy gradients. DDPG being an actor-critic technique consists of two models: Actor and Critic. The actor is a policy network that takes the state as input and outputs the exact action (continuous), instead of a probability distribution over actions. The critic is a Q-value network that takes in state and action as input and outputs the Q-value. DDPG is an “off”-policy method. DDPG is used in the continuous action setting and the “deterministic” in DDPG refers to the fact that the actor computes the action directly instead of a probability distribution over actions.
DDPG is used in a continuous action setting and is an improvement over the vanilla actor-critic.

## Code
[`python sample_keras.py`](./sample_keras.py)
<p align="center">
  <img src="https://www.programmersought.com/images/116/17ac5e3959ebc28908dd4b3f8e4df4dc.JPEG" width="500px">
</p>
<p align="center">
  <img src="https://miro.medium.com/max/1084/1*BVST6rlxL2csw3vxpeBS8Q.png" width="750">
</p>

## Usefull Resources:
+ https://towardsdatascience.com/deep-deterministic-policy-gradients-explained-2d94655a9b7b
+ https://spinningup.openai.com/en/latest/algorithms/ddpg.html
+ https://keras.io/examples/rl/ddpg_pendulum/
+ https://www.youtube.com/watch?v=4jh32CvwKYw&t=903s
+ https://towardsdatascience.com/deep-deterministic-policy-gradient-ddpg-theory-and-implementation-747a3010e82f