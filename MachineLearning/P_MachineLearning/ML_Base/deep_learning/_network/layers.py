# sample code update Network to his own file (import)
import numpy as np
from copy import copy
from terminaltables import AsciiTable

# functions
from algorithms.activation_functions import act_functions 
from algorithms.loss_functions import loss_functions 
from algorithms.optimizer_functions import opt_functions

# Thanks to: based a lot on the source code
# sys.path.insert(1, "D:\Programming\learn\AI\sample\ML-From-Scratch") 
# from mlfromscratch.deep_learning.optimizers import Adam
# from mlfromscratch.deep_learning.loss_functions import CrossEntropy, SquareLoss
# from mlfromscratch.deep_learning import NeuralNetwork

# import or in Layer class
def default_weights(shape, static, limit=1):
    n_features = shape[0]
    n_units  = shape[1]
    n_total  = n_features * n_units

    if static:
        # linear spaced out:
        #     The first param is 0 & the last param is 1,
        #     all params in between are lineared spaced out.
        #     makes it more readable & more sparsed than randomized
        weights = np.zeros(shape)
        lin_spaced = np.linspace(-limit, limit, n_total)

        for i in range(n_features):
            start = i * n_units
            end = start + n_units
            weights[i] = lin_spaced[start:end]

        # [[0.  0.2] [0.4 0.6] [0.8 1. ]]
        return weights
    else:
        # random
        limit = 1 / np.sqrt(n_features)
        weights = np.random.uniform(-limit, limit, shape)

        # [[0.50466882 0.58159532] [0.77758233 0.78466492] [0.44969037 0.5287821 ]]
        return weights

class Cell():
    def __init__(self, optimizer):
        self.values = []

        # weights
        self.W = None
        self.W_gradient = None
        self.W_optimizer = copy(optimizer)

        # bias
        self.b = None
        self.b_gradient = None
        self.b_optimizer = copy(optimizer)

    def initialize(self, n_inputs, n_outputs, limit=None):
        size = (n_inputs, n_outputs)

        # define limit
        if limit is None:
            limit = 1 / np.sqrt(n_inputs)
        
        self.W = np.random.uniform(-limit, limit, size=size)
        self.b = np.zeros((1, n_outputs))
        self.clear_gradients()

    def clear_gradients(self):
        self.W_gradient = np.zeros_like(self.W)
        self.b_gradient = np.zeros_like(self.b)

    def update_weights(self):
        if self.W_optimizer != None:
            self.W = self.W_optimizer.update(self.W, self.W_gradient)

        if self.b_optimizer != None:
            self.b = self.b_optimizer.update(self.b, self.b_gradient)

class Layer_V2():
    def __init__(self, n_units=None, input_shape=None, activation_name=None, optimizer_name=None):
        self.n_units       = n_units
        self.inputs_shape  = input_shape
        self.outputs_shape = input_shape# (n_units,)
        self.layer_input   = None
        self.layer_output  = None
        self.activation    = None
        self.optimizer     = None

        if activation_name != None:
            self.activation = act_functions[activation_name]()
        
        if optimizer_name != None:
            self.optimizer = opt_functions[optimizer_name]()

    def forward(self, X):
        self.layer_output = X
        if self.activation != None:
            return self.activation(X)
        else: 
            return X
  
    def backward(self, gradient):
        if self.activation != None:
            return gradient * self.activation.gradient(self.layer_output)
        else:
            return gradient

    def input_shape(self, new_value=None):
        if new_value != None:
            self.inputs_shape = new_value

        return self.inputs_shape

    def output_shape(self, new_value=None):
        if new_value != None:
            self.outputs_shape = new_value
            
        return self.outputs_shape

    def parameters(self): 
        return 0

    def activation_name(self):
        if self.activation is None:
            return ""
        else:
            return self.activation.__class__.__name__

    # usable on: https://github.com/eriklindernoren/ML-From-Scratch
    def backward_pass(self, gradient): return self.backward(gradient)
    def forward_pass(self, X, training=True): return self.forward(X)
    def set_input_shape(self, shape): self.inputs_shape = self.outputs_shape = shape

####################################
##   Layers that EDIT data flow   ##
####################################
class Dense_V2(Layer_V2):
    """
        ```python
        Dense_V2(n_units=512, input_shape=(784,), activation="relu", optimizer="adam")
        
        # optimizer default: "adam"
        Dense_V2(n_units=512, input_shape=(784,), activation="relu")
        
        # activation default: None
        Dense_V2(n_units=512, input_shape=(784,))

        # only on: network.add(...)
        Dense_V2(n_units=512)
        ```

        some text explaining maybe


        ## Params:
        ```txt
            n_units: int
                Number of units that is been used. 
                Number of outputs from this layer.\n
            
            input_shape: (int,)
                Amount of data inputs.\n
            
            activation: string=None
                When defined it activates the summed input.\n

            optimizer: string="adam"
                The type of learning to bring the prediction closer to the correct output
        ```
    """
    def __init__(self, n_units, input_shape, activation=None, optimizer="adam"):
        super().__init__(n_units, input_shape, activation, optimizer)

        self.cell = Cell(self.optimizer)
        self.cell.initialize(input_shape[0], n_units)

    def forward(self, X):
        self.layer_input = X
        output = X.dot(self.cell.W) + self.cell.b
        return super().forward(output)
        
    def backward(self, gradient):
        gradient = super().backward(gradient)
        W = self.cell.W

        # Calculate gradient w.r.t layer weights
        self.cell.clear_gradients()
        self.cell.W_gradient = self.layer_input.T.dot(gradient)
        self.cell.b_gradient = np.sum(gradient, axis=0, keepdims=True)
        self.cell.update_weights()
        
        # Return accumulated gradient for next layer
        # Calculated based on the weights used during the forward pass
        return gradient.dot(W.T)

    def layer_name(self):
        return self.__class__.__name__

    def parameters(self): 
        return np.prod(self.cell.W.shape) + np.prod(self.cell.b.shape)

    # bypass 
    def backward_pass(self, gradient): return self.backward(gradient)
    def forward_pass(self, X, training=True): return self.forward(X)
    def set_input_shape(self, shape): self.inputs_shape = shape

# class LSTM(Layer_V2):
# class GRU(Layer_V2):
class RNN(Layer_V2):
    def __init__(self, n_units, input_shape, activation=None, optimizer="adam", rnn_activation='tanh', bptt_trunc=5):
        super().__init__(n_units, input_shape, activation, optimizer)
        self.rnn_activation = act_functions[rnn_activation]()
        self.bptt_trunc = bptt_trunc
        
        # Initialize input gates
        limit = 1 / np.sqrt(input_shape[1])
        self.i_gates = Cell(self.optimizer)
        self.i_gates.initialize(n_units, input_shape[1], limit)

        # Initialize output gates
        limit = 1 / np.sqrt(self.n_units)
        self.o_gates = Cell(self.optimizer)
        self.o_gates.initialize(input_shape[1], n_units, limit)

        # Initialize states gates
        self.s_gates = Cell(self.optimizer)
        self.s_gates.initialize(n_units, n_units, limit)

    def forward(self, X, training=True):
        self.layer_input = X
        batch_size, timesteps, input_dim = X.shape

        # Save these values for use in backprop.
        self.i_gates.values = np.zeros((batch_size, timesteps, self.n_units))
        self.s_gates.values = np.zeros((batch_size, timesteps+1, self.n_units))
        self.o_gates.values = np.zeros((batch_size, timesteps, input_dim))

        # Set last time step to zero for calculation of the state_input at time step zero
        self.s_gates.values[:, -1] = np.zeros((batch_size, self.n_units))
        for t in range(timesteps):
            # Input to state_t is the current input and output of previous states
            self.i_gates.values[:, t] = X[:, t].dot(self.i_gates.W.T) + self.s_gates.values[:, t-1].dot(self.s_gates.W.T)
            self.s_gates.values[:, t] = self.rnn_activation(self.i_gates.values[:, t])
            self.o_gates.values[:, t] = self.s_gates.values[:, t].dot(self.o_gates.W.T)

        return super().forward(self.o_gates.values)

    def backward(self, gradient):
        gradient = super().backward(gradient)
        _, timesteps, _ = gradient.shape
        
        # Calculate gradient w.r.t layer weights
        self.i_gates.clear_gradients()
        self.o_gates.clear_gradients()
        self.s_gates.clear_gradients()

        # Will be passed on to the previous layer in the network
        gradient_next = np.zeros_like(gradient)

        # Back Propagation Through Time
        for t in reversed(range(timesteps)):
            
            # Update gradient w.r.t V at time step t
            self.o_gates.W_gradient += gradient[:, t].T.dot(self.s_gates.values[:, t])
            
            # Calculate the gradient w.r.t the state input
            grad_wrt_state = gradient[:, t].dot(self.o_gates.W) * self.rnn_activation.gradient(self.i_gates.values[:, t])
            
            # Gradient w.r.t the layer input
            gradient_next[:, t] = grad_wrt_state.dot(self.i_gates.W)

            # Update gradient w.r.t W and U by backprop. from time step t for at most
            # self.bptt_trunc number of time steps
            for t_ in reversed(np.arange(max(0, t - self.bptt_trunc), t+1)):
                self.i_gates.W_gradient += grad_wrt_state.T.dot(self.layer_input[:, t_])
                self.s_gates.W_gradient += grad_wrt_state.T.dot(self.s_gates.values[:, t_-1])
            
                # Calculate gradient w.r.t previous state
                grad_wrt_state = grad_wrt_state.dot(self.s_gates.W) * self.rnn_activation.gradient(self.i_gates.values[:, t_-1])

        # update
        self.i_gates.update_weights()
        self.o_gates.update_weights()
        self.s_gates.update_weights()
        return gradient_next

    def layer_name(self):
        return self.__class__.__name__

    def parameters(self):
        return np.prod(self.s_gates.W.shape) + np.prod(self.i_gates.W.shape) + np.prod(self.o_gates.W.shape)

    # bypass 
    def backward_pass(self, gradient): return self.backward(gradient)
    def forward_pass(self, X, training=True): return self.forward(X)
    def set_input_shape(self, shape): self.inputs_shape = shape

class Conv2D(Layer_V2):
    def __init__(self, n_units, filter_shape, input_shape, stride=1, padding="same", activation=None, optimizer="adam"):
        super().__init__(n_units, input_shape, activation, optimizer)
        self.filter_shape = filter_shape
        self.stride = stride
        self.padding = padding

        self.cell = Cell(self.optimizer)
        self.initialize(self.optimizer)
        
    def initialize(self, optimizer):
        filter_height, filter_width = self.filter_shape
        limit = 1 / np.sqrt(np.prod(self.filter_shape))
        channels = self.inputs_shape[0]
        size = (self.n_units, channels, filter_height, filter_width)

        self.cell.W  = np.random.uniform(-limit, limit, size=size)
        self.cell.b = np.zeros((self.n_units, 1))
        self.cell.clear_gradients()

    def forward(self, X):
        batch_size, channels, height, width = X.shape
        self.layer_input = X

        # Turn image shape into column shape (enables dot product between input and weights)
        self.X_col = self.image_to_column(X, self.filter_shape, stride=self.stride, output_shape=self.padding)

        # Turn weight into column shape
        self.W_col = self.cell.W.reshape((self.n_units, -1))

        # calculate output
        output = self.W_col.dot(self.X_col) + self.cell.b
        output = output.reshape(self.output_shape() + (batch_size, )).transpose(3, 0, 1, 2)
        return super().forward(output)
        
    def backward(self, gradient):
        gradient = super().backward(gradient)

        # Reshape accumulated gradient into column shape
        gradient = gradient.transpose(1, 2, 3, 0).reshape(self.n_units, -1)
        
        # Calculate gradient w.r.t layer weights
        self.cell.clear_gradients()
        self.cell.W_gradient = gradient.dot(self.X_col.T).reshape(self.cell.W.shape)
        self.cell.b_gradient = np.sum(gradient, axis=1, keepdims=True)
        self.cell.update_weights()

        # Recalculate the gradient
        gradient = self.W_col.T.dot(gradient)

        # Reshape from column shape to image shape
        gradient = self.column_to_image(gradient, self.layer_input.shape, self.filter_shape, stride=self.stride, output_shape=self.padding)

        return gradient

    def layer_name(self):
        return self.__class__.__name__

    def parameters(self): 
        return np.prod(self.cell.W.shape) + np.prod(self.cell.b.shape)
    
    def output_shape(self):
        channels, height, width = self.inputs_shape
        pad_h, pad_w = self.determine_padding(self.filter_shape, output_shape=self.padding)
        output_height = (height + np.sum(pad_h) - self.filter_shape[0]) / self.stride + 1
        output_width = (width + np.sum(pad_w) - self.filter_shape[1]) / self.stride + 1
        return self.n_units, int(output_height), int(output_width)


    # Method which turns the image shaped input to column shape.
    # Used during the forward pass.
    # Reference: CS231n Stanford
    def image_to_column(self, images, filter_shape, stride, output_shape='same'):
        filter_height, filter_width = filter_shape

        pad_h, pad_w = self.determine_padding(filter_shape, output_shape)

        # Add padding to the image
        images_padded = np.pad(images, ((0, 0), (0, 0), pad_h, pad_w), mode='constant')

        # Calculate the indices where the dot products are to be applied between weights
        # and the image
        k, i, j =self.get_im2col_indices(images.shape, filter_shape, (pad_h, pad_w), stride)

        # Get content from image at those indices
        cols = images_padded[:, k, i, j]
        channels = images.shape[1]
        # Reshape content into column shape
        cols = cols.transpose(1, 2, 0).reshape(filter_height * filter_width * channels, -1)
        return cols
        
    # Method which turns the column shaped input to image shape.
    # Used during the backward pass.
    # Reference: CS231n Stanford
    def column_to_image(self, cols, images_shape, filter_shape, stride, output_shape='same'):
        batch_size, channels, height, width = images_shape
        pad_h, pad_w = self.determine_padding(filter_shape, output_shape)
        height_padded = height + np.sum(pad_h)
        width_padded = width + np.sum(pad_w)
        images_padded = np.zeros((batch_size, channels, height_padded, width_padded))

        # Calculate the indices where the dot products are applied between weights
        # and the image
        k, i, j = self.get_im2col_indices(images_shape, filter_shape, (pad_h, pad_w), stride)

        cols = cols.reshape(channels * np.prod(filter_shape), -1, batch_size)
        cols = cols.transpose(2, 0, 1)
        # Add column content to the images at the indices
        np.add.at(images_padded, (slice(None), k, i, j), cols)

        # Return image without padding
        return images_padded[:, :, pad_h[0]:height+pad_h[0], pad_w[0]:width+pad_w[0]]

    # Method which calculates the padding based on the specified output shape and the
    # shape of the filters
    def determine_padding(self, filter_shape, output_shape="same"):

        # No padding
        if output_shape == "valid":
            return (0, 0), (0, 0)
        # Pad so that the output shape is the same as input shape (given that stride=1)
        elif output_shape == "same":
            filter_height, filter_width = filter_shape

            # Derived from:
            # output_height = (height + pad_h - filter_height) / stride + 1
            # In this case output_height = height and stride = 1. This gives the
            # expression for the padding below.
            pad_h1 = int(np.floor((filter_height - 1)/2))
            pad_h2 = int(np.ceil((filter_height - 1)/2))
            pad_w1 = int(np.floor((filter_width - 1)/2))
            pad_w2 = int(np.ceil((filter_width - 1)/2))

            return (pad_h1, pad_h2), (pad_w1, pad_w2)

    # Reference: CS231n Stanford
    def get_im2col_indices(self, images_shape, filter_shape, padding, stride=1):
        # First figure out what the size of the output should be
        batch_size, channels, height, width = images_shape
        filter_height, filter_width = filter_shape
        pad_h, pad_w = padding
        out_height = int((height + np.sum(pad_h) - filter_height) / stride + 1)
        out_width = int((width + np.sum(pad_w) - filter_width) / stride + 1)

        i0 = np.repeat(np.arange(filter_height), filter_width)
        i0 = np.tile(i0, channels)
        i1 = stride * np.repeat(np.arange(out_height), out_width)
        j0 = np.tile(np.arange(filter_width), filter_height * channels)
        j1 = stride * np.tile(np.arange(out_width), out_height)
        i = i0.reshape(-1, 1) + i1.reshape(1, -1)
        j = j0.reshape(-1, 1) + j1.reshape(1, -1)

        k = np.repeat(np.arange(channels), filter_height * filter_width).reshape(-1, 1)

        return (k, i, j)



    # bypass 
    def backward_pass(self, gradient): return self.backward(gradient)
    def forward_pass(self, X, training=True): return self.forward(X)
    def set_input_shape(self, shape): self.inputs_shape = shape

class Activation(Layer_V2):
    def __init__(self, activation_name, n_units=None, input_shape=None, optimizer_name=None):
        super().__init__(n_units, input_shape, activation_name, optimizer_name)

    def layer_name(self): 
        return self.__class__.__name__

class Perceptron(Dense_V2): pass # https://stackoverflow.com/questions/43755293/what-does-dense-do
class Neuron(Dense_V2):     pass # https://ml-cheatsheet.readthedocs.io/en/latest/nn_concepts.html
class Node(Dense_V2):       pass # https://orbograph.com/understanding-ai-what-is-a-deep-learning-node/
class Unit(Dense_V2):       pass # https://cs231n.github.io/neural-networks-1/


####################################
## Layers that MAINTAIN data flow ##
####################################
# class Input(Layer_V2):
# class Output(Layer_V2):
class Reshape(Layer_V2):
    def __init__(self, output_shape, input_shape):
        super().__init__()
        self.inputs_shape = input_shape
        self.outputs_shape = output_shape

    def forward(self, X):
        self.layer_input = X
        return X.reshape((X.shape[0], ) + self.outputs_shape)
        
    def backward(self, gradient):
        return gradient.reshape(self.layer_input.shape)

    def layer_name(self):
        return self.__class__.__name__

    def parameters(self): 
        return 0

    # bypass 
    def backward_pass(self, gradient): return self.backward(gradient)
    def forward_pass(self, X, training=True): return self.forward(X)
    def set_input_shape(self, shape): self.inputs_shape = shape

class Flatten(Layer_V2):
    def __init__(self, input_shape):
        super().__init__()
        self.inputs_shape = input_shape
        self.outputs_shape = (np.prod(input_shape),)

    def forward(self, X):
        self.layer_input = X
        return X.reshape((X.shape[0], -1))
        
    def backward(self, gradient):
        return gradient.reshape(self.layer_input.shape)

    def layer_name(self):
        return self.__class__.__name__

    def parameters(self): 
        return 0

    # bypass 
    def backward_pass(self, gradient): return self.backward(gradient)
    def forward_pass(self, X, training=True): return self.forward(X)
    def set_input_shape(self, shape): self.inputs_shape = shape

class Dropout(Layer_V2):
    def __init__(self, lowest_value, input_shape):
        super().__init__()
        self.lowest_value = lowest_value
        self.inputs_shape = input_shape
        self.outputs_shape = self.inputs_shape

    def forward(self, X):
        self.layer_input = np.random.uniform(size=X.shape) > self.lowest_value
        return X * self.layer_input

    def backward(self, gradient):
        return gradient * self.layer_input

    def layer_name(self):
        return self.__class__.__name__

    def parameters(self): 
        return 0
        
    # bypass 
    def backward_pass(self, gradient): return self.backward(gradient)
    def forward_pass(self, X, training=True): return self.forward(X)
    def set_input_shape(self, shape): self.inputs_shape = shape

class BatchNormalization(Layer_V2):
    def __init__(self, momentum=0.99, input_shape=None, optimizer="adam"):
        super().__init__()
        self.momentum = momentum
        self.inputs_shape = self.outputs_shape = input_shape
        self.optimizer = opt_functions[optimizer]()
        
        self.epsilon = 0.01
        self.running_mean = None
        self.running_var = None

        # initialize parameters
        self.gamma = np.ones(self.inputs_shape[0])
        self.beta = np.zeros(self.inputs_shape[0])
        
        # parameter optimizers
        self.gamma_optimizer = copy(self.optimizer)
        self.beta_optimizer  = copy(self.optimizer)

    def forward(self, X):
        mean = np.mean(X, axis=0)
        var = np.var(X, axis=0)

        # initialize running mean and variance if first run
        if self.running_mean is None:
            self.running_mean = mean
            self.running_var = var

        self.running_mean = self.momentum * self.running_mean + (1 - self.momentum) * mean
        self.running_var = self.momentum * self.running_var + (1 - self.momentum) * var

        # statistics saved for backward pass
        self.X_centered = X - mean
        self.stddev_inv = 1 / np.sqrt(var + self.epsilon)

        X_norm = self.X_centered * self.stddev_inv
        output = self.gamma * X_norm + self.beta
        return output
        
    def backward(self, gradient):
        # save parameters used during the forward pass
        gamma = self.gamma

        # layer update
        X_norm = self.X_centered * self.stddev_inv
        gradient_gamma = np.sum(gradient * X_norm, axis=0)
        gradient_beta = np.sum(gradient, axis=0)

        self.gamma = self.gamma_optimizer.update(self.gamma, gradient_gamma)
        self.beta = self.beta_optimizer.update(self.beta, gradient_beta)

        # The gradient of the loss with the respect to the layer inputs 
        # (use weights and statistics from forward pass)
        batch_size = gradient.shape[0]
        gradient = (1 / batch_size) * gamma * self.stddev_inv * (batch_size * gradient - np.sum(gradient, axis=0) - self.X_centered * self.stddev_inv ** 2) * np.sum(gradient * self.X_centered, axis=0)
        return gradient

    def layer_name(self):
        return self.__class__.__name__

    def parameters(self): 
        return np.prod(self.gamma.shape) + np.prod(self.beta.shape)

    # bypass 
    def backward_pass(self, gradient): return self.backward(gradient)
    def forward_pass(self, X, training=True): return self.forward(X)
    def set_input_shape(self, shape): self.inputs_shape = shape

####################################
##            Network             ##
####################################
class Network_V2():
    # used by:
    # ../artificial_neural_networks/perceptron/sample_scratch.py
    # ../artificial_neural_networks/feed_forward/sample_scratch.py
    """
    ```python
    Network_V2(loss_name="CrossEntropy")

    # loss_name default: "MSE"
    Network_V2() 
    ```

    some text explaining maybe


    ## Params:
    ```txt
        loss_name: string
            Function to calculate the distance between `network output & correct output`\n
    ```
    """
    def __init__(self, loss_name="MSE"):
        self.layers = []
        self.loss_function = loss_functions[loss_name]()

    def add(self, layer):
        self.layers.append(layer)

    def remove(self, layer_index):
        del self.layers[layer_index]
        return self.layers
    
    def test_on_batch(self, X, y):
        y_pred = self._forward(X)

        loss = np.mean(self.loss_function(y, y_pred))
        acc = self.loss_function.acc(y, y_pred)

        return loss, acc

    def train_on_batch(self, X, y):
        y_pred = self._forward(X)

        loss = np.mean(self.loss_function(y, y_pred))
        acc = self.loss_function.acc(y, y_pred)
        loss_grad = self.loss_function.gradient(y, y_pred)
        loss_grad = self._backward(loss_grad)

        return loss, acc, loss_grad

    def _backward(self, gradient_loss):
        # update weights in each layer, bind the output to next input gradient loss
        for layer in reversed(self.layers):
            gradient_loss = layer.backward_pass(gradient_loss)

        return gradient_loss
            
    def _forward(self, X):
        output = X

        # walk through layers, bind the output to input
        for layer in self.layers:
            output = layer.forward_pass(output)

        return output

    def summary(self, name="Model Summary"):
        # Print model name
        print (AsciiTable([[name]]).table)
        # Network input shape (first layer's input shape)
        print ("Input Shape: %s" % str(self.layers[0].input_shape()))
        # Iterate through network and get each layer's configuration
        table_data = [["Layer Type", "Parameters", "Output Shape", "Activation name"]]
        tot_params = 0
        for layer in self.layers:
            layer_name = layer.layer_name()
            params = layer.parameters()
            out_shape = 000# layer.output_shape()
            activation_name = 000# layer.activation_name()
            table_data.append([layer_name, str(params), str(out_shape), str(activation_name)])
            tot_params += params
        # Print network configuration table
        print (AsciiTable(table_data).table)
        print ("Total Parameters: %d\n" % tot_params)

    def predict(self, X):
        return self._forward(X)

    def fit(self, X, y, n_epochs, batch_size=1):
        loss_history = []
        accuracy = 0.00

        for epoch in range(n_epochs):    
            loss_batch = []
            for X_batch, y_batch in self.batch_iterator(X, y, batch_size=batch_size):
                loss, accuracy, _ = self.train_on_batch(X_batch, y_batch)
                loss_batch.append(loss)

            loss = np.mean(loss_batch)
            loss_history.append(loss)
            print(f"\r[{epoch}/{n_epochs}] loss:{loss}", end="")

        print()
        return loss_history, accuracy

    def batch_iterator(self, X, y=None, batch_size=64):
        """ Simple batch generator """
        n_samples = X.shape[0]
        for i in np.arange(0, n_samples, batch_size):
            begin, end = i, min(i+batch_size, n_samples)
            if y is not None:
                yield X[begin:end], y[begin:end]
            else:
                yield X[begin:end]
