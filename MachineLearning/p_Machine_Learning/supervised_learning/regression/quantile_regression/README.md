# Quantile Regression  
Quantile regression is an extension of `Standard linear regression`, which estimates the conditional median of the outcome variable and can be used when assumptions of `linear regression` do not meet.  
Suppose a real estate analyst wants to predict home prices from factors like home age and distance from job centers.  
The typical goal will be generating the best home price point estimate given those factors, where “best” often refers to the estimate that minimizes squared deviations from reality.  
But what if they want to predict not just a single estimate, but also the likely range? This is called the prediction interval, and the general method for producing them is known as `Quantile Regression`.  


## Code
[`python3 sample.py`](./sample.py)
<p align="center">
  <img src="https://www150.statcan.gc.ca/n1/pub/12-001-x/2019002/article/00001/fig/fig2_1-eng.jpg" width="500">
</p>
<p align="center">
  <img src="https://www.lokad.com/public/Upload//Support/Glossary/quantile-demand.png" width="500">
</p>
<p align="center">
  <img src="https://images.slideplayer.com/25/7600807/slides/slide_10.jpg" width="750">
</p>   

# Resources
- https://saattrupdan.github.io/2020-03-09-quantile-regression/
- https://saattrupdan.github.io/2020-04-05-quantile-regression-forests/
- https://www.kaggle.com/editht/quantile-regression-vs-gradient-boosting
- https://www.jmlr.org/papers/volume7/meinshausen06a/meinshausen06a.pdf
- https://support.sas.com/resources/papers/proceedings17/SAS0525-2017.pdf
- https://core.ac.uk/download/pdf/268632093.pdf
- https://scikit-learn.org/stable/auto_examples/ensemble/plot_gradient_boosting_quantile.html
- https://scikit-garden.github.io/examples/QuantileRegressionForests/  
- https://www.kaggle.com/editht/quantile-regression-vs-gradient-boosting
- https://github.com/yromano/cqr
- https://phillipmfeldman.org/Python/quantile_regression_demo.py
- https://stackoverflow.com/questions/51483951/quantile-random-forests-from-scikit-garden-very-slow-at-making-predictions

