from sklearn.datasets import load_iris
from sklearn.gaussian_process import GaussianProcessClassifier
from sklearn.gaussian_process.kernels import RBF

# load data
X, y = load_iris(return_X_y=True)
kernel = 1.0 * RBF(1.0)

# define model
model = GaussianProcessClassifier(kernel=kernel, random_state=0)

# train data
model.fit(X, y)

# predict
unknown_input = [[5.1, 3.5, 1.4, 0.2]]
result = model.predict(unknown_input)
print("\n\n")
print("the prediction of the neural network: " + str(result))
print("\n\n")