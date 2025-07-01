# Reverse filtering for deblurring 
MATLAB code implementing the five reverse filtering (or defiltering) schemes for noisy image deblurring described in the following [paper](https://www.sciencedirect.com/science/article/pii/S0923596522001242). 

## Examples 
Examples of use are shown in the demo scripts ```demo.m```, ```demo_color.m```, ... 

## Dependencies 
The optional function ```denoise``` relies on Mathwork's deep learning toolbox. 

## Notes
See also the Python implementation in this [repo](https://github.com/fayolle/bbDeblur_py). 

## Reference 
Link to the [paper](https://www.sciencedirect.com/science/article/pii/S0923596522001242) where the methods were introduced. The corresponding bibtex entry is  
```
@article{Belyaev2022,
title = {Black-box image deblurring and defiltering},
author = {Belyaev, Alexander G. and Fayolle, Pierre-Alain},
journal = {Signal Processing: Image Communication},
pages = {116833},
year = {2022},
issn = {0923-5965},
doi = {https://doi.org/10.1016/j.image.2022.116833},
url = {https://www.sciencedirect.com/science/article/pii/S0923596522001242},
keywords = {Deblurring, Defiltering, Reverse filtering},
}
```
