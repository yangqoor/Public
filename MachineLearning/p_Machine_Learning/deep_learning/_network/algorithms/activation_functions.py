import numpy as np # for math

# Collection of activation functions
# References: 
# https://en.wikipedia.org/wiki/Activation_function
# https://miro.medium.com/proxy/1*RD0lIYqB5L2LrI2VTIZqGw.png
# https://deepai.org/machine-learning-glossary-and-terms/sigmoid-function
# σ(x) = 1 / 1+e(−xb)
# x = cosh(a) = e(a)+e(−a)/2​   &    y = sinh(a) = e(a)−e(−a)/2
# https://brilliant.org/wiki/hyperbolic-trigonometric-functions/

class Sigmoid():
    def __call__(self, x, bias=0):
        return 1 / (1 + np.exp(-x + bias))
    
    def gradient(self, x, bias=0, out=None):
        if out is None:
            out = self.__call__(x, bias)
        return out * (1 - out)

class TanH():
    def __call__(self, x):
        return 2 / (1 + np.exp(-2 * x)) - 1

    def gradient(self, x):
        return 1 - (self.__call__(x) ** 2)

class ReLU():
    def __call__(self, x):
        return np.where(x >= 0, x, 0)

    def gradient(self, x):
        return np.where(x >= 0, 1, 0)

class SoftPlus():
    def __call__(self, x):
        return np.log(1 + np.exp(x))
    
    def gradient(self, x):
        return 1 / (1 + np.exp(-x))

class LeakyReLU():
    def __init__(self, alpha=0.2):
        self.alpha = alpha

    def __call__(self, x):
        return np.where(x >= 0, x, self.alpha * x)

    def gradient(self, x):
        return np.where(x >= 0, 1, self.alpha)

class ELU():
    def __init__(self, alpha=0.2):
        self.alpha = alpha

    def __call__(self, x):
        return np.where(x >= 0.0, x, self.alpha * (np.exp(x) - 1))

    def gradient(self, x):
        return np.where(x >= 0.0, 1, self.__call__(x) + self.alpha)

class SELU():
    def __init__(self):
        self.alpha = 1.6732632423543772848170429916717
        self.scale = 1.0507009873554804934193349852946 

    def __call__(self, x):
        return self.scale * np.where(x >= 0.0, x, self.alpha*(np.exp(x) - 1))
    
    def gradient(self, x):
        return self.scale * np.where(x >= 0.0, 1, self.alpha * np.exp(x))

class Softmax:
    def __call__(self, x):
        e_x = np.exp(x - np.max(x))
        return e_x / np.sum(e_x)
    
    def gradient(self, x):
        p = self.__call__(x)
        return p * (1 - p)

class Softmax_V2():
    def __call__(self, x):
        exponential = np.exp(x - np.max(x, axis=-1, keepdims=True))
        return exponential / np.sum(exponential , axis=-1, keepdims=True)
    
    def gradient(self, x):
        p = self.__call__(x)
        return p * (1 - p)

act_functions = {
    "sigmoid"   : Sigmoid,
    "tanh"      : TanH,
    "relu"      : ReLU,
    "softplus"  : SoftPlus,
    "leakyrelu" : LeakyReLU,
    "elu"       : ELU,
    "selu"      : SELU,
    "softmax"   : Softmax,
    "softmax_v2"   : Softmax_V2
}
