# Residual-Ratio-Thresholding

Residual Ratio Thresholding  (RRT) is a technique to identify the the correct regression model from a sequence of candidate nested models. This can be utilized for the estimation of sparse entities. Its main features are,  

1). RRT can operate algorithms like LASSO, OMP and their derivatives without knowing signal sparsity and noise variance. The requirement of a priori knowledge of hard to estimate quantities like signal sparsity, noise variance is a roadblock in using algorithms like OMP, LASSO especially for support recovery problems. 

2). RRT  provides easy to interpret finite sample and finite SNR  support recovery guarantees. 

3). RRT is closely related to various information theoretic criteria like AIC, BIC etc. However, unlike many information theoretic criteria, RRT is based on finite sample distributional results. 

4). RRT is applicable to many different scenarios like unstructured sparse vector estimation, group sparse vector estimation, estimating row sparse matrix, robust regression with sparse outliers, linear model order selection etc. 

These codes are a result of joint work with Dr.Sheetal Kalyani, Dept. Of Electrical Engineering. (http://www.ee.iitm.ac.in/user/skalyani/)

# Usage 

The RRT based estimation functions for each scenario are available in seperate python files in codes/. Please see the associated notebooks for a tutorial like description on using RRT. 

1). RRT_single_measurement_vector.ipynb # for unstructured compressive sensing with single measurement vector.

2). RRT_multiple_measurement_vector.ipynb # for unstructured compressive sensing with multiple measurement vectors ,i.e., row sparse matrix estimation.

3). RRT_block_single_measurement_vector.ipynb # for group/block sparse compressive sensing with single measurement vector.

4). RRT_block_multiple_measurement_vector.ipynb # for compressive sensing with multiple measurement vector when non zero rows are cluttered together.

5). RRT_model_order_selection.ipynb # for model order selection problems.

6). RRT_robust_regression.ipynb # For estimation of dense vectors from regression models contaminated with sparse outliers. 

# Publications

The following papers are published based on the concept of Residual Ratio Thresholding. 

1. Signal and Noise Statistics Oblivious Orthogonal Matching Pursuit (ICML 2018, http://proceedings.mlr.press/v80/kallummil18a.html) (Operating OMP using RRT)

2. Noise Statistics Oblivious GARD For Robust Regression With Sparse Outliers (IEEE TSP 2018, https://ieeexplore.ieee.org/abstract/document/8543649) (Operating an algorithm form robust regression called GARD using RRT)

3). Residual Ratio Thresholding for Linear Model Order Selection (IEEE TSP  2019, https://ieeexplore.ieee.org/abstract/document/8573899) (Perform model order selection using RRT. Establish links between RRT and Information Theoretic criteria)

4). Generalized residual ratio thresholding (Under review in IEEE TSP 2020, https://arxiv.org/pdf/1912.08637.pdf) (Extended RRT to multiple measurement vectors, group sparsity, LASSO etc.)

5). High SNR consistent compressive sensing without noise statistics. (Elsevier Signal Processing 2020 https://www.sciencedirect.com/science/article/abs/pii/S0165168419303883). Developed a high SNR consistent version of RRT. 

Please cite the relevant papers if you are using these codes. This set of Python RRT codes is a work under progress. Will be fully ready by November 2020. For comments/suggestions, please write to sreejith.k.venugopal@gmail.com

