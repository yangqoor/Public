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

class block_single_measurement_vector():
    def __init__(self):
        self.norm_order=1 # norm used in the correlation step of Block OMP.
        pass
    # main_function. X is the design matrix. Y is the observation vector. block_size is the size of blocks in unknonw vector B.
    # algorithm has currently support only for 'BMMV-OMP'.
    # alpha_list is the list of values of RRT-parameters $\alpha$ for which the estimate to be computed. $alpha=0.1$ is the default choice.
    def compute_signal_and_support(self,X,Y,block_size,algorithm='BOMP',alpha_list=[0.1]):
        self.Y=Y;self.X=X; nsamples,nfeatures=X.shape;
        self.block_size=block_size;
        self.nblocks=np.int(nfeatures/block_size)
        self.kmax=np.min([self.nblocks,np.int(np.floor(0.5*(nsamples+1)/block_size))]);
        self.nsamples=nsamples;self.nfeatures=nfeatures;self.alpha_list=alpha_list
        ## connection between main code and the underlying algorithm generating residual ratios and ordered block support estimate.
        res_ratio,ordered_block_support_estimate_sequence=self.generate_residual_ratios(X,Y,algorithm)
        ## the following two lines performs RRT on the residual ratios and evaluate support estimate corresponding to each value of alpha in alpha_list.
        rrt=residual_ratio_thresholding(self.nsamples,self.nfeatures,alpha_list=self.alpha_list,
                                nchannels=1,block_size=self.block_size,scenario='BSMV')
        results=rrt.estimate_support(ordered_block_support_estimate_sequence,res_ratio)
        
        estimate_support_dict={}
        # the dictionary where the results are to be kept. the keys of this dictionary are alpha. the values are a dictionary.
        # the keys of this dictionary are support estimate and signal estimate.
        for alpha in alpha_list:
            est_alpha={}
            support_estimate=results[alpha]
            est_alpha['support_estimate']=support_estimate
            B_est= self.generate_estimate_from_support(X,Y,block_support=support_estimate)
            est_alpha['signal_estimate']=B_est
            estimate_support_dict[alpha]=est_alpha
        return estimate_support_dict
            
            
    def generate_residual_ratios(self,X,Y,algorithm):
        # the function that delivers the residual ratios and ordered block support estimate to the main function
        if algorithm=='BOMP':
            res_ratio,ordered_support_estimate_sequence=self.BOMP_run()
        else:
            # if you want to add a new function other than BOMP, add that function here
            print('invalid algorithm')
        return res_ratio,ordered_support_estimate_sequence

    # given a block support estimate produce the corresponding LS estimate.
    def generate_estimate_from_support(self,X,Y,block_support,block_size=None):
        if block_size==None:
            block_size=self.block_size
        support=self.generate_full_support_from_block_support(block_support=block_support,block_size=block_size)
        Xt=X[:,support]
        Beta_est=np.zeros((self.nfeatures,1))
        Beta_est[support]=np.matmul(lin.pinv(Xt),Y) # LS estimate
        return Beta_est

    # produce full support from block support. recall that each block corresponds to block_size  rows in B.
    def generate_full_support_from_block_support(self,block_support,block_size=None):
        if block_size is None:
            block_size=self.block_size
        ind = []
        for i in block_support:
            ind=ind+[j for j in range(i * block_size, (i + 1) * block_size)]
        return ind

    # the function to identify the most correlated block from correlation with residuals. used in BOMP.
    def correlated_block_selection(self,correlation,block_size=None):
        correlation=np.squeeze(correlation)
        if block_size is None:
            block_size=self.block_size
        nfeatures=len(correlation)
        nblocks = np.int(nfeatures / block_size)
        block_norm = np.zeros(nblocks)
        for k in np.arange(nblocks):
            xt = correlation[k * block_size:(k + 1) * block_size]
            block_norm[k] = lin.norm(xt, self.norm_order)
        sel_block = np.argmax(block_norm) # find the most correlated block
        ind = [j for j in range(sel_block * block_size, (sel_block + 1) * block_size)] # indices corresponding the selected block
        ind_b = sel_block
        return ind_b, ind

    # the function to run BOMP for kmax number of iterations and produce residual ratios and ordered block support estimate sequence.
    def BOMP_run(self):
        X=self.X;Y=self.Y;kmax=self.kmax; block_size=self.block_size;
        res_ratio=[]
        res_norm=[]
        res_norm.append(lin.norm(Y))
        res=Y # initialize the residual with observation
        ordered_support_estimate_sequence=[];ordered_block_support_estimate_sequence=[];
        flag=0;
        for k in range(kmax):
            correlation=np.matmul(X.T,res) # correlation between columns in X and residual
            selected_block,indices_in_block=self.correlated_block_selection(correlation) # find the most correlated block.
            ordered_block_support_estimate_sequence.append(selected_block);
            ordered_support_estimate_sequence=ordered_support_estimate_sequence+indices_in_block
            Xk=X[:,ordered_support_estimate_sequence].reshape((self.nsamples,(k+1)*block_size))
            try:
                # LS esitmate
                Xk_pinv = lin.pinv(Xk)
                Beta_est = np.zeros((self.nfeatures, 1))
                Beta_est[ordered_support_estimate_sequence] = np.matmul(Xk_pinv, Y)
                # LS estimate corresponding to LS estimate
                res = Y - np.matmul(X, Beta_est)
                res_normk = lin.norm(res)
                res_ratio.append(res_normk / res_norm[-1])
                res_norm.append(res_normk)
            except:
                print('Ill conditioned matrix. BOMP stop at iteration:' + str(k))
                flag = 1;
                break;

        if flag==1:
            # if full kmax iterations are not possible. RRT assumes residual ratios of fixed length kmax. to achieve this, append 1 to res_ratios to make kmax size.
            while len(res_ratio)!=kmax:
                res_ratio.append(1)
            while len(ordered_block_support_estimate_sequence)!=kmax:
                ordered_block_support_estimate_sequence.append(ordered_block_support_estimate_sequence[-1])
        return res_ratio,ordered_block_support_estimate_sequence

    # Baseline. BOMP powered with a priori knowledge of block sparsity level. Independent function.
    def BOMP_prior_sparsity(self,X,Y,block_size,sparsity):
        res=Y # initialize the residual with observation
        nsamples=X.shape[0];nfeatures=X.shape[1];
        ordered_support_estimate_sequence=[];ordered_block_support_estimate_sequence=[];
        flag=0;
        for k in range(sparsity):
            correlation=np.matmul(X.T,res)
            selected_block, indices_in_block = self.correlated_block_selection(correlation)
            ordered_block_support_estimate_sequence.append(selected_block);
            ordered_support_estimate_sequence = ordered_support_estimate_sequence + indices_in_block
            Xk=X[:,ordered_support_estimate_sequence].reshape((nsamples,(k+1)*block_size))
            try:
                Xk_pinv = lin.pinv(Xk)
                Beta_est = np.zeros((nfeatures, 1))
                Beta_est[ordered_support_estimate_sequence] = np.matmul(Xk_pinv, Y)
                res = Y - np.matmul(X, Beta_est)

            except:
                print('Ill conditioned matrix. BOMP stop at iteration:' + str(k))
                flag = 1;
                break;

        return ordered_block_support_estimate_sequence,Beta_est

    # # BMMV-OMP generates block support estimates which are monotonically increasing. The following code is useful to integrate algorithms other than BMMV-OMP which may generate
    #     # block support estimates sequences which are non monotonic. the following code converts a non monotonic support estimate sequence into monotonic support estimate sequence.
    def generate_ordered_sequence(self,block_support_estimate_sequence,kmax=None):
        if kmax is None:
            kmax=self.kmax;
        nsupports=len(block_support_estimate_sequence)
        ordered_block_support_estimate_sequence=[]
        for k in np.arange(nsupports):
            if k==0:
                ordered_block_support_estimate_sequence=ordered_block_support_estimate_sequence+block_support_estimate_sequence[k]
            else:
                diff=[ele for ele in block_support_estimate_sequence[k]  if ele not in ordered_block_support_estimate_sequence]
                ordered_block_support_estimate_sequence=ordered_block_support_estimate_sequence+diff
        return ordered_block_support_estimate_sequence[:kmax]

    ## this function ia also used for possible integration of a non BBMV-OMP algorithm in the RRT framework. this function computes the residual ratios sequence corresponding to
    ## a user supplied block support estimate sequence.
    def res_ratios_from_ordered_sequence(self,ordered_block_support_estimate_sequence):
        X=self.X;
        Y=self.Y;
        kmax=len(ordered_block_support_estimate_sequence);
        res_ratio=[]
        res_norm=[]
        res_norm.append(lin.norm(Y))
        res=Y # initialize the residual with observation
        
        flag=0;
        for k in range(kmax):
            block_support=ordered_block_support_estimate_sequence[:(k+1)]
            indices_in_block=self.generate_full_support_from_block_support(block_support=block_support)
            Xk=X[:,indices_in_block].reshape((self.nsamples,len(indices_in_block)))
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
    
    

    ## utility function. compute block support recovery error and  l2 error between estimated B and true B.
    def compute_error(self,block_support_true,block_support_estimate,Beta_true,Beta_estimate):
        Beta_true=np.squeeze(Beta_true); Beta_estimate=np.squeeze(Beta_estimate);
        block_support_true=set(block_support_true); block_support_estimate=set(block_support_estimate)
        l2_error=lin.norm(Beta_true-Beta_estimate)
        if block_support_true==block_support_estimate:
            support_error=0;
        else:
            support_error=1;
        return support_error,l2_error

    ## utlity function. Generate random BSMV examples with user specified parameters.
    def generate_random_example(self,nsamples=50,nfeatures=100,block_size=4,sparsity=5,SNR_db=10):
        # sparsity is the number of blocks. actual sparsity=block_size*sparsity
        snr=10**(SNR_db/10)# SNR in real scale
        X=np.random.randn(nsamples,nfeatures)
        X=X/lin.norm(X,axis=0)
        Beta=np.zeros((nfeatures,1))

        if nfeatures % block_size != 0:
            raise Exception(' nfeatures should be a multiple of block_size')

        nblocks = np.int(nfeatures /block_size)
        block_support= np.random.choice(np.arange(nblocks), size=(sparsity), replace=False)
        full_support=self.generate_full_support_from_block_support(block_support,block_size=block_size)
        Beta[full_support] = np.sign(np.random.randn(len(full_support), 1))
        signal_power=len(full_support)
        # noise_power=nsamples*noisevar. snr=signal_power/noise_power
        noisevar = signal_power/ (nsamples * snr)
        noise = np.random.randn(nsamples, 1) * np.sqrt(noisevar)
        Y = np.matmul(X, Beta) + noise
        block_support=[np.int(x) for x in block_support]
        return X,Y,Beta,block_support,noisevar
