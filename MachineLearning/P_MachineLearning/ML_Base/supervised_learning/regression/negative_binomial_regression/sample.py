########################################################################
##                           basic sample                             ##
########################################################################
# https://docs.pymc.io/notebooks/GLM-negative-binomial-regression.html

import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import nbinom

numargs = nbinom.numargs
a, b = 0.2, 0.8
rv = nbinom(a, b)

quantile = np.arange(0.01, 1, 0.1)

# Random Variates
R = nbinom.rvs(a, b, size=10)
print("Random Variates : \n", R)

# datasets
x = np.linspace(nbinom.ppf(0.01, a, b), nbinom.ppf(0.99, a, b), 10)

R = nbinom.ppf(x, 1, 3)
print("\nProbability Distribution : \n", R)

distribution = np.linspace(0, np.minimum(rv.dist.b, 2))
print("\nDistribution : \n", distribution)

# # Graphical Representation.
# plt.plot(distribution, rv.ppf(distribution))

x = np.linspace(0, 5, 100)
y1 = nbinom.ppf(x, a, b)
y2 = nbinom.pmf(x, a, b)

# Varying positional arguments
plt.plot(x, y1, "*", x, y2, "r--")
plt.show()






# ########################################################################
# ##           Bayesian negative binomial regression sample             ##
# ########################################################################
# # https://kieranrcampbell.github.io/blog/2015/03/31/tutorial-bayesian-nb-regression.html
# import numpy as np
# import matplotlib.pyplot as plt
# from scipy.special import gammaln
# from scipy.stats import truncnorm
# import seaborn as sns
# import pylab

# n_iter = 10000
# burn_in = 4000

# sigma_beta_0 = 0.5
# sigma_beta_1 = 0.7
# sigma_r = 0.5


# def nb_acceptance_ratio(theta, theta_p, y, N):
#     """ theta = (mu, r), y  is data, N = len(x) """
#     mu, r = theta
#     mu_p, r_p = theta_p

#     term1 = r_p * np.log(r_p / (r_p + mu_p))
#     term2 = -r * np.log(r / (r + mu))
#     term3 = y * np.log(mu_p / mu * (mu + r) / (mu_p + r_p))

#     term4 = gammaln(r_p + y)
#     term5 = - gammaln(r + y)
#     term6 = N * (gammaln(r) - gammaln(r_p))

#     return (term1 + term2 + term3 + term4 + term5).sum() + term6

# def truncnorm_prop(x, sigma): # proposal for r (non-negative)
#     return truncnorm.rvs(-x / sigma, np.Inf, loc=x, scale=sigma)

# def calculate_mu(beta, x):
#     return beta[0] + beta[1] * x

# def metropolis_hastings(n_iter, bunr_in, thin=5):
#     trace = np.zeros((n_iter, 3))# ordered beta_0 beta_1 r
#     trace[0, :] = np.array([5.0, 5.0, 1.0])
#     acceptance_rate = np.zeros(n_iter)
    
#     # store previous mu to avoid calculating each time
#     mu = calculate_mu(trace[0, 0:2], y)

#     for i in range(1, n_iter):
#         theta = trace[i-1,:] # theta = (beta_0, beta_1, r)
#         theta_p = np.array(
#             [
#                 np.random.normal(theta[0], sigma_beta_0),
#                 np.random.normal(theta[1], sigma_beta_1),
#                 truncnorm_prop(theta[2], sigma_r)

#             ]
#         )

#         mu_p = calculate_mu(theta_p[0:2], x)

#         if np.any(mu <= 0):
#             print("mu == 0 on iteration %d" % i)
        
#         alpha = nb_acceptance_ratio(
#             (mu, theta[2]),
#             (mu_p, theta_p[2]),
#             y, N
#         )

#         u = np.log(np.random.uniform(0.0, 1.0))
#         if u < alpha:
#             trace[i,:] = theta_p
#             mu = mu_p
#             acceptance_rate[i - 1] = 1
#         else:
#             trace[i, :] = theta
    
#     print("Acceptance rate: %.2f" % acceptance_rate[burn_in:].mean())
#     return trace[burn_in::thin,:]
    
    
# # generate data
# sns.set_palette("hls", desat=0.6)
# sns.set_context(rc={"figure.figsize" : (6, 4)})
# np.random.seed(123)

# beta_0 = 10
# beta_1 = 5
# N = 150

# x = np.random.randint(0, 50, N)
# true_mu = beta_0 + beta_1 * x
# true_r = 10
# p = 1 - true_mu / (float(true_r) + true_mu)

# y = np.random.negative_binomial(n=true_r, p=p, size=N)

# # Graphical Representation.
# plt.scatter(x, y, color="black")
# plt.xlabel("x")
# plt.ylabel("y")
# plt.title("150 points generated")

# trace = metropolis_hastings(n_iter, burn_in)

# # Display traces
# pylab.rcParams["figure.figsize"] = (12.0, 8.0)

# plt.subplot(3, 2, 1)
# plt.plot(trace[:, 0])
# plt.title("beta_0")

# plt.subplot(3, 2, 2)
# plt.hist(trace[:, 0])

# plt.subplot(3, 2, 3)
# plt.plot(trace[:, 1])
# plt.title("beta_1")

# plt.subplot(3, 2, 4)
# plt.hist(trace[:, 1])

# plt.subplot(3, 2, 5)
# plt.plot(trace[:, 2])
# plt.title("r")

# plt.subplot(3, 2, 6)
# plt.hist(trace[:, 2])
# plt.show()