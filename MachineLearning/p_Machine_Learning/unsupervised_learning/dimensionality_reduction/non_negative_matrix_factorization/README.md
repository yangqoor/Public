# Non-Negative Matrix Factorization (NMF) 
`NMF stands for non-negative matrix factorization`, a technique for obtaining low rank representation of matrices with non-negative or positive elements. Such matrices are common in a variety of applications of interest. For example, images are nothing but matrices of positive integer numbers representing pixel intensities. In information retrieval and text mining, we rely on term-document matrices for representing document collections. In recommendation systems, we have utility matrices showing customers’ preferences for items.

Given a data matrix A of m rows and n columns with each and every element aij ≥ 0, NMF seeks matrices W and H of size m rows and k columns, and k rows and n columns, respectively, such that A≈WH, and every element of matrices W and H is either zero or positive. The quantity k is set by the user and is required to be equal or less than the smallest of m and n. The matrix W  is generally called the dictionary or basis matrix, and H is known as expansion or coefficient matrix. The underlying idea of this terminology is that a given data matrix A can be expressed in terms of summation of k basis vectors (columns of W) multiplied by the corresponding coefficients (columns of H).

## code 
[`python3 sample.py`](./sample.py)
<p align="center">
  <img src="https://blog.acolyer.org/wp-content/uploads/2019/02/nmf-fig-1.jpeg?w=640" width="500">
</p>
<p align="center">
  <img src="https://www.researchgate.net/publication/306246844/figure/fig1/AS:396052583731203@1471437702189/A-Non-negative-matrix-factorization-NMF-returns-five-basis-shapes-that-explain-976.png" width="500">
</p>

## Resources
+ https://predictivehacks.com/topic-modelling-with-nmf-in-python/
+ https://methods.sagepub.com/dataset/howtoguide/non-negative-matrix-factorization-in-news-2016-python
+ https://medium.com/logicai/non-negative-matrix-factorization-for-recommendation-systems-985ca8d5c16c
+ https://datascience.stackexchange.com/questions/10299/what-is-a-good-explanation-of-non-negative-matrix-factorization
+ https://towardsdatascience.com/nmf-a-visual-explainer-and-python-implementation-7ecdd73491f8 (use incognito)
+ https://blog.acolyer.org/2019/02/18/the-why-and-how-of-nonnegative-matrix-factorization/
+ https://en.wikipedia.org/wiki/Non-negative_matrix_factorization
+ https://www.youtube.com/watch?v=AjtfHRVpjEc
+ https://github.com/kimjingu/nonnegfac-python
+ https://github.com/benedekrozemberczki/M-NMF

