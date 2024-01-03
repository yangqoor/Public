# Clustering
The goal of `unsupervised learning` is to discover hidden patterns in any unlabeled data. One of the approaches to `unsupervised learning` is clustering. In this tutorial, we will discuss clustering, its types and a few algorithms to find clusters in data. `Clustering` groups data points based on their similarities. Each group is called a cluster and contains data points with high similarity and low similarity with data points in other clusters. In short, data points of a cluster are more similar to each other than they are to the data points of other clusters. The goal of clustering is to divide a set of data points in such a way that similar items fall into the same cluster, whereas dissimilar data points fall in different clusters. Further in this tutorial, we will discuss ideas on how to choose different metrics of similarity between data points and use them in different clustering algorithms.

Clustering is crucial in multiple research fields in BioInformatics such as analyzing unlabeled data which can be gene expressions profiles, biomedical images and so on. For example, clustering is often used in gene expression analysis to find groups of genes with similar expression patterns which may provide a useful understanding of gene functions and regulations, cellular processes and so on. 

## Subsets of `Clustering`:
##### best way is to learn is from `TOP` to `BOTTOM`.  
  + [`Affinity Propagation`](./affinity_propagation/README.md)
  + [`Agglomerative Clustering`](./agglomerative_clustering/README.md)
  + [`BIRCH`](./BIRCH/README.md)
  + [`DBSCAN`](./DBSCAN/README.md)
  + [`Gaussian Mixture`](./gaussian_mixture/README.md)
  + [`K-Means`](./k_means/README.md)
  + [`Mean Shift`](./mean_shift/README.md)
  + [`OPTICS`](./OPTICS/README.md)
  + [`Spectral Clustering`](./spectral_clustering/README.md)

<p align="center">
    <img src="https://miro.medium.com/max/1200/1*oNt9G9UpVhtyFLDBwEMf8Q.png" width="750">
</p>

# Informative Resources:
+ https://towardsdatascience.com/unsupervised-learning-and-data-clustering-eeecb78b422a
+ https://scikit-learn.org/stable/modules/clustering.html  
+ https://developers.google.com/machine-learning/clustering
+ https://www.freecodecamp.org/news/8-clustering-algorithms-in-machine-learning-that-all-data-scientists-should-know/
+ https://machinelearningmastery.com/clustering-algorithms-with-python
