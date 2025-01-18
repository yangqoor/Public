import numpy as np
import seaborn as sns
import umap.umap_ as umap
import matplotlib.pyplot as plt
from sklearn.datasets import load_iris

# data
iris = load_iris()

# define model
reducer = umap.UMAP()

# train model
embedding = reducer.fit_transform(iris.data)

plt.scatter(embedding[:, 0], embedding[:, 1], c=[sns.color_palette()[x] for x in iris.target])
plt.gca().set_aspect('equal', 'datalim')
plt.title('UMAP projection of the Iris dataset', fontsize=24);
plt.show()

