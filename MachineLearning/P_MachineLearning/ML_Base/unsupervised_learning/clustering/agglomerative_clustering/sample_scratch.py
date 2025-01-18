import numpy as np
import matplotlib.pyplot as plt
import pandas as pd 
from scipy.cluster.hierarchy import dendrogram, linkage

# data
dataset = np.array([[15, 39], [15, 81], [16, 6], [16, 77], [17, 40], [17, 76], [18, 6], [18, 94], [19, 3], [19, 72], [19, 14]])

class AgglomerativeClustering(object):
    def __init__(self, n_clusters = 5):
        self.n_clusters = n_clusters
        
    def fit_predict(self, data):
        self.data = data

        print("niek")

    """
    Creates a matrix of distances between individual samples and clusters attained at a particular step
    """
    def compute_distance(self,samples):
        Distance_mat = np.zeros((len(samples),len(samples)))
        for i in range(Distance_mat.shape[0]):
            for j in range(Distance_mat.shape[0]):
                if i!=j:
                    Distance_mat[i,j] = float(self.calculate_distance(samples[i],samples[j]))
                else:
                    Distance_mat[i,j] = 10**4
        return Distance_mat
    

    """
    Distance calulated between two samples. 
    The two samples can be both samples, both clusters or one cluster and one sample. 
    If both of them are samples/clusters, then simple norm is used. 
    In other cases, we refer it as an exception case and pass the samples as parameter to some function that 
    calculates the necessary distance between cluster and a sample
    """
    def calculate_distance(self,sample1,sample2):
        dist = []
        for i in range(len(sample1)):
            for j in range(len(sample2)):
                try:
                    dist.append(np.linalg.norm(np.array(sample1[i])-np.array(sample2[j])))
                except:
                    dist.append(self.intersampledist(sample1[i],sample2[j]))
        return min(dist)
    
    
    def intersampledist(self,s1,s2):
        '''
            To be used in case we have one sample and one cluster . It takes the help of one 
            method 'interclusterdist' to compute the distances between elements of a cluster(which are
            samples) and the actual sample given.
        '''
        if str(type(s2[0]))!='<class \'list\'>':
            s2=[s2]
        if str(type(s1[0]))!='<class \'list\'>':
            s1=[s1]
        m = len(s1)
        n = len(s2)
        dist = []
        if n>=m:
            for i in range(n):
                for j in range(m):
                    if (len(s2[i])>=len(s1[j])) and str(type(s2[i][0])!='<class \'list\'>'):
                        dist.append(self.interclusterdist(s2[i],s1[j]))
                    else:
                        dist.append(np.linalg.norm(np.array(s2[i])-np.array(s1[j])))
        else:
            for i in range(m):
                for j in range(n):
                    if (len(s1[i])>=len(s2[j])) and str(type(s1[i][0])!='<class \'list\'>'):
                        dist.append(self.interclusterdist(s1[i],s2[j]))
                    else:
                        dist.append(np.linalg.norm(np.array(s1[i])-np.array(s2[j])))
        return min(dist)
    
    def interclusterdist(self,cl,sample):
        if sample[0]!='<class \'list\'>':
            sample = [sample]
        dist   = []
        for i in range(len(cl)):
            for j in range(len(sample)):
                dist.append(np.linalg.norm(np.array(cl[i])-np.array(sample[j])))
        return min(dist)

# as we need to bind all the data points with each other,
# we need the higest value of the x or y.
def empty_matrix(X):
    return np.zeros((max(X.shape), max(X.shape)))

if __name__ == "__main__":
    model = AgglomerativeClustering(n_clusters=5)
    yhat = model.fit_predict(dataset)

    progression = [[i] for i in range(dataset.shape[0])]
    samples     = [[list(dataset[i])] for i in range(dataset.shape[0])]
    m = len(samples)

    while m > 1:
        print('Sample size before clustering    :- ',m)
        Distance_mat      = model.compute_distance(samples)
        sample_ind_needed = np.where(Distance_mat==Distance_mat.min())[0]
        value_to_add      = samples.pop(sample_ind_needed[1])
        samples[sample_ind_needed[0]].append(value_to_add)
        
        print('Cluster Node 1                   :-',progression[sample_ind_needed[0]])
        print('Cluster Node 2                   :-',progression[sample_ind_needed[1]])
        
        progression[sample_ind_needed[0]].append(progression[sample_ind_needed[1]])
        progression[sample_ind_needed[0]] = [progression[sample_ind_needed[0]]]
        v = progression.pop(sample_ind_needed[1])
        m = len(samples)
        
        print('Progression(Current Sample)      :-',progression)
        print('Cluster attained                 :-',progression[sample_ind_needed[0]])
        print('Sample size after clustering     :-',m)
        print('\n')

    Z = linkage(dataset, 'single')
    dn = dendrogram(Z)

    plt.show()
