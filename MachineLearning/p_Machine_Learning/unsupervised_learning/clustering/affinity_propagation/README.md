# Affinity Propagation
[`Affinity Propagation`](https://www.youtube.com/watch?v=NaldkmCouLw) we are using it when we want to group the closest data to each other. By sending messages between pairs of samples until convergence. A dataset is then described using a small number of exemplars, which are identified as those most representative of other samples.  
The messages sent between pairs represent the suitability for one sample to be the exemplar of the other, which is updated in response to the values from other pairs.  
This updating happens iteratively until convergence, at which point the final exemplars are chosen, and than the final clustering is given.

## Code 
[`python3 sample.py`](./sample.py)  
[`python3 sample_scratch.py`](./sample_scratch.py)  
<p align="center">
  <img src="https://www.ritchievink.com/img/post-14-affinity_propagation/preference_median.gif" width="500">
</p>
<p align="center">
  <img src="https://www.researchgate.net/profile/Achmad-Mutiara/publication/321462147/figure/fig1/AS:613935107563543@1523384944757/Message-Passing-in-Affinity-Propagation-4.png" width="500">
</p>

## Resources   
+ https://www.ritchievink.com/blog/2018/05/18/algorithm-breakdown-affinity-propagation/  
+ https://scikit-learn.org/stable/modules/clustering.html#affinity-propagation  
+ https://hdbscan.readthedocs.io/en/latest/comparing_clustering_algorithms.html#affinity-propagation  
+ https://machinelearningmastery.com/clustering-algorithms-with-python/  
+ https://medium.com/@aneesha/using-affinity-propagation-to-find-the-number-of-clusters-in-a-dataset-52f5dd3b0760  
+ https://github.com/abhinavkashyap92/affinity_propagation/blob/master/affinity_prop.py
