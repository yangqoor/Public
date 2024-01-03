# Dimensionality Reduction
These factors are basically variables called features. The higher the number of features, the harder it gets to visualize the training set and then work on it. Sometimes, most of these features are correlated, and hence redundant. This is where `dimensionality reduction` algorithms come into play. `Dimensionality reduction` is the process of reducing the number of random variables under consideration, by obtaining a set of principal variables. It can be divided into feature selection and feature extraction.

An intuitive example of dimensionality reduction can be discussed through a simple e-mail classification problem, where we need to classify whether the e-mail is spam or not. This can involve a large number of features, such as whether or not the e-mail has a generic title, the content of the e-mail, whether the e-mail uses a template, etc. However, some of these features may overlap. In another condition, a classification problem that relies on both humidity and rainfall can be collapsed into just one underlying feature, since both of the aforementioned are correlated to a high degree. Hence, we can reduce the number of features in such problems.

## Subsets of `Dimensionality Reduction`:
##### best way is to learn is from `TOP` to `BOTTOM`.
  + [`LSA`](./LSA/README.md)
  + [`NMF`](./NMF/README.md)
  + [`PCA`](./PCA/README.md)
  + [`t-SNE`](./t_SNE/README.md)
  + [`UMAP`](./UMAP/README.md)

<p align="center">
    <img src="https://miro.medium.com/max/2000/1*WhKA9Jboj_1sHa0MbWQQ7w.png" width="750">
</p>

# Resources:
+ https://towardsdatascience.com/dimensionality-reduction-for-machine-learning-80a46c2ebb7e
+ https://machinelearningmastery.com/dimensionality-reduction-for-machine-learning/
+ https://en.wikipedia.org/wiki/Dimensionality_reduction
+ https://homepage.univie.ac.at/maximilian.noichl/
+ https://machinelearningmastery.com/calculate-principal-component-analysis-scratch-python/
+ https://www.youtube.com/watch?v=g-Hb26agBFg
+ https://www.youtube.com/watch?v=aStvaXMhGGs
+ https://www.youtube.com/watch?v=EMD106bB2vY
+ https://machinelearningmastery.com/rfe-feature-selection-in-python/