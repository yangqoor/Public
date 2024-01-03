# type of rnn: `Many to Many`
import numpy as np
from tensorflow.keras import (
    datasets, 
    preprocessing, 
    utils, 
    models, 
    layers, 
    optimizers
)

# generate data
(X_train, y_train), (X_test, y_test) = datasets.reuters.load_data(num_words=30000, maxlen=50, test_split=0.3)

# nomalize/rescale dataset
X_train = preprocessing.sequence.pad_sequences(X_train, padding='post')
X_test = preprocessing.sequence.pad_sequences(X_test, padding='post')

X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))
X_test = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], 1))

y_train = utils.to_categorical(y_train)
y_test = utils.to_categorical(y_test)

# define network
network = models.Sequential()
network.add(layers.SimpleRNN(y_train.shape[1], input_shape=X_train.shape[1:], return_sequences=False))
network.add(layers.Dense(y_train.shape[1], activation="softmax"))
network.compile(loss = 'categorical_crossentropy', optimizer="adam", metrics = ['accuracy'])

# train network
network.fit(X_train, y_train, epochs=200, batch_size=50)

# results network
y_pred = network.predict(X_test)
print(f"y_pred[0]: {y_pred[0]}")

y_correct = np.argmax(y_test, axis=1)
print(f"y_correct[0]: {y_correct[0]}")



