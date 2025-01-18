import sys, os
import numpy as np
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from tensorflow.keras.utils import to_categorical

sys.path.insert(1, os.getcwd() + "./../../_network") 
from layers import Network_V2, RNN

def generate_data(amount):
    """ Method which generates multiplication series """
    X = np.zeros([amount, 10, 61], dtype=float)
    y = np.zeros([amount, 10, 61], dtype=float)

    for i in range(amount):
        start = np.random.randint(2, 7)
        mult_ser = np.linspace(start, start*10, num=10, dtype=int)
        X[i] = to_categorical(mult_ser, num_classes=61)
        y[i] = np.roll(X[i], -1, axis=0)

    y[:, -1, 1] = 1 # Mark endpoint as 1
    return X, y

X, y = generate_data(3000)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.4)

# define network
network = Network_V2(loss_name="CrossEntropy")
network.add(RNN(y_train.shape[1], input_shape=X_train.shape[1:], activation="softmax", rnn_activation="tanh", bptt_trunc=5))

# Print a problem instance and the correct solution
tmp_X = np.argmax(X_train[0], axis=1)
tmp_y = np.argmax(y_train[0], axis=1)
print("Number Series Problem:")
print("X = [" + " ".join(tmp_X.astype("str")) + "]")
print("y = [" + " ".join(tmp_y.astype("str")) + "]\n")

# train network
train_err, _ = network.fit(X_train, y_train, n_epochs=500, batch_size=512)

# Predict labels of the test data
y_pred = np.argmax(network.predict(X_test), axis=2)
y_test = np.argmax(y_test, axis=2)

print()
print("Results:")
for i in range(5):
    # Print a problem instance and the correct solution
    tmp_X = np.argmax(X_test[i], axis=1)
    tmp_y1 = y_test[i]
    tmp_y2 = y_pred[i]
    print ("X      = [" + " ".join(tmp_X.astype("str")) + "]")
    print ("y_true = [" + " ".join(tmp_y1.astype("str")) + "]")
    print ("y_pred = [" + " ".join(tmp_y2.astype("str")) + "]\n")

training = plt.plot(range(500), train_err, label="Training Error")
plt.title("Error Plot")
plt.ylabel('Training Error')
plt.xlabel('Iterations')
plt.show()
