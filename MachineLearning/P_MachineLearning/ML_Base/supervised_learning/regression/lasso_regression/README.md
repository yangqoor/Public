# Lasso Regression
The `“LASSO”` stands for `Least Absolute Shrinkage and Selection Operator`. `Lasso regression` is a regularization technique. It is used over regression methods for a more accurate prediction. This model uses shrinkage. Shrinkage is where data values are shrunk towards a central point as the mean. The lasso procedure encourages simple, sparse models (i.e. models with fewer parameters).  
This particular type of regression is well-suited for models showing high levels of multicollinearity or when you want to automate certain parts of model selection, like variable selection/parameter elimination.

`Lasso Regression` uses L1 regularization technique (will be discussed later in this article).  
It is used when we have more number of features because it automatically performs feature selection.  
([brouder explanation](https://analyticsindiamag.com/lasso-regression-in-python-with-machinehack-data-science-hackathon/))

## Code
[`python3 sample.py`](./sample.py)
<p align="center">
  <img src="https://miro.medium.com/max/1936/1*y-ZuKVAAvjc63jdg9TISQg.png" width="500">
</p>
<p align="center">
  <img src="https://miro.medium.com/max/2802/1*1X_5VpDYfMx_-K9_0h_QhQ.png" width="500">
</p>
<p align="center">
  <img src="https://i.stack.imgur.com/DnYAJ.png" width="750">
</p>

## Resources
- https://analyticsindiamag.com/lasso-regression-in-python-with-machinehack-data-science-hackathon/
- https://machinelearningmastery.com/lasso-regression-with-python/
- https://bookdown.org/tpinto_home/Regularisation/lasso-regression.html
- https://www.mygreatlearning.com/blog/understanding-of-lasso-regression/