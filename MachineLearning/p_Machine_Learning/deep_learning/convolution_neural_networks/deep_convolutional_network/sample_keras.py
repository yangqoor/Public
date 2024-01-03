import matplotlib.pyplot as plt
from tensorflow.keras.datasets import mnist
from tensorflow.keras.utils import to_categorical
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Conv2D, Flatten

# download mnist data split into train and test sets
(X_train, y_train), (X_test, y_test) = mnist.load_data()

# plot the first image iin the dataset
plt.imshow(X_train[0])

# reshape data to fit model (pre-processing)
X_train = X_train.reshape(60000, 28, 28, 1)
X_test = X_test.reshape(10000, 28, 28, 1)

# one-hot encode target column
y_train = to_categorical(y_train)
y_test = to_categorical(y_test)

# Create model
model = Sequential()
model.add(Conv2D(64, kernel_size=3, activation="relu", input_shape=(28, 28, 1)))
model.add(Conv2D(32, kernel_size=3, activation="relu"))
model.add(Flatten())
model.add(Dense(10, activation="softmax"))

# compile
model.compile(optimizer="adam", loss="categorical_crossentropy", metrics=["accuracy"])

# train the model
model.fit(X_train, y_train, validation_data=(X_test, y_test), epochs=3)

# predict first 4 images in the test set
network_predictions = model.predict(X_test[:4])
for i, pred in enumerate(network_predictions):
    prediction = [i for i, x in enumerate(pred) if x == max(pred)]
    correct = [i for i, x in enumerate(y_test[i]) if x == max(y_test[i])]
    print(f"prediction on picture {i} = {prediction}, correct answer = {correct}")
