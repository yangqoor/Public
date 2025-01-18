import numpy as np
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense

# train data
X = np.array([
    [1,1,1], 
    [1,1,0], 
    [1,0,0], 
    [0,0,0], 
    [0,0,1], 
    [0,1,1]
])

# train data results
y = np.array([
    [0, 1],
    [1, 0],
    [0, 1],
    [0, 1],
    [0, 1],
    [1, 0]
])

# model
model = Sequential([
    Dense(3, activation="relu", input_shape=(3,)),
    Dense(3, activation="relu"),
    Dense(2, activation="sigmoid")
])
model.compile(loss="binary_crossentropy", metrics=["accuracy"])
model.fit(X, y, batch_size=1, epochs=1500)

# predict
unknown_input = [[0, 1, 0]]
result = model.predict(unknown_input)

print("\n\n")
print("the prediction of the neural network: " + str(result))
print("\n\n")