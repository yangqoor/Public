import gym 
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

# Configuration parameters for the whole setup
seed = 42
gamma = 0.99
max_steps_per_episode = 10000
env = gym.make("CartPole-v0")
env.seed(seed)
eps = np.finfo(np.float32).eps.item()

num_inputs = 4
num_actions = 2
num_hidden = 128

inputs = layers.Input(shape=(num_inputs,))
common = layers.Dense(num_hidden, activation="relu")(inputs)
action = layers.Dense(num_actions, activation="softmax")(common)
critic = layers.Dense(1)(common)

model = keras.Model(inputs=inputs, outputs=[action, critic])
optimizer = keras.optimizers.Adam(learning_rate=0.01)
huber_loss = keras.losses.Huber()
action_probs_history = []
critic_value_history = []
rewards_history = []
running_reward = 0
episode_count = 0

# train
while True:
    state = env.reset()
    episode_reward = 0
    with tf.GradientTape() as tape:
        # forward
        for timestep in range(1, max_steps_per_episode):
            # of the agent in a pop up window
            state = tf.convert_to_tensor(state)
            state = tf.expand_dims(state, 0)

            # Predict action probabilities and estimated, 
            # future rewards from enviroment state.
            action_probs, critic_value = model(state)
            critic_value_history.append(critic_value[0, 0])

            # Sample action from action probability distribution
            action = np.random.choice(num_actions, p=np.squeeze(action_probs))
            action_probs_history.append(tf.math.log(action_probs[0, action]))

            # Apply the sampled action in out enviroment
            state, reward, done, _ = env.step(action)
            rewards_history.append(reward)
            episode_reward += reward

            # threshold for exit
            if done:
                break

        # update runningreward to check condition for solving 
        running_reward = 0.05 * episode_reward + (1 - 0.05) * running_reward

        # Calculate expected value from scratch
        # - At each timestep what was the total reward received after that timestep
        # - Rewards in the past are discounted by multiplying them with gamma
        # - These are the labels for our critic 
        returns = []
        discounted_sum = 0
        for r in rewards_history[::-1]:
            discounted_sum = r + gamma * discounted_sum
            returns.insert(0, discounted_sum)

        # Normalize
        returns = np.array(returns)
        returns = (returns - np.mean(returns)) / (np.std(returns) + eps)
        returns = returns.tolist()

        # calculating loss values to update our network
        history = zip(action_probs_history, critic_value_history, returns)
        actor_losses = []
        critic_losses = []
        for log_prop, value, ret in history:
            # At this point in history, the critic estimated that we would get a total_reward = "value" in the future.
            # We took an action with log probability of the 'log_prob' and ended up receiving a total reward = "ret".
            # The actor must be updated so that it predicts and action thta leads to high rewards (compared to critic's estimate) with high probability.
            diff = ret - value
            actor_losses.append(-log_prop * diff)

            # critic must be updated so that it predicts 
            # a better estimate of the future rewards.
            critic_losses.append(
                huber_loss(tf.expand_dims(value, 0), tf.expand_dims(ret, 0))
            )

        # Backpropagation
        loss_value = sum(actor_losses) + sum(critic_losses)
        grads = tape.gradient(loss_value, model.trainable_variables)
        optimizer.apply_gradients(zip(grads, model.trainable_variables))

        # Clear the loss and reward history
        action_probs_history.clear()
        critic_value_history.clear()
        rewards_history.clear()

    # Log details
    episode_count += 1
    if episode_count % 10 == 0:
        print(f"running reward: {running_reward} at episode {episode_count}")

    if running_reward > 190:# Condition to consider the task solved
        print(f"Solved at episode {episode_count}!")
        break


#  end result
while True:
    # Adding this line would show the attempts
    env.render()

    # of the agent in a pop up window
    state = tf.convert_to_tensor(state)
    state = tf.expand_dims(state, 0)

    # Predict action probabilities and estimated future rewards
    action_probs, _ = model(state)

    # Sample action from action probability distribution
    action = np.random.choice(num_actions, p=np.squeeze(action_probs))

    # Apply the sampled action in out enviroment
    state, reward, done, _ = env.step(action)








