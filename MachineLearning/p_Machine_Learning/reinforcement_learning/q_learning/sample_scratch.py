import numpy as np
import gym

env = gym.make("MountainCar-v0")
env.reset()

########## Params #########
learning_rate = 0.10
epsilon = 0.25
discount = 0.95
episodes = 25000
verbose = 500
###########################

decaying_threshold = episodes // 2
q_table = np.random.uniform(low=-1, high=1, size=([20, 20, env.action_space.n]))

def get_discrete_state(state):
    size = (env.observation_space.high - env.observation_space.low) / [20, 20]
    discrete_state = (state - env.observation_space.low) / size
    return tuple(discrete_state.astype(np.int))

for episode in range(episodes):
    discrete_state = get_discrete_state(env.reset())
    total_reward = 0
    done = False
    
    # keep logs 
    if episode % verbose == 0: 
        print()

    # prediction
    while not done:
        if np.random.random() > epsilon:
            action = np.argmax(q_table[discrete_state])
        else:
            action = np.random.randint(0, env.action_space.n)

        q_position = (discrete_state + (action,))
        new_state, reward, done, info = env.step(action)

        # update parameters
        discrete_state = get_discrete_state(new_state)
        total_reward += reward

        # visualization
        if episode % verbose == 0: 
            print(f"\r[{episode}/{episodes}] total_reward = {total_reward}", end="")
            env.render()

        # learn / finished
        if not done:
            current_q = q_table[q_position]
            future_q = np.max(q_table[discrete_state])
            new_q = (1 - learning_rate) * current_q + learning_rate * (reward + discount * future_q)
            q_table[q_position] = new_q

        elif new_state[0] >= env.goal_position:
            q_table[q_position] = 0

    if decaying_threshold >= episode:
        epsilon -= (epsilon / decaying_threshold)

env.close()

"""
NOTE:

Each timestep the reward will be decrease by 1, and we start on 0.
Maximum amount it could take is -200 rewards than the game will be canceled.
When the object catch the flag the game will be canceled.
"""