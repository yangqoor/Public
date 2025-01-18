# usefull: https://github.com/PacktPublishing/Advanced-Deep-Learning-with-Keras/blob/master/chapter9-drl/dqn-cartpole-9.6.1.py

import gym, time, random
import numpy as np
import tensorflow as tf
from collections import deque

from tensorflow import keras
from tensorflow.keras.initializers import HeUniform
from tensorflow.keras.layers import Dense
from tensorflow.keras.losses import Huber
from tensorflow.keras.optimizers import Adam

env = gym.make('CartPole-v1')
env.seed(5)
np.random.seed(5)
tf.random.set_seed(5)

DISCOUNT = 0.618
MIN_REPLAY_SIZE = 1000
BATCH_SIZE = 64 * 2

print("Action Space: {}".format(env.action_space))
print("State space: {}".format(env.observation_space))

# An episode a full game
episodes = 300
test_episodes = 100

def agent(state_shape, action_shape, learning_rate = 0.001):
    """ The agent maps X-states to Y-actions
    e.g. The neural network output is [.1, .7, .1, .3]
    The highest value 0.7 is the Q-Value.
    The index of the highest action (0.7) is action #1.
    """
    
    model = keras.Sequential()
    model.add(Dense(24, input_shape=state_shape, activation='relu', kernel_initializer=HeUniform()))
    model.add(Dense(12, activation='relu', kernel_initializer=HeUniform()))
    model.add(Dense(action_shape, activation='linear', kernel_initializer=HeUniform()))
    model.compile(loss=Huber(), optimizer=Adam(lr=learning_rate), metrics=['accuracy'])
    
    return model

def train(env, replay_memory, model, target_model, done, learning_rate=0.7):
    if len(replay_memory) < MIN_REPLAY_SIZE:
        return

    mini_batch = random.sample(replay_memory, BATCH_SIZE)

    current_states = np.array([encode_observation(transition[0], env.observation_space.shape) for transition in mini_batch])
    current_qs_list = model.predict(current_states)
    
    new_current_states = np.array([encode_observation(transition[3], env.observation_space.shape) for transition in mini_batch])
    future_qtable = target_model.predict(new_current_states)

    X, Y = [], []
    for index, (observation, action, reward, new_observation, done) in enumerate(mini_batch):
        if not done:
            max_future_q = reward + DISCOUNT * np.max(future_qtable[index])
        else:
            max_future_q = reward

        current_qs = current_qs_list[index]
        current_qs[action] = (1 - learning_rate) * current_qs[action] + learning_rate * max_future_q

        X.append(encode_observation(observation, env.observation_space.shape))
        Y.append(current_qs)
    model.fit(np.array(X), np.array(Y), batch_size=BATCH_SIZE, verbose=0, shuffle=True)

def encode_observation(observation, n_dims):
    return observation

if __name__ == '__main__':
    
    epsilon = 1 # Epsilon-greedy algorithm in initialized at 1 meaning every step is random at the start
    max_epsilon = 1 # You can't explore more than 100% of the time
    min_epsilon = 0.01 # At a minimum, we'll always explore 1% of the time
    decay = 0.01

    # 1. Initialize the Target and Main models
    # Main Model (updated every 4 steps)
    model = agent(env.observation_space.shape, env.action_space.n)
    # Target Model (updated every 100 steps)
    target_model = agent(env.observation_space.shape, env.action_space.n)
    target_model.set_weights(model.get_weights())

    replay_memory = deque(maxlen=50_000)

    target_update_counter = 0

    # X = states, y = actions
    X = []
    y = []

    train_threshold = 0

    for episode in range(episodes):
        observation = env.reset()
        rewards = 0
        done = False
        while not done:
            train_threshold += 1
            if True:
                env.render()

            random_number = np.random.rand()
            # 2. Explore using the Epsilon Greedy Exploration Strategy
            if random_number <= epsilon:
                # Explore
                action = env.action_space.sample()
            else:
                # Exploit best known action
                # model dims are (batch, env.observation_space.n)
                encoded = encode_observation(observation, env.observation_space.shape[0])
                encoded_reshaped = encoded.reshape([1, encoded.shape[0]])
                predicted = model.predict(encoded_reshaped).flatten()
                action = np.argmax(predicted)

            new_observation, reward, done, info = env.step(action)
            replay_memory.append([observation, action, reward, new_observation, done])

            # 3. Update the Main Network using the Bellman Equation
            if train_threshold % 4 == 0 or done:
                train(env, replay_memory, model, target_model, done)

            observation = new_observation
            rewards += reward

            if done:
                print(f"[{episode}/{episodes}] rewarded: {rewards}")
                rewards += 1

                if train_threshold >= 100:
                    print('Copying main network weights to the target network weights')
                    target_model.set_weights(model.get_weights())
                    train_threshold = 0
                break

        epsilon = min_epsilon + (max_epsilon - min_epsilon) * np.exp(-decay * episode)
    env.close()



