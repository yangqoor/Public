# Reverse filtering for deblurring 
Python code implementing five reverse filtering (or defiltering) schemes for noisy image deblurring described in the following [paper](https://www.sciencedirect.com/science/article/pii/S0923596522001242). 

## Dependencies
The code depends on a few common Python libraries (NumPy, ...). Install them via ```pip``` and the provided ```requirements.txt``` file. 
For example 
```bash
$ python -m venv bbdeblur_venv
$ ./bbdeblur_venv/Scripts/activate
$ pip install -r requirements.txt
```

## How to run? 
One possibility is to execute the scripts in the sub-directory ```src``` 
```bash
$ cd src
$ python test_color.py
```

Another possibility is to use the Python notebook, provided in the sub-directory ```notebooks```. The notebook works on Google Colab (with the default installation). 

## Notes 
See also the original (and more complete) MATLAB implementation in this [repo](https://github.com/fayolle/bbDeblur). 

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
