# credit: https://github.com/yromano/cqr
# #####################################################################################################
# ##                   The Dynamic Gradient Boosting case of quantile regression                     ##
# #####################################################################################################
import numpy as np
import matplotlib.pyplot as plt
from sklearn.ensemble import GradientBoostingRegressor

def predict(x):
    """ The function to predict. """
    return x * np.sin(x)

def sample():
    #----------------------------------------------------------------------
    #  First the noiseless case
    X = np.atleast_2d(np.random.uniform(0, 10.0, size=100)).T
    X = X.astype(np.float32)

    # Observations
    y = predict(X).ravel()

    np.random.seed(1)
    dy = 1.5 + 1.0 * np.random.random(y.shape)
    noise = np.random.normal(0, dy)
    y += noise
    y = y.astype(np.float32)

    # Mesh the input space for evaluations of the real function, the prediction and
    # its MSE
    xx = np.atleast_2d(np.linspace(0, 10, 1000)).T
    xx = xx.astype(np.float32)

    alpha = 0.95
    clf = GradientBoostingRegressor(
        loss = 'quantile', 
        alpha = alpha,
        n_estimators = 250, 
        max_depth = 3,
        learning_rate = .1, 
        min_samples_leaf = 9,
        min_samples_split = 9
    )

    clf.fit(X, y)

    # Make the prediction on the meshed x-axis
    y_upper = clf.predict(xx)

    clf.set_params(alpha=1.0 - alpha)
    clf.fit(X, y)

    # Make the prediction on the meshed x-axis
    y_lower = clf.predict(xx)

    clf.set_params(loss='ls')
    clf.fit(X, y)

    # Make the prediction on the meshed x-axis
    y_pred = clf.predict(xx)

    # Plot the function, the prediction and the 95% confidence interval based on
    # the MSE
    fig = plt.figure()
    plt.plot(xx, predict(xx), 'g:', label=r'$predict(x) = x\,\sin(x)$')
    plt.plot(X, y, 'b.', markersize=10, label=u'Observations')
    plt.plot(xx, y_pred, 'r-', label=u'Prediction')
    plt.plot(xx, y_upper, 'k-')
    plt.plot(xx, y_lower, 'k-')
    plt.fill(np.concatenate([xx, xx[::-1]]),
            np.concatenate([y_upper, y_lower[::-1]]),
            alpha=.5, fc='b', ec='None', label='95% prediction interval')
    plt.xlabel('$x$')
    plt.ylabel('$f(x)$')
    plt.ylim(-10, 20)
    plt.legend(loc='upper left')
    plt.show()

if __name__ == "__main__":
    sample()


# #####################################################################################################
# ##                     The Dynamic Random Forest case of quantile regression                       ##
# #####################################################################################################

# import matplotlib.pyplot as plt
# import numpy as np
# from sklearn.datasets import load_boston
# from sklearn.model_selection import train_test_split
# from sklearn.model_selection import KFold
# from skgarden import RandomForestQuantileRegressor

# boston = load_boston()
# X, y = boston.data, boston.target
# kf = KFold(n_splits=5, random_state=0)
# rfqr = RandomForestQuantileRegressor(
#     random_state=0, min_samples_split=10, n_estimators=1000)

# y_true_all = []
# lower = []
# upper = []

# for train_index, test_index in kf.split(X):
#     X_train, X_test, y_train, y_test = (
#         X[train_index], X[test_index], y[train_index], y[test_index])

#     rfqr.set_params(max_features=X_train.shape[1] // 3)
#     rfqr.fit(X_train, y_train)
#     y_true_all = np.concatenate((y_true_all, y_test))
#     upper = np.concatenate((upper, rfqr.predict(X_test, quantile=98.5)))
#     lower = np.concatenate((lower, rfqr.predict(X_test, quantile=2.5)))

# interval = upper - lower
# sort_ind = np.argsort(interval)
# y_true_all = y_true_all[sort_ind]
# upper = upper[sort_ind]
# lower = lower[sort_ind]
# mean = (upper + lower) / 2

# # Center such that the mean of the prediction interval is at 0.0
# y_true_all -= mean
# upper -= mean
# lower -= mean

# plt.plot(y_true_all, "ro")
# plt.fill_between(
#     np.arange(len(upper)), lower, upper, alpha=0.2, color="r",
#     label="Pred. interval")
# plt.xlabel("Ordered samples.")
# plt.ylabel("Values and prediction intervals.")
# plt.xlim([0, 500])
# plt.show()



# #####################################################################################################
# ##                              LAD way of quantile regression                                     ##
# #####################################################################################################
# import numpy as np
# import pandas as pd
# import statsmodels.api as sm
# import statsmodels.formula.api as smf
# import matplotlib.pyplot as plt


# def fit_model(mode, q):
#     res = mod.fit(q=q)
#     return [q, res.params['Intercept'], res.params['income']] + res.conf_int().loc['income'].tolist()


# # Get File
# data = sm.datasets.engel.load_pandas().data
# data.head()

# ## Least Absolute Deviation
# #
# # The LAD model is a special case of quantile regression where q=0.5
# mod = smf.quantreg('foodexp ~ income', data)
# res = mod.fit(q=.5)
# print(res.summary())

# # ## Visualizing the results
# #
# # We estimate the quantile regression model for many quantiles between .05
# # and .95, and compare best fit line from each of these models to Ordinary
# # Least Squares results.

# # ### Prepare data for plotting
# #
# # For convenience, we place the quantile regression results in a Pandas
# # DataFrame, and the OLS results in a dictionary.

# quantiles = np.arange(.05, .96, .1)

# models = [fit_model(mod, x) for x in quantiles]
# models = pd.DataFrame(models, columns=['q', 'a', 'b', 'lb', 'ub'])

# ols = smf.ols('foodexp ~ income', data).fit()
# ols_ci = ols.conf_int().loc['income'].tolist()
# ols = dict(
#     a=ols.params['Intercept'],
#     b=ols.params['income'],
#     lb=ols_ci[0],
#     ub=ols_ci[1])

# print(models)
# print(ols)

# # ### First plot
# #
# # This plot compares best fit lines for 10 quantile regression models to
# # the least squares fit. As Koenker and Hallock (2001) point out, we see
# # that:
# #
# # 1. Food expenditure increases with income
# # 2. The *dispersion* of food expenditure increases with income
# # 3. The least squares estimates fit low income observations quite poorly
# # (i.e. the OLS line passes over most low income households)

# x = np.arange(data.income.min(), data.income.max(), 50)
# get_y = lambda a, b: a + b * x

# fig, ax = plt.subplots(figsize=(8, 6))

# for i in range(models.shape[0]):
#     y = get_y(models.a[i], models.b[i])
#     ax.plot(x, y, linestyle='dotted', color='grey')

# y = get_y(ols['a'], ols['b'])

# ax.plot(x, y, color='red', label='OLS')
# ax.scatter(data.income, data.foodexp, alpha=.2)
# ax.set_xlim((240, 3000))
# ax.set_ylim((240, 2000))
# legend = ax.legend()
# ax.set_xlabel('Income', fontsize=16)
# ax.set_ylabel('Food expenditure', fontsize=16)

# # ### Second plot
# #
# # The dotted black lines form 95% point-wise confidence band around 10
# # quantile regression estimates (solid black line). The red lines represent
# # OLS regression results along with their 95% confidence interval.
# #
# # In most cases, the quantile regression point estimates lie outside the
# # OLS confidence interval, which suggests that the effect of income on food
# # expenditure may not be constant across the distribution.

# n = models.shape[0]
# p1 = plt.plot(models.q, models.b, color='black', label='Quantile Reg.')
# p2 = plt.plot(models.q, models.ub, linestyle='dotted', color='black')
# p3 = plt.plot(models.q, models.lb, linestyle='dotted', color='black')
# p4 = plt.plot(models.q, [ols['b']] * n, color='red', label='OLS')
# p5 = plt.plot(models.q, [ols['lb']] * n, linestyle='dotted', color='red')
# p6 = plt.plot(models.q, [ols['ub']] * n, linestyle='dotted', color='red')
# plt.ylabel(r'$\beta_{income}$')
# plt.xlabel('Quantiles of the conditional food expenditure distribution')
# plt.legend()
# plt.show()