import numpy as np
import matplotlib.pyplot as plt
import operator, math
from scipy.spatial.distance import pdist
from scipy.spatial.distance import squareform

import warnings
warnings.filterwarnings("ignore", category=FutureWarning)

# data
X = np.array([[15, 39], [15, 81], [16, 6], [16, 77], [17, 40], [17, 76], [18, 6], [18, 94], [19, 3], [19, 72], [19, 14], [19, 99], [20, 15], [20, 77], [20, 13], [20, 79], [21, 35], [21, 66], [23, 29], [23, 98], [24, 35], [24, 73], [25, 5], [25, 73], [28, 14], [28, 82], [28, 32], [28, 61], [29, 31], [29, 87], [30, 4], [30, 73], [33, 4], [33, 92], [33, 14], [33, 81], [34, 17], [34, 73], [37, 26], [37, 75], [38, 35], [38, 92], [39, 36], [39, 61], [39, 28], [39, 65], [40, 55], [40, 47], [40, 42], [40, 42], [42, 52], [42, 60], [43, 54], [43, 60], [43, 45], [43, 41], [44, 50], [44, 46], [46, 51], [46, 46], [46, 56], [46, 55], [47, 52], [47, 59], [48, 51], [48, 59], [48, 50], [48, 48], [48, 59], [48, 47], [49, 55], [49, 42], [50, 49], [50, 56], [54, 47], [54, 54], [54, 53], [54, 48], [54, 52], [54, 42], [54, 51], [54, 55], [54, 41], [54, 44], [54, 57], [54, 46], [57, 58], [57, 55], [58, 60], [58, 46], [59, 55], [59, 41], [60, 49], [60, 40], [60, 42], [60, 52], [60, 47], [60, 50], [61, 42], [61, 49], [62, 41], [62, 48], [62, 59], [62, 55], [62, 56], [62, 42], [63, 50], [63, 46], [63, 43], [63, 48], [63, 52], [63, 54], [64, 42], [64, 46], [65, 48], [65, 50], [65, 43], [65, 59], [67, 43], [67, 57], [67, 56], [67, 40], [69, 58], [69, 91], [70, 29], [70, 77], [71, 35], [71, 95], [71, 11], [71, 75], [71, 9], [71, 75], [72, 34], [72, 71], [73, 5], [73, 88], [73, 7], [73, 73], [74, 10], [74, 72], [75, 5], [75, 93], [76, 40], [76, 87], [77, 12], [77, 97], [77, 36], [77, 74], [78, 22], [78, 90], [78, 17], [78, 88], [78, 20], [78, 76], [78, 16], [78, 89], [78, 1], [78, 78], [78, 1], [78, 73], [79, 35], [79, 83], [81, 5], [81, 93], [85, 26], [85, 75], [86, 20], [86, 95], [87, 27], [87, 63], [87, 13], [87, 75], [87, 10], [87, 92], [88, 13], [88, 86], [88, 15], [88, 69], [93, 14], [93, 90], [97, 32], [97, 86], [98, 15], [98, 88], [99, 39], [99, 97], [101, 24], [101, 68], [103, 17], [103, 85], [103, 23], [103, 69], [113, 8], [113, 91], [120, 16], [120, 79], [126, 28], [126, 74], [137, 18], [137, 83]])


# Algorithms
def euclidean_distance(x1, x2):
    """ Calculates the l2 distance between two vectors """
    distance = 0
    # Squared distance between each coordinate
    for i in range(len(x1)):
        distance += pow((x1[i] - x2[i]), 2)
    return math.sqrt(distance)

class OPTICS():
    def __init__(self, epsilon=10, min_samples=10,  metric="euclidean"):
        self.epsilon=epsilon
        self.min_samples=min_samples
        self.metric=metric  

    def _get_core_distances(self):  
        # min_index that will been checked
        min_index = self.min_samples - 1 # list to array

        # get matrix value of the min_samples
        temp = self.adjacency_matrix[
            np.arange(self.adjacency_matrix.shape[0]),
            np.argsort(self.adjacency_matrix)[:, min_index]
        ]

        # return matrix with all values that are less then self.epsilon else it will be -1
        return np.where(temp <= self.epsilon, temp, -1)

    def _get_neighbors(self, sample_i):
        """
        Return a list of indexes of neighboring samples
        A sample_2 is considered a neighbor of sample_1 
        if the distance between them is smaller than this.epsilon
        """
        data = self.X
        neighbors = []
        all_indexes = np.arange(len(data))

        for i, _sample in enumerate(data[all_indexes != sample_i]):
            distance = euclidean_distance(data[sample_i], _sample)
            if distance <= self.epsilon:
                neighbors.append(i)
        
        return np.array(neighbors)

    def _update_reachable_distances(self, sample_i, neighbors, seeds=dict()):
        # Iterate through neighbors and expand higest reachable distance from them
        for neighbor in neighbors:
            if self.visited_samples[neighbor]:
                continue
                
            # First calculate the reachable distance of the changed point for sample_i
            new_reach_dist = max(
                self.core_distances[sample_i], 
                self.adjacency_matrix[sample_i][neighbor]
            )
            
            seeds[neighbor] = self.reachable_distances[neighbor] = min(
                self.reachable_distances[neighbor], 
                new_reach_dist
            )

        return seeds

    def _get_cluster_labels(self, orders):
        # find the index of the point in the ordered list that is smaller than epsilon, 
        # that is the index corresponding to the ordered list
        clusters = np.where(self.reachable_distances[orders] <= self.epsilon)[0]
        
        # Normally: the value of current should be one more index than the value of pre. 
        # If it is larger than one index, it means that it is not a category.
        pre = clusters[0] - 1
        clusterId = 0

        # Will make sure all outliers have same cluster label
        labels = np.full(shape=self.X.shape[0], fill_value=0)

        for cluster_i, cluster in enumerate(clusters):
            # Normally: the value of cluster should be one more index than the value of pre. 
            # If it is larger than one index, it means that it is not a category.
            if(cluster - pre != 1):
                clusterId = clusterId + 1

            labels[orders[cluster]]=clusterId
            pre=cluster

        return labels

    def fit_predict(self, X, is_adjacency_matrix=False):
        self.X = X

        # Compute the adjacency matrix
        if not is_adjacency_matrix:
            dist = pdist(X, metric=self.metric)
            self.adjacency_matrix = squareform(dist)
        else:
            self.adjacency_matrix = X

        self.visited_samples        = np.zeros(self.X.shape[0])
        self.reachable_distances    = np.full(self.X.shape[0], np.inf)
        self.core_distances         = self._get_core_distances()

        # all matched values as a summed Matrix
        summed_matches = np.sum(np.where(self.adjacency_matrix <= self.epsilon, 1, 0), axis=1)
        core_samples = np.where(summed_matches >= self.min_samples)[0]
        used_samples = []    
        
        # Iterate through core samples and itterate to the next core samples
        # so we get all grouped clusters at the end
        for core_sample in core_samples:
            if self.visited_samples[core_sample]:
                continue
            
            # unique noted data
            self.visited_samples[core_sample] = int(True)
            used_samples.append(core_sample)
        
            # Find all points (samples) in epsilon range
            neighbors = self._get_neighbors(core_sample)
            nearest_samples = self._update_reachable_distances(core_sample, neighbors)

            # check closest sample from core point
            while len(nearest_samples) > 0:
                closest_sample = sorted(nearest_samples.items(), key=operator.itemgetter(1))[0][0]
                del nearest_samples[closest_sample]

                # unique noted data
                self.visited_samples[closest_sample] = int(True)
                used_samples.append(closest_sample)
        
                # Find all points (samples) in epsilon range
                sample_neighbors = self._get_neighbors(closest_sample)
                if len(sample_neighbors) >= self.min_samples:
                    nearest_samples = self._update_reachable_distances(closest_sample, sample_neighbors, nearest_samples)
            
        cluster_labels = self._get_cluster_labels(used_samples)
        return cluster_labels

if __name__ == "__main__":
    
    # define model
    model = OPTICS(epsilon=23, min_samples=15)

    # assign cluster to each sample
    yhat = model.fit_predict(X)

    # retrieve unique clusters
    clusters = np.unique(yhat)

    # create scatter plot for samples from each cluster
    for cluster in clusters:

        # get row indexes for samples with this cluster
        row_ix = np.where(yhat == cluster)

        # create scatter of these samples
        plt.scatter(X[row_ix, 0], X[row_ix, 1])

    # show the plot
    plt.show()

