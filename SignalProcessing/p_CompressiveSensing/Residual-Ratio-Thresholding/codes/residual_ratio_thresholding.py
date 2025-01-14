import numpy as np
import numpy.linalg as lin
import numpy.random as random
import scipy as sci
import matplotlib.pyplot as plt
from scipy import special
from scipy.linalg import hadamard
import os
os.getcwd()
from sklearn import linear_model
import warnings
warnings.filterwarnings('ignore')

class residual_ratio_thresholding():
    def __init__(self,nsamples,nfeatures,alpha_list=[0.1],nchannels=1,block_size=1,scenario='compressed_sensing:SMV'):
        # we consider a linear model Y=X*B+W+O. Y:observation. X: design matrix of size nsamples*nfeatures
        # inlier noise W: Gaussian  noise of size nsamples*L. 
        #outlier O: of size nsamples*nchannels
        # regression vector B of size nfeatures*L. 
        # in compressed sensing B is a sparse matrix with only few non zero rows. 
        # and if group_size>1: non zero rows of B are cluttered together in groups of size group_size. its group sparsity
        # and if nchannels>1: multiple measurement vector problem.
        # and if nchannels=1 and group size=1. An unstructured sparse recovery problem with one measurement. 
        # in robust regression scenario: the outlier matrix O is sparse with few non zero rows. i.e, only few observations are corrupted by outliers 
        # in model order selection: the hypotheses are of the form : first k rows of B are non zero. more structured sparse problems
        self.nsamples=nsamples;    
        self.nfeatures=nfeatures;
        self.nchannels=nchannels;
        self.block_size=block_size;
        self.scenario=scenario; 
        # scenario has to be one of {model_order_selection,compressed_sensing:SMV,compressed_sensing:MMV,
        # compressed_sensing:BSMV, compressed_sensing:BMMV, robust_regression}
        # currently model order selection and robust regression has support in single measurement vector case only.
        self.alpha_list=alpha_list # RRT involves a hyper parameter alpha. We typically set it as alpha=0.1. You can give multiple values as a list to check whether performance changes with alpha. 
        self.threshold_dict=None # place to keep various thresholds used in RRT
        
    def generate_thresholds_robust_regression(self):
        # this function generate thresholds for robust regression
        nsamples=self.nsamples;
        nfeatures=self.nfeatures;
        kmax=self.kmax;
        alpha_list=self.alpha_list;
        if nfeatures>nsamples:
            raise Exception('Must satisfy nfeatures<nsamples. This technique is for low dimensional dense regression with sparse outliers. High dimensional regression with sparse outliers can be posed as a compressive sensing problem')

        threshold_dict={}; # place to save the set of thresholds used for residual ratio thresholding
        for alpha in alpha_list:
            # we compare the residual ratios with a sequence of threshold defined using the given value of alpha. 
            # however, if that thresholding scheme fails which happens only at low signal to noise ratio,
            # we gradually increase the value of alpha until we get a succesful thresholding. alphas_to_use is this set of thresholds
            # gradually increasing.
            alphas_to_use=10**(np.linspace(np.log10(alpha),np.log10(nsamples*kmax),100));
            threshold_alpha={}; threshold_alpha['when_rrt_fails']=[]
            for alpha_t in alphas_to_use:
                thres=np.zeros(kmax);
                for k in np.arange(kmax):
                    # definition of RRT thresholds. 
                    j=k+1+nfeatures;a=(nsamples-j)/2;b=1/2
                    npossibilities=(nsamples-j+1)
                    val=alpha_t/(npossibilities*kmax)
                    thres[k]=np.sqrt(special.betaincinv(a,b,val))
                if alpha_t==alpha:
                    threshold_alpha['direct']=thres; # save the threshold related to given alpha seperately.
                else:
                    threshold_alpha['when_rrt_fails'].append(thres) # save the thresholds to be used when RRT fails 
            threshold_alpha['alphas_to_use']=alphas_to_use
            threshold_dict[alpha]=threshold_alpha
        self.threshold_dict=threshold_dict
        return None

    def generate_thresholds_SMV(self):
        # this function generate thresholds for SMV scenario
        nsamples=self.nsamples;
        nfeatures=self.nfeatures;
        kmax=self.kmax;
        alpha_list=self.alpha_list;
        threshold_dict={}; # place to save the set of thresholds used for residual ratio thresholding
        for alpha in alpha_list:
            # we compare the residual ratios with a sequence of threshold defined using the given value of alpha.
            # however, if that thresholding scheme fails which happens only at low signal to noise ratio,
            # we gradually increase the value of alpha until we get a succesful thresholding. alphas_to_use is this set of thresholds
            # gradually increasing.

            alphas_to_use = 10 ** (np.linspace(np.log10(alpha), np.log10(nfeatures* kmax), 100));
            threshold_alpha = {};
            threshold_alpha['when_rrt_fails'] = []
            for alpha_t in alphas_to_use:
                thres = np.zeros(kmax);
                for k in np.arange(kmax):
                    j = k + 1;
                    a = (nsamples - j)/ 2;
                    b = 1/ 2;
                    npossibilities = nfeatures- j + 1
                    val = alpha_t / (npossibilities * kmax)
                    thres[k] = np.sqrt(special.betaincinv(a, b, val))
                if alpha_t == alpha:
                    threshold_alpha['direct'] = thres;
                else:
                    threshold_alpha['when_rrt_fails'].append(thres)
            threshold_alpha['alphas_to_use'] = alphas_to_use
            threshold_dict[alpha] = threshold_alpha
        self.threshold_dict = threshold_dict
        return None

    def generate_thresholds_MMV(self):
        # this function generate thresholds for BMMV scenario
        nsamples = self.nsamples;
        nfeatures = self.nfeatures;nchannels=self.nchannels
        kmax = self.kmax;
        alpha_list = self.alpha_list;
        threshold_dict = {};  # place to save the set of thresholds used for residual ratio thresholding
        for alpha in alpha_list:
            # we compare the residual ratios with a sequence of threshold defined using the given value of alpha.
            # however, if that thresholding scheme fails which happens only at low signal to noise ratio,
            # we gradually increase the value of alpha until we get a succesful thresholding. alphas_to_use is this set of thresholds
            # gradually increasing.
            alphas_to_use = 10 ** (np.linspace(np.log10(alpha), np.log10(nfeatures * kmax), 100));
            threshold_alpha = {};
            threshold_alpha['when_rrt_fails'] = []
            for alpha_t in alphas_to_use:
                thres = np.zeros(kmax);
                for k in np.arange(kmax):
                    j = k + 1;
                    a = (nsamples - j)*nchannels/2;
                    b = nchannels/2;
                    npossibilities = nfeatures - j + 1
                    val = alpha_t / (npossibilities * kmax)
                    thres[k] = np.sqrt(special.betaincinv(a, b, val))
                if alpha_t == alpha:
                    threshold_alpha['direct'] = thres;
                else:
                    threshold_alpha['when_rrt_fails'].append(thres)
            threshold_alpha['alphas_to_use'] = alphas_to_use
            threshold_dict[alpha] = threshold_alpha
        self.threshold_dict = threshold_dict
        return None

    def generate_thresholds_BSMV(self):
        # this function generate thresholds for BSMV scenario
        nsamples = self.nsamples;
        nfeatures = self.nfeatures;block_size=self.block_size
        nblocks=np.int(nfeatures/block_size)
        kmax = self.kmax;
        alpha_list = self.alpha_list;
        threshold_dict = {};  # place to save the set of thresholds used for residual ratio thresholding
        for alpha in alpha_list:
            # we compare the residual ratios with a sequence of threshold defined using the given value of alpha.
            # however, if that thresholding scheme fails which happens only at low signal to noise ratio,
            # we gradually increase the value of alpha until we get a succesful thresholding. alphas_to_use is this set of thresholds
            # gradually increasing.
            alphas_to_use = 10 ** (np.linspace(np.log10(alpha), np.log10(nblocks*kmax), 100));
            threshold_alpha = {};
            threshold_alpha['when_rrt_fails'] = []
            for alpha_t in alphas_to_use:
                thres = np.zeros(kmax);
                for k in np.arange(kmax):
                    j = k + 1;
                    a = (nsamples - j*block_size)/2;
                    b = block_size/2;
                    npossibilities = nblocks- j + 1
                    val = alpha_t / (npossibilities * kmax)
                    thres[k] = np.sqrt(special.betaincinv(a, b, val))
                if alpha_t == alpha:
                    threshold_alpha['direct'] = thres;
                else:
                    threshold_alpha['when_rrt_fails'].append(thres)
            threshold_alpha['alphas_to_use'] = alphas_to_use
            threshold_dict[alpha] = threshold_alpha
        self.threshold_dict = threshold_dict
        return None

    def generate_thresholds_BMMV(self):
        # this function generate thresholds for BSMV scenario
        nsamples = self.nsamples;
        nfeatures = self.nfeatures;
        block_size = self.block_size; nchannels=self.nchannels
        nblocks = np.int(nfeatures / block_size)
        kmax = self.kmax;
        alpha_list = self.alpha_list;
        threshold_dict = {};  # place to save the set of thresholds used for residual ratio thresholding
        for alpha in alpha_list:
            # we compare the residual ratios with a sequence of threshold defined using the given value of alpha.
            # however, if that thresholding scheme fails which happens only at low signal to noise ratio,
            # we gradually increase the value of alpha until we get a succesful thresholding. alphas_to_use is this set of thresholds
            # gradually increasing.
            alphas_to_use = 10 ** (np.linspace(np.log10(alpha),np.log10(nblocks * kmax), 100));
            threshold_alpha = {};
            threshold_alpha['when_rrt_fails'] = []
            for alpha_t in alphas_to_use:
                thres = np.zeros(kmax);
                for k in np.arange(kmax):
                    j = k + 1;
                    a = (nsamples - j * block_size)*nchannels/2;
                    b = block_size*nchannels/2;
                    npossibilities = nblocks - j + 1
                    val = alpha_t / (npossibilities * kmax)
                    thres[k] = np.sqrt(special.betaincinv(a, b, val))
                if alpha_t == alpha:
                    threshold_alpha['direct'] = thres;
                else:
                    threshold_alpha['when_rrt_fails'].append(thres)
            threshold_alpha['alphas_to_use'] = alphas_to_use
            threshold_dict[alpha] = threshold_alpha
        self.threshold_dict = threshold_dict
        return None

    def generate_thresholds_MOS(self):
        # this function generate thresholds for BSMV scenario
        nsamples = self.nsamples;
        nfeatures = self.nfeatures;
        kmax = self.kmax;
        alpha_list = self.alpha_list;
        threshold_dict = {};  # place to save the set of thresholds used for residual ratio thresholding
        for alpha in alpha_list:
            # we compare the residual ratios with a sequence of threshold defined using the given value of alpha.
            # however, if that thresholding scheme fails which happens only at low signal to noise ratio,
            # we gradually increase the value of alpha until we get a succesful thresholding. alphas_to_use is this set of thresholds
            # gradually increasing.
            alphas_to_use = 10 ** (np.linspace(np.log10(alpha), np.log10(nfeatures * kmax), 100));
            threshold_alpha = {};
            threshold_alpha['when_rrt_fails'] = []
            for alpha_t in alphas_to_use:
                thres = np.zeros(kmax);
                for k in np.arange(kmax):
                    j = k + 1;
                    a = (nsamples - j)/ 2;
                    b = 1/ 2;
                    npossibilities = 1
                    val = alpha_t / (npossibilities * kmax)
                    thres[k] = np.sqrt(special.betaincinv(a, b, val))
                if alpha_t == alpha:
                    threshold_alpha['direct'] = thres;
                else:
                    threshold_alpha['when_rrt_fails'].append(thres)
            threshold_alpha['alphas_to_use'] = alphas_to_use
            threshold_dict[alpha] = threshold_alpha
        self.threshold_dict = threshold_dict
        return None


    
    def compare_residual_ratios_with_threshold(self,res_ratio,thres):
        # this function compute the sparsity level from res_ratios given a RRT thres
        res_ratio=np.squeeze(res_ratio);thres=np.squeeze(thres);
        if np.any(res_ratio<thres)==True:
            temp=np.where(res_ratio<thres)[0] # the last index where res_ratio is smaller than the threshold
            sparsity_estimate=np.max(temp)+1 # sparsity_estimate is added one. since python index starts from 0. 
        else:
            sparsity_estimate=False # when none of residual ratios are smaller than thres. 
        return sparsity_estimate
    
    def estimate_support(self,ordered_support_list,res_ratio):
        # main function that estimate the support estimate from the ordered_support_list and res_ratio
        # res_ratio[k] is computed from the ordered_support_list[1:k] for k=1....kmax
        kmax=len(res_ratio);
        self.kmax=kmax; 
        if self.threshold_dict is None:
            # unless thresholds are computed a priori. compute the required thresholds. 
            if self.scenario=='MOS':
                self.generate_thresholds_MOS()
            elif self.scenario=='robust_regression':
                self.generate_thresholds_robust_regression()
            elif self.scenario=='SMV':
                self.generate_thresholds_SMV()
            elif self.scenario=='MMV':
                self.generate_thresholds_MMV()
            elif self.scenario=='BSMV':
                self.generate_thresholds_BSMV()
            elif self.scenario=='BMMV':
                self.generate_thresholds_BMMV()
            else:
                raise Exception('Invalid scenario')
        threshold_dict=self.threshold_dict
        alpha_list=self.alpha_list
        results={}
        for alpha in alpha_list:
            support_estimate=ordered_support_list
            threshold_alpha=threshold_dict[alpha]
            thres=threshold_alpha['direct'] # the list of thresholds based on a given alpha
            sparsity_estimate=self.compare_residual_ratios_with_threshold(res_ratio,thres) # compute rrt sparsity using the given thres
            if sparsity_estimate!=False:
                support_estimate=ordered_support_list[:sparsity_estimate]
            else:
                # when rrt with a given value of alpha fails, we increase the value of alpha till we see some elements of res_ratios falls the corresponding threshold
                threshold_when_rrt_fails=threshold_alpha['when_rrt_fails']
                for k in np.arange(len(threshold_when_rrt_fails)):
                    thres=threshold_when_rrt_fails[k]
                    sparsity_estimate=self.compare_residual_ratios_with_threshold(res_ratio,thres)
                    if sparsity_estimate!=False:
                        support_estimate=ordered_support_list[:sparsity_estimate]
                        break;
            results[alpha]=support_estimate # carries the support estimate for each value of alpha
        return results     