# Actor Critic Methods
The principal idea is to split the model in two: one for computing an action based on a state and another one to produce the Q values of the action.

The actor takes as input the state and outputs the best action. It essentially controls how the agent behaves by learning the optimal policy (policy-based). The critic, on the other hand, evaluates the action by computing the value function (value based). Those two models participate in a game where they both get better in their own role as the time passes. The result is that the overall architecture will learn to play the game more efficiently than the two methods separately.

## Code
[`python sample.py`](./sample.py)
<p align="center">
  <img src="https://theaisummer.com/static/a4620c153553ad622c5dbae389367c90/8608d/ac.jpg" width="500px">
</p>

## Usefull Resources:
+ https://towardsdatascience.com/understanding-actor-critic-methods-931b97b6df3f
+ https://www.youtube.com/watch?v=LawaN3BdI00
+ https://theaisummer.com/Actor_critics/