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

class single_measurement_vector():
    def __init__(self):
        pass

    # main_function. X is the design matrix. Y is the observation vector.
    # algorithm has currently support only for 'OMP' and 'LASSO'.
    # alpha_list is the list of values of RRT-parameters $\alpha$ for which the estimate to be computed. $alpha=0.1$ is the default choice.
    def compute_signal_and_support(self,X,Y,algorithm='OMP',alpha_list=[0.1]):
        self.Y=Y;self.X=X; nsamples,nfeatures=X.shape; 
        self.kmax=np.min([nfeatures,np.int(np.floor(0.5*(nsamples+1)))]);
        self.nsamples=nsamples;self.nfeatures=nfeatures;self.alpha_list=alpha_list
        res_ratio,ordered_support_estimate_sequence=self.generate_residual_ratios(X,Y,algorithm)
        ## the following two lines perform RRT on the generated residual ratios
        rrt=residual_ratio_thresholding(self.nsamples,self.nfeatures,alpha_list=self.alpha_list,
                                nchannels=1,block_size=1,scenario='SMV')
        results=rrt.estimate_support(ordered_support_estimate_sequence,res_ratio)
        
        estimate_support_dict={}
        for alpha in alpha_list:
            est_alpha={}
            support_estimate=results[alpha]
            est_alpha['support_estimate']=support_estimate
            B_est= self.generate_estimate_from_support(X,Y,support=support_estimate)
            est_alpha['signal_estimate']=B_est
            estimate_support_dict[alpha]=est_alpha
        return estimate_support_dict
            
            
    def generate_residual_ratios(self,X,Y,algorithm):
        # the following code provide residual ratios and ordered support estimate sequences for the main code.
        if algorithm=='OMP':
            res_ratio,ordered_support_estimate_sequence=self.OMP_run()
        elif algorithm=='LASSO':
            res_ratio,ordered_support_estimate_sequence=self.LASSO_run()
        else:
            # if you want to add a new function other than OMP and LASSO add that function here
            print('invalid algorithm')
        return res_ratio,ordered_support_estimate_sequence

    # the following code generate LS estimate based on a support estimate
    def generate_estimate_from_support(self,X,Y,support):
        Xt=X[:,support]
        Beta_est=np.zeros((self.nfeatures,1))
        Beta_est[support]=np.matmul(lin.pinv(Xt),Y)
        return Beta_est
    # the following code run OMP for kmax iterations and generate residual ratios and support estimate sequences.
    def OMP_run(self):
        X=self.X;Y=self.Y;kmax=self.kmax; 
        res_ratio=[]
        res_norm=[]
        res_norm.append(lin.norm(Y))
        res=Y # initialize the residual with observation
        ordered_support_estimate_sequence=[]
        flag=0;
        for k in range(kmax):
            correlation=np.abs(np.matmul(X.T,res)) # correlation between X and residual
            ind=np.argmax(correlation) # column most correlated with residual
            ordered_support_estimate_sequence.append(ind)
            Xk=X[:,ordered_support_estimate_sequence].reshape((self.nsamples,k+1))
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
                print('Ill conditioned matrix. OMP stop at iteration:' + str(k))
                flag = 1;
                break;
                
        if flag==1:
            # RRT assumes residual ratios of fixed size kmax. hence, if OMP_run could not run kmax iterations, append 1 to residual ratios.
            while len(res_ratio)!=kmax:
                res_ratio.append(1)
            while len(ordered_support_estimate_sequence)!=kmax:
                ordered_support_estimate_sequence.append(ordered_support_estimate_sequence[-1])
        return res_ratio,ordered_support_estimate_sequence

    # baseline. Run OMP with a priori knowledge of sparsity.
    def OMP_prior_sparsity(self,X,Y,sparsity):
        res=Y # initialize the residual with observation
        support_estimate=[]
        flag=0;
        for k in range(sparsity):
            correlation=np.abs(np.matmul(X.T,res))
            ind=np.argmax(correlation)
            support_estimate.append(ind)
            Xk=X[:,support_estimate].reshape((self.nsamples,k+1))
            try:
                Xk_pinv = lin.pinv(Xk)
                Beta_est = np.zeros((self.nfeatures, 1))
                Beta_est[support_estimate] = np.matmul(Xk_pinv, Y)
                res = Y - np.matmul(X, Beta_est)
            except:
                print('Ill conditioned matrix. OMP stop at iteration:' + str(k))
                flag = 1;
                break;
        return support_estimate,Beta_est

    # algorithms like OMP generate monotonic support sequences as RRT accepts. LASSO and many other algorithms generate non monotonic supports. the following
    # function generate monotonic support sequence from non monotonic support sequences.
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

    # algorithms like OMP compute residual ratios as a part of algorithm itself. For algorithms like LASSO, we have to generate ordered support sequences
    # and based on these ordered support sequences we have to generate residual ratios base don these ordered support sequences.
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
                Beta_est = np.zeros((self.nfeatures, 1))
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
    
    # compute the required residual ratios using LASSO regularization path.
    def LASSO_run(self):
        X=self.X;Y=self.Y
        _, _, coefs = linear_model.lars_path(X, Y.reshape((self.nsamples,)), method='lasso', verbose=False)
        nfeatures,nodes=coefs.shape
        support_estimate_sequence=[]
        for k in np.arange(nodes):
            support_k=np.where(np.abs(coefs[:,k])>1e-8)[0]
            support_estimate_sequence.append(support_k.tolist())
        ordered_support_estimate_sequence=self.generate_ordered_sequence(support_estimate_sequence)
        res_ratio=self.res_ratios_from_ordered_sequence(ordered_support_estimate_sequence)
        return res_ratio,ordered_support_estimate_sequence

    # utility function. compute l2 error and support recovery error
    def compute_error(self,support_true,support_estimate,Beta_true,Beta_estimate):
        Beta_true=np.squeeze(Beta_true); Beta_estimate=np.squeeze(Beta_estimate);
        support_true=set(support_true); support_estimate=set(support_estimate)
        l2_error=lin.norm(Beta_true-Beta_estimate)
        if support_true==support_estimate:
            support_error=0;
        else:
            support_error=1;
        return support_error,l2_error
    #utility function: generate random example using user specified parameters.
    def generate_random_example(self,nsamples,nfeatures,sparsity,SNR_db):
        X=np.random.randn(nsamples,nfeatures)
        X=X/lin.norm(X,axis=0)
        Beta=np.zeros((nfeatures,1))
        Beta[:sparsity]=np.sign(np.random.randn(sparsity,1))
        signal=np.matmul(X,Beta)
        signal_power=sparsity;
        #noise_power=nsamples*noise varaince. snr=signal_power/noise_power
        snr=10**(SNR_db/10)
        noisevar=signal_power/(nsamples*snr)
        Y=signal+np.random.randn(nsamples,1)*np.sqrt(noisevar)
        support=[np.int(k) for k in np.arange(sparsity)]
        return X,Y,Beta,support,noisevar
