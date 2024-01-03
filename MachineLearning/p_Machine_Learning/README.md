# Machine Learing (ML)
`Machine learning` is an application of artificial intelligence (`AI`) that provides systems the ability to automatically learn and improve from experience without being explicitly programmed.
`Machine learning` focuses on the development of computer programs that can access data and use it to learn for themselves.  

For beginners [`Machine Learning by Google`](https://developers.google.com/machine-learning) and [`Machine Learning by scikit-learn`](https://scikit-learn.org/stable/) will be a good take-off.  
To start understanding most of the `Machine Learning` algorithms, you must get the basic understanding of `Calculus` and `Linear Algebra`:  
+ [`Linear Algebra`](https://www.youtube.com/watch?v=fNk_zzaMoSs&list=PLZHQObOWTQDPD3MizzM2xVFitgF8hE_ab&index=1)
+ [`Calculus`](https://www.youtube.com/watch?v=WUvTyaaNkzM&list=PLZHQObOWTQDMsr9K-rj53DwVRMYO3t5Yr&index=1)
+ [`Derivatives exersices`](http://derivative-functions.cours-de-math.eu/exercises-derivative-basic.php)  
+ [`Derivatives exersices`](https://www.youtube.com/watch?v=5yfh5cf4-0w)  
+ [`Partial Derivatives`](https://www.youtube.com/watch?v=p_di4Zn4wz4&list=PLZHQObOWTQDNPOjrT6KVlfJuKtYTftqH6&index=1)  
+ [`Partial Derivatives exersices`](https://www.youtube.com/watch?v=JAf_aSIJryg) 


When there is a clear understanding how  [`Deep Learning`](./deep_learning/README.md) is working nor used on data.  
[`Supervised Learning`](./supervised_learning/README.md)`, ` [`Unsupervised Learning `](./unsupervised_learning/README.md)` and ` [`Reinforcement Learning`](./reinforcement_learning/README.md) are understandable as well.

## Requirements 
```python
  # (required to have programming knowledge)
  # 1 - open a command prompt, in this folder.
  # 2 - paste line below & press enter.
  pip3 install -r "./requirements.txt"
```

# [`Deep Learning`](./deep_learning/README.md)
Usage Type                                                                                                                             | Model Type   | tensorflow | pytorch |   numpy   |
|--------------------------------------------------------------------------------------------------------------------------------------|--------------|------------|---------|-----------|
<b>[`Artificial Neural Networks`](./deep_learning/artificial_neural_networks/README.md)</b>
| | [`Perceptron`](./deep_learning/artificial_neural_networks/perceptron/README.md)                                                                   |⬜️         |⬜️       |✅         |
| | [`Feed Forward`](./deep_learning/artificial_neural_networks/feed_forward/README.md)                                                               |✅         |⬜️       |✅         |
| | [`Deep Feed Forward`](./deep_learning/artificial_neural_networks/deep_feed_forward/README.md)                                                     |✅         |✅       |✅         |
| | [`Radial Basis Network`](./deep_learning/artificial_neural_networks/radial_basis_network/README.md)                                               |⬜️         |✅       |✅         |
<b>[`Recurrent Neural Networks`](./deep_learning/recurrent_neural_networks/README.md)</b>          
| | [`Recurrent Neural Network`](./deep_learning/recurrent_neural_networks/recurrent_neural_network/README.md)                                        |✅         |✅       |✅         |
| | [`Long Short Term Memory`](./deep_learning/recurrent_neural_networks/long_short_term_memory/README.md)                                            |✅         |✅       |⬜️         |
| | [`Gated Recurrent Unit`](./deep_learning/recurrent_neural_networks/gated_recurrent_unit/README.md)                                                |✅         |✅       |⬜️         |
<b>[`Auto Encoders`](./deep_learning/autoencoders/README.md)</b>
| | [`Auto Encoder`](./deep_learning/autoencoders/autoencoder/README.md)                                                                            |✅         |✅       |✅         |
| | [`Denoising Autoencoder`](./deep_learning/autoencoders/denoising_autoencoder/README.md)                                                           |✅         |✅       |✅         |
| | [`Generative Adversarial Network`](./deep_learning/autoencoders/generative_adversarial_network/README.md)                                         |✅         |✅       |✅         |
| | [`Sparse Autoencoder`](./deep_learning/autoencoders/sparse_autoencoder/README.md)                                                                 |✅         |✅       |⬜️         |
| | [`Variational Autoencoder`](./deep_learning/autoencoders/variational_autoencoder/README.md)                                                       |✅         |✅       |⬜️         |
<b>[`Convolution Neural Networks`](./deep_learning/convolution_neural_networks/README.md)</b>
| | [`Deep Convolutional Network`](./deep_learning/convolution_neural_networks/deep_convolutional_network/README.md)                                  |✅         |✅       |✅         |
| | [`Deconvolutional Network`](./deep_learning/convolution_neural_networks/deconvolutional_network/README.md)                                        |✅         |✅       |⬜️         |
| | [`Deep Convolutional Inverse Graphics Network`](./deep_learning/convolution_neural_networks/deep_convolutional_inverse_graphics_network/README.md)|✅         |✅       |✅         |
<b>[`Stochastic Neural Networks`](./deep_learning/stochastic_neural_networks/README.md)</b>
| | [`Deep Belief Network`](./deep_learning/stochastic_neural_networks/deep_belief_network/README.md)                                                 |⬜️         |✅       |⬜️         |
| | [`Restricted Boltzmann Machine`](./deep_learning/stochastic_neural_networks/restricted_boltzmann_machine/README.md)                               |⬜️         |✅       |✅         |
<b>[`Reservoir Computing`](./deep_learning/reservoir_computing/README.md)</b>
| | [`Liquid State Machine`](./deep_learning/reservoir_computing/liquid_state_machine/README.md)                                                      |⬜️         |⬜️       |⬜️         |
| | [`Extreme Learning Machine`](./deep_learning/reservoir_computing/extreme_learning_machine/README.md)                                              |⬜️         |⬜️       |✅         |
| | [`Echo State Network`](./deep_learning/reservoir_computing/echo_state_network/README.md)                                                          |⬜️         |⬜️       |✅         |
<b>[`Ungrouped Networks`](./deep_learning/ungrouped_networks/README.md)</b>
| | [`Deep Residual Network`](./deep_learning/ungrouped_networks/deep_belief_network/README.md)                                                       |✅         |✅       |⬜️         |
| | [`Kohonen Network`](./deep_learning/ungrouped_networks/kohonen_network/README.md)                                                                 |⬜️         |✅       |⬜️         |
| | [`Neural Tuning Machine`](./deep_learning/ungrouped_networks/neural_tuning_machine/README.md)                                                     |⬜️         |✅       |⬜️         |
| | [`Support Vector Machine`](./deep_learning/ungrouped_networks/support_vector_machine/README.md)                                                   |⬜️         |⬜️       |✅         |
 
# [`Supervised Learning`](./supervised_learning/README.md)
Usage Type                                                                                                   | Model Type   | numpy |
|------------------------------------------------------------------------------------------------------------|--------------|-------|
<b>[`Classification`](./supervised_learning/classification/README.md)</b>
| | [`Binary Classification`](./supervised_learning/classification/binary_classification/README.md)                         |✅     |
| | [`Imbalanced Classification`](./supervised_learning/classification/imbalanced_classification/README.md)                 |✅     |
| | [`Multi Class Classification`](./supervised_learning/classification/multi_class_classification/README.md)               |✅     |
| | [`Multi Label Classification`](./supervised_learning/classification/multi_label_classification/README.md)               |✅     |
<b>[`Regression`](./supervised_learning/regression/README.md)</b>          
| | [`Cox Regression`](./supervised_learning/regression/cox_regression/README.md)                                           |✅     |
| | [`Elastic Net Regression`](./supervised_learning/regression/elastic_net_regression/README.md)                           |✅     |
| | [`Lasso Regression`](./supervised_learning/regression/lasso_regression/README.md)                                       |✅     |
| | [`Linear Regression`](./supervised_learning/regression/linear_regression/README.md)                                     |✅     |
| | [`Logistic Regression`](./supervised_learning/regression/logistic_regression/README.md)                                 |✅     |
| | [`Negative Binomial Regression`](./supervised_learning/regression/negative_binomial_regression/README.md)               |✅     |
| | [`Ordinal Regression`](./supervised_learning/regression/ordinal_regression/README.md)                                   |✅     |
| | [`Partial Least Squares Regression`](./supervised_learning/regression/partial_least_squares_regression/README.md)       |✅     |
| | [`Poisson Regression`](./supervised_learning/regression/poisson_regression/README.md)                                   |✅     |
| | [`Polynomial Regression`](./supervised_learning/regression/polynomial_regression/README.md)                             |✅     |
| | [`Principal Components Regression`](./supervised_learning/regression/principal_components_regression/README.md)         |✅     |
| | [`Quantile Regression`](./supervised_learning/regression/quantile_regression/README.md)                                 |✅     |
| | [`Ridge Regression`](./supervised_learning/regression/ridge_regression/README.md)                                       |✅     |
| | [`Support Vector Regression`](./supervised_learning/regression/support_vector_regression/README.md)                     |✅     |


# [`Unsupervised Learning`](./unsupervised_learning/README.md)
Usage Type                                                                                                                                   | Model Type   | sample | numpy |
|--------------------------------------------------------------------------------------------------------------------------------------------|--------------|--------|-------|
<b>[`Clustering`](./unsupervised_learning/clustering/README.md)</b>
| | [`Affinity Propagation`](./unsupervised_learning/clustering/affinity_propagation/README.md)                                                             |✅      |✅    |
| | [`Agglomerative Clustering`](./unsupervised_learning/clustering/agglomerative_clustering/README.md)                                                     |✅      |✅    |
| | [`BIRCH`](./unsupervised_learning/clustering/BIRCH/README.md)                                                                                           |✅      |⬜️    |
| | [`DBSCAN`](./unsupervised_learning/clustering/DBSCAN/README.md)                                                                                         |✅      |✅    |
| | [`Gaussian Mixture`](./unsupervised_learning/clustering/gaussian_mixture/README.md)                                                                     |✅      |✅    |
| | [`K-Means`](./unsupervised_learning/clustering/k_means/README.md)                                                                                       |✅      |✅    |
| | [`Mean Shift`](./unsupervised_learning/clustering/mean_shift/README.md)                                                                                 |✅      |✅    |
| | [`OPTICS`](./unsupervised_learning/clustering/OPTICS/README.md)                                                                                         |✅      |✅    |
| | [`Spectral Clustering`](./unsupervised_learning/clustering/spectral_clustering/README.md)                                                               |✅      |✅    |
<b>[`Dimensionality Reduction`](./unsupervised_learning/dimensionality_reduction/README.md)</b>          
| | [`Latent Semantic Analysis`](./unsupervised_learning/dimensionality_reduction/latent_semantic_analysis/README.md)                                       |✅      |⬜️    |
| | [`Non Negative Matrix Factorization`](./unsupervised_learning/dimensionality_reduction/non_negative_matrix_factorization/README.md)                     |✅      |⬜️    |
| | [`Principal Component Analysis`](./unsupervised_learning/dimensionality_reduction/principal_component_analysis/README.md)                               |✅      |✅    |
| | [`T-Distributed Stochastic Neighbor Embedding`](./unsupervised_learning/dimensionality_reduction/t_distributed_stochastic_neighbor_embedding/README.md) |✅      |⬜️    |
| | [`Uniform Manifold Approximation And Projection`](./unsupervised_learning/dimensionality_reduction/latent_semantic_analysis/README.md)                  |✅      |⬜️    |

# [`Reinforcement Learning`](./reinforcement_learning/README.md)
| Model Type                                                                                                    | sample |
|---------------------------------------------------------------------------------------------------------------|--------|
| [`Q-Learning`](./reinforcement_learning/q_learning/README.md)                                                 |✅     |
| [`Deep Q-Learning`](./reinforcement_learning/deep_q_learning/README.md)                                       |✅     |
| [`Double Deep Q-Learning`](./reinforcement_learning/double_deep_q_learning/README.md)                         |✅     |
| [`Actor Critic Method`](./reinforcement_learning/actor_critic_method/README.md)                               |✅     |
| [`Deep Deterministic Policy Gradient`](./reinforcement_learning/deep_deterministic_policy_gradient/README.md) |✅     |
| [`Proximal Policy Optimization`](./reinforcement_learning/proximal_policy_optimization/README.md)             |✅     |

<p align="center">
    <!-- <img src="https://miro.medium.com/max/2628/0*NJFLO8BSVhZy8XNF.png" width="750"> -->
    <img src="https://miro.medium.com/max/903/1*8OSHpISmR1l79yX4I234wg.jpeg" width="750">
</p>  

# Usefull Resources:
+ https://www.youtube.com/user/stanfordonline
+ https://www.youtube.com/channel/UC58v9cLitc8VaCjrcKyAbrw
+ https://developers.google.com/machine-learning
+ https://machinelearningmastery.com
+ https://gluon.mxnet.io/
+ https://pub.towardsai.net
+ https://atcold.github.io/pytorch-Deep-Learning
+ https://www.datatechnotes.com/

Kind Regards,   
Niek Tuytel  :)
