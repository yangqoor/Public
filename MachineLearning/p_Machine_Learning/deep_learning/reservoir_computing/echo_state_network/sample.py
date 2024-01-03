import numpy as np
from matplotlib import pyplot as plt

random_state = np.random.RandomState(42)

# data sin wave generator
def generate_data(N, min_period, max_period, n_changepoints, traintest_cutoff):
    """
    returns a random step function with N changepoints
    and a sin wave signal that changes its frequency at
    aech such step, in the limits given by min_ and max_period.
    """
    # vector of random indices < N, padded with 0 and N at the ends:
    changepoints = np.insert(np.sort(random_state.randint(0, N,n_changepoints)), [0, n_changepoints], [0, N])
    # list of interval boundaries between which the control sequence should be constant:
    const_intervals = list(zip(changepoints, np.roll(changepoints, -1)))[:-1]

    # populate a control sequence
    frequency_control = np.zeros((N, 1))
    for (t0, t1) in const_intervals:
        frequency_control[t0:t1] = random_state.rand()
    periods = frequency_control * (max_period - min_period) + max_period

    # run time through a sine, while changing the period length
    frequency_output = np.zeros((N, 1))
    z = 0
    for i in range(N):
        z = z + 2 * np.pi / periods[i]
        frequency_output[i] = (np.sin(z) + 1) / 2

    X = np.hstack([np.ones((N, 1)), 1-frequency_control])
    y = frequency_output
    return (X[:traintest_cutoff], y[:traintest_cutoff]), (X[traintest_cutoff:], y[traintest_cutoff:])

class ESN():
    def __init__(self, 
        n_inputs, 
        n_outputs, 
        n_reservoir, 
        spectral_radius, 
        sparsity, 
        noise, 
        input_shift=[0, 0], 
        input_scaling=[0.01, 3], 
        teacher_shift=-0.7, 
        teacher_scaling=1.12
    ):
        self.n_inputs = n_inputs
        self.n_outputs = n_outputs
        self.n_reservoir = n_reservoir
        self.spectral_radius = spectral_radius
        self.sparsity = sparsity
        self.noise = noise
        self.input_shift = input_shift
        self.input_scaling = input_scaling
        self.teacher_shift = teacher_shift
        self.teacher_scaling = teacher_scaling

        # Initialize
        self.activation = np.tanh
        self.activation_gradient = np.arctanh
        self.init_weights()


    def init_weights(self):
        # initialize recurrent weights:
        # begin with a random matrix centered around zero:
        W = random_state.rand(self.n_reservoir, self.n_reservoir) - 0.5

        # delete the fraction of connections given by (self.sparsity):
        W[random_state.rand(*W.shape) < self.sparsity] = 0
        
        # compute the spectral radius of these weights:
        radius = np.max(np.abs(np.linalg.eigvals(W)))
        
        # rescale them to reach the requested spectral radius:
        self.W = W * (self.spectral_radius / radius)

        # random input weights:
        self.W_in = random_state.rand(self.n_reservoir, self.n_inputs) * 2 - 1
        
        # random feedback (teacher forcing) weights:
        self.W_feedb = random_state.rand(self.n_reservoir, self.n_outputs) * 2 - 1

    def _update_step(self, state, input_pattern, output_pattern):
        """
        performs one update step.
        i.e., computes the next network state by applying the recurrent weights
        to the last state & and feeding in the current input and output patterns
        """
        wsum = np.dot(self.W, state)
        wsum += np.dot(self.W_in, input_pattern) 
        wsum += np.dot(self.W_feedb, output_pattern)

        return (np.tanh(wsum) + self.noise * (random_state.rand(self.n_reservoir) - 0.5))

    def _scale_inputs(self, inputs):
        """
        for each input dimension j: multiplies by the j'th entry in the
        input_scaling argument, then adds the j'th entry of the input_shift
        argument.
        """
        inputs = np.dot(inputs, np.diag(self.input_scaling))
        inputs = inputs + self.input_shift

        return inputs

    def _scale_teacher(self, teacher):
        """
        multiplies the teacher/target signal by the teacher_scaling argument,
        then adds the teacher_shift argument to it.
        """
        
        teacher = teacher * self.teacher_scaling
        teacher = teacher + self.teacher_shift
        return teacher

    def _unscale_teacher(self, teacher_scaled):
        """
        inverse operation of the _scale_teacher method.
        """

        teacher_scaled = teacher_scaled - self.teacher_shift
        teacher_scaled = teacher_scaled / self.teacher_scaling
        return teacher_scaled

    def fit(self, inputs, outputs):
        """
        Collect the network's reaction to training data, train readout weights.
        Args:
            inputs: array of dimensions (N_training_samples x n_inputs)
            outputs: array of dimension (N_training_samples x n_outputs)
            inspect: show a visualisation of the collected reservoir states
        Returns:
            the network's output on the training data, using the trained weights
        """

        # transform input and teacher signal:
        inputs_scaled = self._scale_inputs(inputs)
        teachers_scaled = self._scale_teacher(outputs)

        # step the reservoir through the given input,output pairs:
        states = np.zeros((inputs.shape[0], self.n_reservoir))
        for n in range(1, inputs.shape[0]):
            states[n, :] = self._update_step(states[n - 1], inputs_scaled[n, :], teachers_scaled[n - 1, :])

        # we'll disregard the first few states:
        transient = min(int(inputs.shape[1] / 10), 100)
        
        # include the raw inputs:
        extended_states = np.hstack((states, inputs_scaled))

        # Solve for W_out:
        self.W_out = np.dot(
            np.linalg.pinv(
                extended_states[transient:, :]), 
                self.activation_gradient(teachers_scaled[transient:, :]
            )
        ).T

        # remember the last state for later:
        self.laststate = states[-1, :]
        self.lastinput = inputs[-1, :]
        self.lastoutput = teachers_scaled[-1, :]

        # apply learned weights to the collected states:
        pred_train = self._unscale_teacher(self.activation(
            np.dot(extended_states, self.W_out.T)))
            
        
        print(np.sqrt(np.mean((pred_train - outputs)**2)))
        return pred_train

    def predict(self, inputs, continuation=True):
        """
        Apply the learned weights to the network's reactions to new input.
        Args:
            inputs: array of dimensions (N_test_samples x n_inputs)
            continuation: if True, start the network from the last training state
        Returns:
            Array of output activations
        """
        if inputs.ndim < 2:
            inputs = np.reshape(inputs, (len(inputs), -1))
        n_samples = inputs.shape[0]

        if continuation:
            laststate = self.laststate
            lastinput = self.lastinput
            lastoutput = self.lastoutput
        else:
            laststate = np.zeros(self.n_reservoir)
            lastinput = np.zeros(self.n_inputs)
            lastoutput = np.zeros(self.n_outputs)

        inputs = np.vstack([lastinput, self._scale_inputs(inputs)])
        states = np.vstack([laststate, np.zeros((n_samples, self.n_reservoir))])
        outputs = np.vstack([lastoutput, np.zeros((n_samples, self.n_outputs))])

        for n in range(n_samples):
            states[n + 1, :] = self._update_step(states[n, :], inputs[n + 1, :], outputs[n, :])
            outputs[n + 1, :] = self.activation(np.dot(self.W_out, np.concatenate([states[n + 1, :], inputs[n + 1, :]])))

        return self._unscale_teacher(self.activation(outputs[1:]))


if __name__ == "__main__":
    N = 15000
    min_period = 2
    max_period = 10
    n_changepoints = int(N/200)
    traintest_cutoff = int(np.ceil(0.7*N))

    (X_train, Y_train), (X_test, Y_test) = generate_data(N, min_period, max_period, n_changepoints, traintest_cutoff)

    # define network
    esn = ESN(n_inputs=2, n_outputs=1, n_reservoir=200, spectral_radius=0.25, sparsity=0.95, noise=0.001)

    # train network
    pred_train = esn.fit(X_train, Y_train)
    pred_test = esn.fit(X_test, Y_test)

    loss = np.sqrt(np.mean((pred_test - Y_test) ** 2))
    print(f"test error: {loss}")

    # plots
    window_tr = range(int(len(Y_train) / 4), int(len(Y_train)/4+2000))
    plt.figure(figsize=(10, 1.5))
    plt.plot(X_train[window_tr, 1], label="control", color="blue")
    plt.plot(Y_train[window_tr], label="target", color="green")
    plt.plot(pred_train[window_tr], label="model", color="red")
    plt.legend(fontsize="x-small")
    plt.title("training (expect)")
    plt.ylim([-0.1, 1.1])

    window_test = range(2000)
    plt.figure(figsize=(10, 1.5))
    plt.plot(X_test[window_test, 1], label="control", color="blue")
    plt.plot(Y_test[window_test], label="target", color="green")
    plt.plot(pred_test[window_test], label="model", color="red")
    plt.legend(fontsize="x-small")
    plt.title("test (expect)")
    plt.ylim([-0.1, 1.1])

    plt.show()
