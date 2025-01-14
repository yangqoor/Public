import numpy as np
import numpy.linalg as lin
import numpy.random as random
import scipy as sci
import matplotlib.pyplot as plt
from scipy import special
from scipy.linalg import hadamard
import os,sys
os.getcwd()
from sklearn import linear_model
import warnings
warnings.filterwarnings('ignore')
sys.path.insert(0, os.path.realpath('.'))
from codes.residual_ratio_thresholding import residual_ratio_thresholding

class model_order_selection():
    def __init__(self):
        pass

    # main_function. X is the design matrix. Y is the observation vector.
    # algorithm has currently support only for 'OMP' and 'LASSO'.
    # alpha_list is the list of values of RRT-parameters $\alpha$ for which the estimate to be computed. $alpha=0.1$ is the default choice.
    def compute_model_order(self,X,Y,alpha_list=[0.1]):
        self.Y=Y;self.X=X; nsamples,nfeatures=X.shape;
        if nsamples<=nfeatures:
            raise Exception('MOS specified only when nsamples>nfeatures.')
        self.kmax=nfeatures;
        self.nsamples=nsamples;self.nfeatures=nfeatures;self.alpha_list=alpha_list
        res_ratio,ordered_support_estimate_sequence=self.generate_residual_ratios(X,Y)
        ## the following two lines perform RRT on the generated residual ratios
        rrt=residual_ratio_thresholding(self.nsamples,self.nfeatures,alpha_list=self.alpha_list,
                                nchannels=1,block_size=1,scenario='MOS')
        results=rrt.estimate_support(ordered_support_estimate_sequence,res_ratio)
        # the dictionary where the results are to be kept. the keys of this dictionary are alpha. the values are a dictionary.
        # the keys of this dictionary are support estimate and signal estimate.
        estimate_support_dict={}
        for alpha in alpha_list:
            est_alpha={}
            support_estimate=results[alpha]
            est_alpha['model_order_estimate']=len(support_estimate)
            estimate_support_dict[alpha]=est_alpha
        return estimate_support_dict
            
            
    def generate_residual_ratios(self,X,Y):
        # the following code provide residual ratios and ordered support estimate sequences for the main code.
        X = self.X;
        Y = self.Y;
        kmax = self.kmax;
        res_ratio = []
        res_norm = []
        res_norm.append(lin.norm(Y))
        ordered_support_estimate_sequence = []
        flag = 0;
        for k in range(kmax):
            ordered_support_estimate_sequence.append(k)
            Xk = X[:, ordered_support_estimate_sequence].reshape((self.nsamples, k + 1))
            try:
                # LS estimate
                Xk_pinv = lin.pinv(Xk)
                Beta_est = np.zeros((self.nfeatures, 1))
                Beta_est[ordered_support_estimate_sequence] = np.matmul(Xk_pinv, Y)
                # compute residual using LS estimate
                res = Y - np.matmul(X, Beta_est)
                res_normk = lin.norm(res)
                res_ratio.append(res_normk / res_norm[-1])
                res_norm.append(res_normk)
            except:
                print('Ill conditioned matrix at iteration:' + str(k))
                flag = 1;
                break;

        if flag == 1:
            # RRT assumes residual ratios of fixed size kmax. hence, if OMP_run could not run kmax iterations, append 1 to residual ratios.
            while len(res_ratio) != kmax:
                res_ratio.append(1)
            while len(ordered_support_estimate_sequence) != kmax:
                ordered_support_estimate_sequence.append(ordered_support_estimate_sequence[-1])
        return res_ratio,ordered_support_estimate_sequence


    # baseline. model order selection with plain old AIC and BIC
    def baselines(self,X,Y):
        nfeatures=X.shape[1]; nsamples=X.shape[0]
        cost_aic=[]; cost_bic=[]
        support_estimate=[]
        for k in range(nfeatures):
            support_estimate.append(k)
            Xk=X[:,support_estimate].reshape((self.nsamples,k+1))
            try:
                Xk_pinv = lin.pinv(Xk)
                Beta_est = np.zeros((self.nfeatures, 1))
                Beta_est[support_estimate] = np.matmul(Xk_pinv, Y)
                res = Y - np.matmul(X, Beta_est)
                noise_variance_est=lin.norm(res)**2/nsamples;
                cost_aic.append(nsamples*np.log(noise_variance_est)+2*(k+1))
                cost_bic.append(nsamples * np.log(noise_variance_est) + 2 * (k + 1)*np.log(nsamples))
            except:
                print('Ill conditioned matrix. OMP stop at iteration:' + str(k))
                flag = 1;
                break;
        model_order_aic=np.argmin(cost_aic)+1;
        model_order_bic=np.argmin(cost_bic)+1;
        return model_order_aic,model_order_bic


    # utility function. check whether true model order and estimated model order are same.
    def compute_error(self,model_order_true,model_order_est):
        if np.abs(model_order_true-model_order_est)>1e-1:
            model_order_error=1
        else:
            model_order_error=0
        return model_order_error

    #utility function: generate random example using user specified parameters.
    def generate_random_example(self,nsamples,nfeatures,model_order,SNR_db):
        X=np.random.randn(nsamples,nfeatures)
        X=X/lin.norm(X,axis=0)
        Beta=np.zeros((nfeatures,1))
        Beta[:model_order]=np.sign(np.random.randn(model_order,1))
        signal=np.matmul(X,Beta)
        signal_power=model_order;
        #noise_power=nsamples*noise varaince. snr=signal_power/noise_power
        snr=10**(SNR_db/10)
        noisevar=signal_power/(nsamples*snr)
        Y=signal+np.random.randn(nsamples,1)*np.sqrt(noisevar)
        return X,Y,Beta,model_order,noisevar
