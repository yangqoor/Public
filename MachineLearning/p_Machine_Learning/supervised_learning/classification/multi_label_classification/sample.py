from sklearn.datasets import make_multilabel_classification

# define dataset
X, y = make_multilabel_classification(n_samples=1000, n_features=2, n_classes=3, n_labels=2, random_state=1)
print(X.shape, y.shape)

# summarize first few examples
for i in range(10):
    print(X[i], y[i])
