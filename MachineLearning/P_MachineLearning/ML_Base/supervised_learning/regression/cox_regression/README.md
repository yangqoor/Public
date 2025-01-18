# Cox Regression (Proportional Hazards Model)
`Cox regression` (or proportional hazards regression) is a method for investigating the effect of several variables upon the time a specified event takes to happen. In the context of an outcome such as death this is known as `Cox regression` for survival analysis. The method does not assume any particular `"survival model"` but it is not truly nonparametric because it does assume that the effects of the predictor variables upon survival are constant over time and are additive in one scale.  

## Code
[`python3 sample.py`](./sample.py)
<p align="center">
  <img src="https://miro.medium.com/max/1400/1*Ckhi9soE9Lx2lIf9tPVLMQ.png" width="500">
</p>
<p align="center">
  <img src="https://slideplayer.com/slide/4902856/16/images/2/Cox+Regression+h%28t%29%2C+represents+how+the+risk+changes+with+time%2C+and+exp+represents+the+effect+of+covariates+%28or+factors%2Ffeatures%29.jpg" width="500">
</p>

## Resources
+ https://webfocusinfocenter.informationbuilders.com/wfappent/TLs/TL_rstat/source/Survival45.htm
- https://www.kaggle.com/bryanb/survival-analysis-with-cox-model-implementation
- https://kowshikchilamkurthy.medium.com/the-cox-proportional-hazards-model-da61616e2e50
- https://www.statsdirect.com/help/survival_analysis/cox_regression.htm
- http://www.sthda.com/english/wiki/cox-proportional-hazards-model
- https://github.com/havakv/pycox/blob/master/examples/01_introduction.ipynb