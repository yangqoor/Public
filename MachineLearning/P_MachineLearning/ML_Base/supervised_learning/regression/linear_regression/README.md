# Linear Regression
`Linear regression` models are used to show or predict the relationship between two variables or factors. There are 2 types of Linear Regressions.  
- Single Linear Regression  
(single `independent` variable (input) and a corresponding `dependent` variable (output))  
- Multiple Linear Regression  
(one continuous `dependent` variable and two or more `independent` variables)  

`Single Linear Regression` attempts to find the relationship between a single independent variable (input) and a corresponding dependent variable (output). This can be expressed in the form of a straight line.

`Multiple Linear Regression` attempts to model the relationship between two or more features and a response by fitting a linear equation to observed data. The steps to perform `multiple linear Regression` are almost similar to that of `single linear Regression`. The Difference Lies in the `evaluation`. We can use it to find out which factor has the highest impact on the predicted output and now different variable relate to each other. We are required to rescale our data, when some values are way different than other values, this can lead to that the average value is not average on the graph ([`brouder explanation`](https://github.com/niektuytel/ML_Algorithms/gradient_descent#scaling))  


To understand `Linear Regression` it would be nice to read first how [`Gradient Descent`](https://github.com/niektuytel/ML_Algorithms/gradient_descent) is working.

## Code
[`python3 sample_single.py`](./sample_single.py)  
[`python3 sample_multiply.py`](./sample_multiply.py)  

<p align="center">
  <img src="https://i.stack.imgur.com/SbqXz.png" width="500">
</p>
<p align="center">
  <img src="https://www.upgrad.com/blog/wp-content/uploads/2020/10/Untitled-5.jpg" width="500">
</p>
<p align="center">
  <img src="https://sds-platform-private.s3-us-east-2.amazonaws.com/uploads/38_blog_image_1.png" width="500">
</p>

# Resources:
+ https://youtu.be/nk2CQITm_eo
+ http://www.stat.yale.edu/Courses/1997-98/101/linreg.htm
+ https://www.jmp.com/en_ch/statistics-knowledge-portal/what-is-multiple-regression/fitting-multiple-regression-model.html
+ https://towardsdatascience.com/simple-and-multiple-linear-regression-with-python-c9ab422ec29c (use incognito)