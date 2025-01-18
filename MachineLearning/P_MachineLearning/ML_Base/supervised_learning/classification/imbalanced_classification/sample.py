from numpy import where
from collections import Counter
from sklearn.datasets import make_classification
import matplotlib.pyplot as plt

# dataset
X, y = make_classification(n_samples=1000, n_features=2, n_informative=2, n_redundant=0, n_classes=2, n_clusters_per_class=1, weights=[0.99, 0.01], random_state=1)
# print(X.shape, y.shape)

# summarize observations bt class label
counter = Counter(y)
print(counter)

# plot dataset and color the by class label
for label, _ in counter.items():
    row_ix = where(y == label)[0]
    plt.scatter(X[row_ix, 0], X[row_ix, 1], label=str(label))

plt.legend()
plt.show()

