import numpy as np
import numpy.linalg as lin
import numpy.random as random
import scipy as sci
import matplotlib.pyplot as plt
from scipy import special
from scipy.linalg import hadamard
import os, sys

os.getcwd()
from sklearn import linear_model
import warnings

warnings.filterwarnings('ignore')
sys.path.insert(0, os.path.realpath('.'))
from codes.residual_ratio_thresholding import residual_ratio_thresholding

class robust_regression():
    def __init__(self):
        pass

    # main_function. X is the design matrix. Y is the observation vector.
    # algorithm has currently support only for 'OMP' and 'LASSO'.
    # alpha_list is the list of values of RRT-parameters $\alpha$ for which the estimate to be computed. $alpha=0.1$ is the default choice.
    def compute_signal_and_outlier_support(self, X, Y, algorithm='GARD', alpha_list=[0.1]):
        self.Y = Y;
        self.X = X;
        nsamples, nfeatures = X.shape;
        if nsamples<nfeatures:
            raise Exception('nsamples>nfeatures. This code is for low dimesnional robust regression')
        self.kmax = np.int(0.5*(nsamples-nfeatures+1));
        self.nsamples = nsamples;
        self.nfeatures = nfeatures;
        self.alpha_list = alpha_list
        # res ratios are based on outlier support estimate sequence
        res_ratio, ordered_support_estimate_sequence = self.generate_residual_ratios(X, Y, algorithm)
        ## the following two lines perform RRT on the generated residual ratios
        rrt = residual_ratio_thresholding(self.nsamples, self.nfeatures, alpha_list=self.alpha_list,
                                          nchannels=1, block_size=1, scenario='robust_regression')
        results = rrt.estimate_support(ordered_support_estimate_sequence, res_ratio)
        
        estimate_support_dict = {}
        # the dictionary where the results are to be kept. the keys of this dictionary are alpha. the values are a dictionary.
        # the keys of this dictionary are support estimate and signal estimate.
        for alpha in alpha_list:
            est_alpha = {}
            outlier_support_estimate = results[alpha]
            est_alpha['outlier_support_estimate'] = outlier_support_estimate
            B_est = self.generate_estimate_from_outlier_support(X=X, Y=Y, support=outlier_support_estimate)[0]
            est_alpha['signal_estimate'] = B_est
            estimate_support_dict[alpha] = est_alpha
        return estimate_support_dict

    def generate_residual_ratios(self, X, Y, algorithm):
        # the following code provide residual ratios and ordered support estimate sequences for the main code.
        if algorithm == 'GARD':
            res_ratio, ordered_support_estimate_sequence = self.GARD_run()
        else:
            # if you want to add a new function other than OMP and LASSO add that function here
            print('invalid algorithm')
        return res_ratio, ordered_support_estimate_sequence

    # the following code generate the joint LS estimate of required signal and outlier whose support is given.
    # it also produce the residual corresponding the joint LS estimate
    def generate_estimate_from_outlier_support(self, X, Y, support):
        nsamples=X.shape[0];nfeatures=X.shape[1]
        Xt = np.hstack([X,np.eye(nsamples)[:,support]])
        signal_outlier_est = np.matmul(lin.pinv(Xt),Y)
        res=Y-np.matmul(Xt,signal_outlier_est)
        Beta_est=signal_outlier_est[:nfeatures]
        return Beta_est,res

    # the following code generate the LS estimate and the correspoding residuals.
    # this is also a good baseline. an outlier agnostic LS estimate.
    def generate_LS_estimate_and_residual(self, X, Y):
        signal_est = np.matmul(lin.pinv(X),Y)
        residual=Y-np.matmul(X,signal_est)
        return signal_est,residual


    # the following code run GARD for kmax iterations and generate residual ratios and support estimate sequences.
    def GARD_run(self):
        X = self.X;
        Y = self.Y;
        kmax = self.kmax;
        res_ratio = []
        res_norm = []
        res=self.generate_LS_estimate_and_residual(X=X,Y=Y)[1]
        res_norm.append(lin.norm(res))
        ordered_support_estimate_sequence = [] # outlier support estimate
        flag = 0;
        for k in range(kmax):
            ind = np.argmax(np.abs(res))  # find the largest residual
            ordered_support_estimate_sequence.append(ind)
            try:
                Beta_est,res=self.generate_estimate_from_outlier_support(X=X, Y=Y, support=ordered_support_estimate_sequence)
                # compute residual using LS estimate
                res_normk = lin.norm(res)
                res_ratio.append(res_normk / res_norm[-1])
                res_norm.append(res_normk)
            except:
                print('Ill conditioned matrix. GARD stopped at iteration:' + str(k))
                flag = 1;
                break;

        if flag == 1:
            # RRT assumes residual ratios of fixed size kmax. hence, if OMP_run could not run kmax iterations, append 1 to residual ratios.
            while len(res_ratio) != kmax:
                res_ratio.append(1)
            while len(ordered_support_estimate_sequence) != kmax:
                ordered_support_estimate_sequence.append(ordered_support_estimate_sequence[-1])
        return res_ratio, ordered_support_estimate_sequence

    # the following code run GARD for outlier_sparsity iterations and generate the signal estimate and outlier support
    def GARD_prior_outlier_sparsity(self,X,Y,outlier_sparsity):
        res = self.generate_LS_estimate_and_residual(X=X, Y=Y)[1]
        ordered_support_estimate_sequence = []  # outlier support estimate
        flag = 0;
        for k in range(outlier_sparsity):
            ind = np.argmax(np.abs(res))  # find the largest residual
            ordered_support_estimate_sequence.append(ind)
            try:
                Beta_est, res = self.generate_estimate_from_outlier_support(X=X, Y=Y,
                                                                            support=ordered_support_estimate_sequence)
            except:
                print('Ill conditioned matrix. GARD stopped at iteration:' + str(k))
                flag = 1;
                break;
        return Beta_est, ordered_support_estimate_sequence

    # utility function. compute l2 error and outlier support recovery error
    def compute_error(self, outlier_support_true, outlier_support_estimate, Beta_true, Beta_estimate):
        Beta_true = np.squeeze(Beta_true);
        Beta_estimate = np.squeeze(Beta_estimate);
        outlier_support_true = set(outlier_support_true);
        outlier_support_estimate = set(outlier_support_estimate)
        l2_error = lin.norm(Beta_true - Beta_estimate)
        if outlier_support_true == outlier_support_estimate:
            support_error = 0;
        else:
            support_error = 1;
        return support_error, l2_error

    # utility function: generate random example using user specified parameters.
    # SNR is the ratio of signal power to inlier noise.
    # OIR is the ratio of outlier to inlier power ratio.
    def generate_random_example(self, nsamples, nfeatures, outlier_sparsity, SNR_db,OIR_db):
        X = np.random.randn(nsamples, nfeatures)
        X = X / lin.norm(X, axis=0)
        Beta = np.sign(np.random.randn(nfeatures, 1))
        signal = np.matmul(X, Beta)
        signal_power = nfeatures;
        # inlier_noise_power=nsamples*inlier_noise varaince. snr=signal_power/inlier_noise_power
        snr = 10 ** (SNR_db / 10)
        inlier_noisevar = signal_power / (nsamples * snr)
        inlier=np.random.randn(nsamples, 1) * np.sqrt(inlier_noisevar)

        oir=10**(OIR_db/10)
        inlier_power=nsamples*inlier_noisevar
        # outlier power=(outlier_magnitude**2)*outlier_sparsity
        outlier_magnitude=np.sqrt(oir*inlier_power/outlier_sparsity)
        outlier=np.zeros((nsamples,1))
        ind=np.random.choice(nsamples,outlier_sparsity,replace=False)
        outlier[ind]=outlier_magnitude*np.sign(np.random.randn(outlier_sparsity,1))
        Y = signal + inlier+outlier
        outlier_support = [np.int(k) for k in ind]
        return X, Y, Beta, outlier_support, outlier,inlier_noisevar
