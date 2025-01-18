from tensorflow.keras.layers import Dense, Activation
from tensorflow.keras.models import Sequential
from tensorflow.keras.optimizers import Adam
import numpy as np
import gym

class ReplayBuffer(object):
    def __init__(self, max_size, input_shape, n_actions, discrete=False):
        self.mem_size = max_size
        self.mem_cntr = 0
        self.discrete = discrete
        self.state_memory = np.zeros((self.mem_size, input_shape))
        self.new_state_memory = np.zeros((self.mem_size, input_shape))
        dtype = np.int8 if self.discrete else np.float32
        self.action_memory = np.zeros((self.mem_size, n_actions), dtype=dtype)
        self.reward_memory = np.zeros(self.mem_size)
        self.terminal_memory = np.zeros(self.mem_size, dtype=np.float32)

    def store_transition(self, state, action, reward, state_, done):
        index = self.mem_size % self.mem_size
        self.state_memory[index] = state
        self.new_state_memory[index] = state_

        if self.discrete:
            actions = np.zeros(self.action_memory.shape[1])
            actions[action] = 1.0
            self.action_memory[index] = actions
        else:
            self.action_memory[index] = action
        
        self.reward_memory[index] = reward
        self.terminal_memory[index] = 1 - int(done)
        self.mem_cntr += 1
    
    def sample_buffer(self, batch_size):
        max_mem = min(self.mem_cntr, self.mem_size)
        batch = np.random.choice(max_mem, batch_size)
        states = self.state_memory[batch]
        new_states = self.new_state_memory[batch]
        actions = self.action_memory[batch]
        rewards = self.reward_memory[batch]
        terminal = self.terminal_memory[batch]

        return states, actions, rewards, new_states, terminal
    
class DDQNAgent(object):
    def __init__(self, alpha, gamma, n_actions, epsilon, batch_size, input_dims, epsilon_dec=0.996, epsilon_end=0.01, mem_size=1000000, fname="ddqn_model.h5", replace_target=100):
        self.n_actions = n_actions
        self.action_space = [i for i in range(self.n_actions)]
        self.gamma = gamma
        
        self.epsilon = epsilon
        self.epsilon_dec = epsilon_dec
        self.epsilon_min = epsilon_end
        
        self.batch_size = batch_size
        self.model = fname
        self.replace_target = replace_target

        self.memory = ReplayBuffer(mem_size, input_dims, n_actions, True)
        self.q_eval = build_dqn(alpha, n_actions, input_dims, 256, 256)
        self.q_target = build_dqn(alpha, n_actions, input_dims, 256, 256)

    def remember(self, state, action, reward, new_state, done):
        self.memory.store_transition(state,  action, reward, new_state, done)

    def get_action(self, state):
        state = state[np.newaxis, :]
        rand = np.random.random()

        if rand < self.epsilon:
            action = np.random.choice(self.action_space)
        else:
            actions = self.q_eval.predict(state)
            action = np.argmax(actions)
        
        return action

    def learn(self):
        if self.memory.mem_cntr > self.batch_size:
            # get stored data
            state, action, reward, new_state, done = self.memory.sample_buffer(self.batch_size)
            action_values = np.array(self.action_space, dtype=np.int8)
            action_indices = np.dot(action, action_values)

            # forward
            q_next = self.q_target.predict(new_state)
            q_eval = self.q_eval.predict(new_state)
            q_pred = self.q_eval.predict(state)

            max_actions = np.argmax(q_eval, axis=1)
            q_target = q_pred

            # update stored data
            batch_index = np.arange(self.batch_size, dtype=np.int32)
            q_target[batch_index, action_indices] = reward + self.gamma * q_next[batch_index, max_actions.astype(int)] * done

            # backward
            _ = self.q_eval.fit(state, q_target, verbose=0)
            if self.memory.mem_cntr % self.replace_target == 0:
                self.q_target.set_weights(self.q_eval.get_weights())

            # update randomness
            self.epsilon = self.epsilon * self.epsilon_dec if self.epsilon > self.epsilon_min else self.epsilon_min

def build_dqn(lr, n_actions, input_dims, fc1_dims, fc2_dims):
    model = Sequential([
        Dense(fc1_dims, input_shape=(input_dims, )),
        Activation("relu"),
        Dense(fc2_dims),
        Activation("relu"),
        Dense(n_actions)
    ])

    model.compile(optimizer=Adam(lr=lr), loss="mse")
    return model

if __name__ == '__main__':
    env = gym.make("LunarLander-v2")
    ddqn_agent = DDQNAgent(alpha=0.0005, gamma=0.99, n_actions=4, epsilon=1.0, batch_size=64, input_dims=8)

    n_games = 500

    for i in range(n_games):
        done = False
        rewards = 0
        state = env.reset()

        while not done:
            action = ddqn_agent.get_action(state)
            next_state, reward, done, info = env.step(action)
            rewards += reward

            ddqn_agent.remember(state, action, reward, next_state, done)
            state = next_state

            ddqn_agent.learn()

            if i % 100 == 0:
                env.render()
        
        print(f"[{i}/{n_games}] rewarded:{rewards}")
