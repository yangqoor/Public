# Partial Least Squares Regression (PLS)
`Partial least squares regression` (PLS regression) is a statistical method that bears some relation to principal components regression instead of finding hyperplanes of maximum variance between the response and independent variables, it finds a linear regression model by projecting the predicted variables and the observable variables to a new space. Because both the X and Y data are projected to new spaces, the PLS family of methods are known as bilinear factor models. `Partial least squares discriminant analysis` (PLS-DA) is a variant used when the Y is categorical.

PLS is used to find the fundamental relations between two matrices (X and Y), i.e. a latent variable approach to modeling the covariance structures in these two spaces. A PLS model will try to find the multidimensional direction in the X space that explains the maximum multidimensional variance direction in the Y space. PLS regression is particularly suited when the matrix of predictors has more variables than observations, and when there is multicollinearity among X values. By contrast, standard regression will fail in these cases (unless it is regularized).

`Partial least squares` was introduced by the Swedish statistician Herman O. A. Wold, who then developed it with his son, Svante Wold. An alternative term for PLS (and more correct according to Svante Wold) is projection to latent structures, but the term partial least squares is still dominant in many areas. Although the original applications were in the social sciences, PLS regression is today most widely used in chemometrics and related areas. It is also used in bioinformatics, sensometrics, neuroscience, and anthropology.

## Code
[`python3 sample.py`](./sample.py)
<p align="center">
  <img src="https://www.ericrscott.com/project/pls-ecology/featured.png" width="500">
</p>   
<p align="center">
  <img src="http://imdevsoftware.files.wordpress.com/2013/02/clipboard04.png?w=500" width="500">
</p>   
<p align="center">
  <img src="https://cdn.technologynetworks.com/tn/images/body/juuu1538567366342.png" width="500">
</p>   

# Resources
- https://www.kaggle.com/phamvanvung/partial-least-squares-regression-in-python
- https://support.minitab.com/en-us/minitab/18/help-and-how-to/modeling-statistics/regression/supporting-topics/partial-least-squares-regression/what-is-partial-least-squares-regression/
- https://stats.stackexchange.com/questions/461752/partial-least-squares-using-python-understanding-predictions
- https://www.frontiersin.org/articles/10.3389/fnins.2019.01282/full
- https://personal.utdallas.edu/~herve/Abdi-PLS-pretty.pdf

