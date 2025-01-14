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

class multiple_measurement_vector():
    def __init__(self):
        pass
    # main_function. X is the design matrix. Y is the observation vector.
    # algorithm has currently support only for 'SOMP'.
    # alpha_list is the list of values of RRT-parameters $\alpha$ for which the estimate to be computed. $alpha=0.1$ is the default choice.
    def compute_signal_and_support(self,X,Y,algorithm='SOMP',alpha_list=[0.1]):
        self.Y=Y;self.X=X; nsamples,nfeatures=X.shape; nchannels=Y.shape[1]
        self.kmax=np.min([nfeatures,np.int(np.floor(0.5*(nsamples+1)))]);
        self.nsamples=nsamples;self.nfeatures=nfeatures;self.alpha_list=alpha_list
        self.nchannels=nchannels
        res_ratio,ordered_support_estimate_sequence=self.generate_residual_ratios(X,Y,algorithm)
        # the following two lines compute residual ratio thresholding from the residual ratios generated.
        rrt=residual_ratio_thresholding(self.nsamples,self.nfeatures,alpha_list=self.alpha_list,
                                nchannels=self.nchannels,block_size=1,scenario='MMV')
        results=rrt.estimate_support(ordered_support_estimate_sequence,res_ratio)
        
        estimate_support_dict={}
        # the dictionary where the results are to be kept. the keys of this dictionary are alpha. the values are a dictionary.
        # the keys of this dictionary are support estimate and signal estimate.
        for alpha in alpha_list:
            est_alpha={}
            support_estimate=results[alpha]
            est_alpha['support_estimate']=support_estimate
            B_est= self.generate_estimate_from_support(X,Y,support=support_estimate)
            est_alpha['signal_estimate']=B_est
            estimate_support_dict[alpha]=est_alpha
        return estimate_support_dict
            
            
    def generate_residual_ratios(self,X,Y,algorithm):
        # this function provides residual ratios for the main function
        if algorithm=='SOMP':
            res_ratio,ordered_support_estimate_sequence=self.SOMP_run()
        else:
            # if you want to add a new function other than SOMP add that function here
            print('invalid algorithm')
        return res_ratio,ordered_support_estimate_sequence
    
    def generate_estimate_from_support(self,X,Y,support):
        # generate the LS estimate of B from a user provided support
        Xt=X[:,support]
        Beta_est=np.zeros((self.nfeatures,self.nchannels))
        Beta_est[support,:]=np.matmul(lin.pinv(Xt),Y)
        return Beta_est

    # run kmax iterations of SOMP and produce residual ratios
    def SOMP_run(self):
        X=self.X;Y=self.Y;kmax=self.kmax; 
        res_ratio=[]
        res_norm=[]
        res_norm.append(lin.norm(Y))
        res=Y # initialize the residual with observation
        ordered_support_estimate_sequence=[]
        flag=0;
        for k in range(kmax):
            correlation=np.matmul(X.T,res) # unlike OMP, correlation is a matrix of size nfeatures times nchannels
            corrnorm = np.sqrt(np.sum(np.square(correlation), axis=1)) # take the frobenius norm of correlations corresponding to each features. you can try different norms here.
            ind = np.argmax(corrnorm) # find the feature with maximum correlation with  residual as measured by frobenius norm.
            ordered_support_estimate_sequence.append(ind)
            Xk=X[:,ordered_support_estimate_sequence].reshape((self.nsamples,k+1))
            try:
                # LS estimate
                Xk_pinv = lin.pinv(Xk)
                Beta_est = np.zeros((self.nfeatures, self.nchannels))
                Beta_est[ordered_support_estimate_sequence] = np.matmul(Xk_pinv, Y)
                # compute residuals
                res = Y - np.matmul(X, Beta_est)
                res_normk = lin.norm(res)  # frobenius norm . res is a matrix of size nsamples times nchannels
                res_ratio.append(res_normk / res_norm[-1])
                res_norm.append(res_normk)
            except:
                print('Ill conditioned matrix. OMP stop at iteration:' + str(k))
                flag = 1;
                break;

                
        if flag==1:
            # RTT expects residual ratios of fixed size kmax. If kmax iterations are not possible, just append 1 to residual ratios to make size kmax.
            while len(res_ratio)!=kmax:
                res_ratio.append(1)
            while len(ordered_support_estimate_sequence)!=kmax:
                ordered_support_estimate_sequence.append(ordered_support_estimate_sequence[-1])
        return res_ratio,ordered_support_estimate_sequence
    # baseline: RUN SOMP with a user specified sparsity
    def SOMP_prior_sparsity(self,X,Y,sparsity):
        res=Y # initialize the residual with observation
        support_estimate=[]
        flag=0;
        for k in range(sparsity):
            correlation=np.abs(np.matmul(X.T,res))
            corrnorm = np.sqrt(np.sum(np.square(correlation), axis=1))
            ind = np.argmax(corrnorm)
            support_estimate.append(ind)
            Xk=X[:,support_estimate].reshape((self.nsamples,k+1))
            try:
                Xk_pinv = lin.pinv(Xk)
                Beta_est = np.zeros((self.nfeatures, self.nchannels))
                Beta_est[support_estimate] = np.matmul(Xk_pinv, Y)
                res = Y - np.matmul(X, Beta_est)
            except:
                print('Ill conditioned matrix. SOMP stop at iteration:' + str(k))
                flag = 1;
                break;
        return support_estimate,Beta_est

    # SOMP generates monotonic support sequences. For non monotonic algorithms, we have to convert the non monotonic support sequence to monotnic support sequences.
    # this function does that
    def generate_ordered_sequence(self,support_estimate_sequence,kmax=None):
        if kmax is None:
            kmax=self.kmax;
        nsupports=len(support_estimate_sequence)
        ordered_support_estimate_sequence=[]
        for k in np.arange(nsupports):
            if k==0:
                ordered_support_estimate_sequence=ordered_support_estimate_sequence+support_estimate_sequence[k]
            else:
                diff=[ele for ele in support_estimate_sequence[k]  if ele not in ordered_support_estimate_sequence]
                ordered_support_estimate_sequence=ordered_support_estimate_sequence+diff
        return ordered_support_estimate_sequence[:kmax]

    # SOMP compute residual ratios as a part of it. For non SOMP algorithms, it may be necessary to compute ordered monotonic support sequence from
    # non monotonic squences and you will have to generate the residual ratios based on the ordered support sequence. the following function does that.
    def res_ratios_from_ordered_sequence(self,ordered_support_estimate_sequence):
        X=self.X;
        Y=self.Y;
        kmax=len(ordered_support_estimate_sequence);
        res_ratio=[]
        res_norm=[]
        res_norm.append(lin.norm(Y))
        res=Y # initialize the residual with observation
        
        flag=0;
        for k in range(kmax):
            index=ordered_support_estimate_sequence[:(k+1)]
            Xk=X[:,index].reshape((self.nsamples,len(index)))
            try:
                Xk_pinv = lin.pinv(Xk)
                Beta_est = np.zeros((self.nfeatures, self.nchannels))
                Beta_est[index] = np.matmul(Xk_pinv, Y)
                res = Y - np.matmul(X, Beta_est)
                res_normk = lin.norm(res)
                res_ratio.append(res_normk / res_norm[-1])
                res_norm.append(res_normk)
            except:
                print('Ill conditioned matrix. stop at iteration:' + str(k))
                flag = 1;
                break;
        if flag==1:
            while len(res_ratio)!=kmax:
                res_ratio.append(1)
            
        return res_ratio

   # utility function : compute the frobenis norm between true and estimate B and support recovery error.
    def compute_error(self,support_true,support_estimate,Beta_true,Beta_estimate):
        Beta_true=np.squeeze(Beta_true); Beta_estimate=np.squeeze(Beta_estimate);
        support_true=set(support_true); support_estimate=set(support_estimate)
        l2_error=lin.norm(Beta_true-Beta_estimate)/np.sqrt(Beta_true.shape[1])
        if support_true==support_estimate:
            support_error=0;
        else:
            support_error=1;
        return support_error,l2_error

    # utility function: Generate MMV with user specified parameters.
    def generate_random_example(self,nsamples,nfeatures,nchannels,sparsity,SNR_db):
        X=np.random.randn(nsamples,nfeatures)
        X=X/lin.norm(X,axis=0)
        Beta=np.zeros((nfeatures,nchannels))
        Beta[:sparsity,:]=np.sign(np.random.randn(sparsity,nchannels))
        signal=np.matmul(X,Beta)
        signal_power=sparsity*nchannels;# follows from independence of columns in X and independence of non zero entries. all columns have unit norm
        #noise_power=noisevar*nsamples*nchannels
        snr=10**(SNR_db/10)
        noisevar=signal_power/(nsamples*snr*nchannels)
        
        Y=signal+np.random.randn(nsamples,nchannels)*np.sqrt(noisevar)
        
        support=[np.int(k) for k in np.arange(sparsity)]
        
        return X,Y,Beta,support,noisevar
