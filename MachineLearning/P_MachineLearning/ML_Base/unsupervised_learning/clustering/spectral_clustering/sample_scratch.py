import math # for math
import numpy as np # for math
import pandas as pd # for csv file reading
import matplotlib.pyplot as plt # for data visualization
from sklearn.cluster import KMeans # need in the spectral clustering
from scipy.spatial.distance import pdist, squareform # to generate adjacency values

import warnings
warnings.filterwarnings("ignore", category=FutureWarning)

# data
X = np.array([[15, 39], [15, 81], [16, 6], [16, 77], [17, 40], [17, 76], [18, 6], [18, 94], [19, 3], [19, 72], [19, 14], [19, 99], [20, 15], [20, 77], [20, 13], [20, 79], [21, 35], [21, 66], [23, 29], [23, 98], [24, 35], [24, 73], [25, 5], [25, 73], [28, 14], [28, 82], [28, 32], [28, 61], [29, 31], [29, 87], [30, 4], [30, 73], [33, 4], [33, 92], [33, 14], [33, 81], [34, 17], [34, 73], [37, 26], [37, 75], [38, 35], [38, 92], [39, 36], [39, 61], [39, 28], [39, 65], [40, 55], [40, 47], [40, 42], [40, 42], [42, 52], [42, 60], [43, 54], [43, 60], [43, 45], [43, 41], [44, 50], [44, 46], [46, 51], [46, 46], [46, 56], [46, 55], [47, 52], [47, 59], [48, 51], [48, 59], [48, 50], [48, 48], [48, 59], [48, 47], [49, 55], [49, 42], [50, 49], [50, 56], [54, 47], [54, 54], [54, 53], [54, 48], [54, 52], [54, 42], [54, 51], [54, 55], [54, 41], [54, 44], [54, 57], [54, 46], [57, 58], [57, 55], [58, 60], [58, 46], [59, 55], [59, 41], [60, 49], [60, 40], [60, 42], [60, 52], [60, 47], [60, 50], [61, 42], [61, 49], [62, 41], [62, 48], [62, 59], [62, 55], [62, 56], [62, 42], [63, 50], [63, 46], [63, 43], [63, 48], [63, 52], [63, 54], [64, 42], [64, 46], [65, 48], [65, 50], [65, 43], [65, 59], [67, 43], [67, 57], [67, 56], [67, 40], [69, 58], [69, 91], [70, 29], [70, 77], [71, 35], [71, 95], [71, 11], [71, 75], [71, 9], [71, 75], [72, 34], [72, 71], [73, 5], [73, 88], [73, 7], [73, 73], [74, 10], [74, 72], [75, 5], [75, 93], [76, 40], [76, 87], [77, 12], [77, 97], [77, 36], [77, 74], [78, 22], [78, 90], [78, 17], [78, 88], [78, 20], [78, 76], [78, 16], [78, 89], [78, 1], [78, 78], [78, 1], [78, 73], [79, 35], [79, 83], [81, 5], [81, 93], [85, 26], [85, 75], [86, 20], [86, 95], [87, 27], [87, 63], [87, 13], [87, 75], [87, 10], [87, 92], [88, 13], [88, 86], [88, 15], [88, 69], [93, 14], [93, 90], [97, 32], [97, 86], [98, 15], [98, 88], [99, 39], [99, 97], [101, 24], [101, 68], [103, 17], [103, 85], [103, 23], [103, 69], [113, 8], [113, 91], [120, 16], [120, 79], [126, 28], [126, 74], [137, 18], [137, 83]])

class SpectralClustering():
    def __init__(self, n_clusters=5, metric="euclidean", similarity_type="knn", knn=10, sigma=1, epsilon=0.5):
        """
        Parameters:
        -----------
        n_clusters: int
            the amount of different colored groups, than will been generated

        metric: string
            the type of metric that will been used to generate the adjacency

        similarity_type: string
            the type of graph similarity calculation: 
            'fully_connect', 'eps_neighbor', 'knn', 'mutual_knn'.
            
        knn: int
            used when similarity_type is ['mutual_knn', 'knn'], 
            the amount of values of the weights are been checked

        sigma: int 
            used when similarity_type is 'fully_connect', 
            for Standard deviation (Gaussian noise). 

        epsilon: float
            used when similarity_type is 'eps_neighbor', 
            to get all the values in the length of the epsilon value
        """
        self.n_clusters=n_clusters
        self.metric=metric
        self.similarity_type=similarity_type
        self.knn=knn
        self.sigma=sigma
        self.epsilon=epsilon

    def _get_adjacency_weights(self):
        """ 
        Compute the weighted adjacency matrix based on the self.similarity_type:
            knn: (k-nearest neighbors)
                return of 1's if the weight slice is below the self.knn index else 0's
            mutual_knn: (mutual k-nearest neighbors)
                return a array with True and False values, (1=True, 0=False) on self.knn index per array
            fully_connect: 
                return the exponential value of the negative adjacency devided by self.sigma
            eps_neighbor:
                return all float adjacency values, that contains in the self.epsilon length
        """
        adjacency = self.adjacency_matrix

        if "knn" in self.similarity_type:
            # Sort the adjacency matrx by rows and record the indices
            adjacency_sort = np.argsort(adjacency, axis=1)

            if self.similarity_type == 'knn':
                # Set the weight (i,j) to 1 when either i or j is within the k-nearest neighbors of each other
                weights = np.zeros(adjacency.shape)
                for i in range(adjacency_sort.shape[0]):
                    weights[i,adjacency_sort[i,:][:(self.knn + 1)]] = 1

            elif self.similarity_type == 'mutual_knn':
                # Set the weight W1[i,j] to 0.5 when either i or j is within the k-nearest neighbors of each other (Flag)
                # Set the weight W1[i,j] to 1 when both i and j are within the k-nearest neighbors of each other
                W1 = np.ones(adjacency.shape)
                for i in range(adjacency.shape[0]):
                    for j in adjacency_sort[i,:][:(self.knn+1)]:
                        if W1[i,j] == 0 and W1[j,i] == 0:
                            W1[i,j] = 0.5

                weights = np.copy((W1 > 0.5).astype('float64'))

        elif self.similarity_type ==  'fully_connect':
            weights = np.exp(-adjacency/(2 * self.sigma))
        elif self.similarity_type == 'eps_neighbor':
            weights = (adjacency <= self.epsilon).astype('float64')
        else:
            raise ValueError(
                """
                    The 'similarity_type' should be one of the following types: 
                    [
                        'fully_connect', 
                        'eps_neighbor', 
                        'knn', 
                        'mutual_knn'
                    ]
                """
            )
            
        return weights

    def _project_and_transpose(self, weights, normalized=1):
        # Compute the degree matrix and the unnormalized graph Laplacian
        D = np.diag(np.sum(weights, axis=1))
        L = D - weights
        
        # Compute the matrix with the first K eigenvectors as columns based on the normalized type of L
        if normalized == 1:   ## Random Walk normalized version
            # Compute the inverse of the diagonal matrix
            D_inv = np.diag(1/np.diag(D))
            
            # Compute the eigenpairs of L_{rw}
            Lambdas, V = np.linalg.eig(np.dot(D_inv, L))
            
            # Sort the eigenvalues by their L2 norms and record the indices
            ind = np.argsort(np.linalg.norm(np.reshape(Lambdas, (1, len(Lambdas))), axis=0))
            V_K = np.real(V[:, ind[:self.n_clusters]])

        elif normalized == 2:   ## Graph cut normalized version
            # Compute the square root of the inverse of the diagonal matrix
            D_inv_sqrt = np.diag(1/np.sqrt(np.diag(D)))
            
            # Compute the eigenpairs of L_{sym}
            Lambdas, V = np.linalg.eig(np.matmul(np.matmul(D_inv_sqrt, L), D_inv_sqrt))
            
            # Sort the eigenvalues by their L2 norms and record the indices
            ind = np.argsort(np.linalg.norm(np.reshape(Lambdas, (1, len(Lambdas))), axis=0))
            V_K = np.real(V[:, ind[:self.n_clusters]])
            
            # Normalize the row sums to have norm 1
            V_K = V_K/np.reshape(np.linalg.norm(V_K, axis=1), (V_K.shape[0], 1))

        else:   ## Unnormalized version
            
            # Compute the eigenpairs of L
            Lambdas, V = np.linalg.eig(L)
            
            # Sort the eigenvalues by their L2 norms and record the indices
            ind = np.argsort(np.linalg.norm(np.reshape(Lambdas, (1, len(Lambdas))), axis=0))
            V_K = np.real(V[:, ind[:self.n_clusters]])

        return V_K

    def fit_predict(self, X, is_adjacency_matrix=False, type_normalization=1):
        """
        Parameters:
        -----------
        X: numpy Array
            given data points
        is_adjacency_matrix: bool
            if X is already a adjacency matrix than the value need to be True,
            so the generation is been ignored to a new adjacency matrix
        type_normalization: int
            for normalizing the data of adjacency weights
        """
        self.X = X

        # Compute the adjacency matrix
        if not is_adjacency_matrix:
            dist = pdist(X, metric=self.metric)
            self.adjacency_matrix = squareform(dist)
        else:
            self.adjacency_matrix = X

        # Get the adjacency weights from given user input 
        weights = self._get_adjacency_weights()
        
        # Similarity Graph
        similarities = self._project_and_transpose(weights, type_normalization)
        
        # Conduct K-Means on the matrix with the first K eigenvectors as columns
        kmeans = KMeans(n_clusters=self.n_clusters, init='k-means++', random_state=0)
        yhat = kmeans.fit_predict(similarities)

        return yhat 
        
if __name__ == '__main__':
    # define the model
    model = SpectralClustering(n_clusters=5)

    # assign a cluster to each example
    yhat = model.fit_predict(X)

    # Retrieve unique clusters
    clusters = np.unique(yhat)

    # Create scatter plot samples for each example
    for cluster in clusters:

        # get row indexes for samples with this cluster
        row_ix = np.where(yhat == cluster)

        # create scatter for this sample
        plt.scatter(X[row_ix, 0], X[row_ix, 1])

    # show the window
    plt.show()
