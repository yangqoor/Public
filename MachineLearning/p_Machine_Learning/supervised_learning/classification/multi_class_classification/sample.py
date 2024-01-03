from numpy import where
from collections import Counter
from sklearn.datasets import make_blobs
import matplotlib.pyplot as plt

# define dataset
X, y = make_blobs(n_samples=1000, centers=3, random_state=1)
# print(X.shape, y.shape)

counter = Counter(y)
print(counter)

for label, _ in counter.items():
    row_ix = where(y == label)[0]
    plt.scatter(X[row_ix, 0], X[row_ix, 1], label=str(label))

plt.legend()
plt.show()
