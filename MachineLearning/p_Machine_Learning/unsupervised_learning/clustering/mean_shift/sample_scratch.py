import numpy as np
import matplotlib.pyplot as plt
import random 

import warnings
warnings.filterwarnings("ignore", category=FutureWarning)

# data
X = np.array([[15, 39], [15, 81], [16, 6], [16, 77], [17, 40], [17, 76], [18, 6], [18, 94], [19, 3], [19, 72], [19, 14], [19, 99], [20, 15], [20, 77], [20, 13], [20, 79], [21, 35], [21, 66], [23, 29], [23, 98], [24, 35], [24, 73], [25, 5], [25, 73], [28, 14], [28, 82], [28, 32], [28, 61], [29, 31], [29, 87], [30, 4], [30, 73], [33, 4], [33, 92], [33, 14], [33, 81], [34, 17], [34, 73], [37, 26], [37, 75], [38, 35], [38, 92], [39, 36], [39, 61], [39, 28], [39, 65], [40, 55], [40, 47], [40, 42], [40, 42], [42, 52], [42, 60], [43, 54], [43, 60], [43, 45], [43, 41], [44, 50], [44, 46], [46, 51], [46, 46], [46, 56], [46, 55], [47, 52], [47, 59], [48, 51], [48, 59], [48, 50], [48, 48], [48, 59], [48, 47], [49, 55], [49, 42], [50, 49], [50, 56], [54, 47], [54, 54], [54, 53], [54, 48], [54, 52], [54, 42], [54, 51], [54, 55], [54, 41], [54, 44], [54, 57], [54, 46], [57, 58], [57, 55], [58, 60], [58, 46], [59, 55], [59, 41], [60, 49], [60, 40], [60, 42], [60, 52], [60, 47], [60, 50], [61, 42], [61, 49], [62, 41], [62, 48], [62, 59], [62, 55], [62, 56], [62, 42], [63, 50], [63, 46], [63, 43], [63, 48], [63, 52], [63, 54], [64, 42], [64, 46], [65, 48], [65, 50], [65, 43], [65, 59], [67, 43], [67, 57], [67, 56], [67, 40], [69, 58], [69, 91], [70, 29], [70, 77], [71, 35], [71, 95], [71, 11], [71, 75], [71, 9], [71, 75], [72, 34], [72, 71], [73, 5], [73, 88], [73, 7], [73, 73], [74, 10], [74, 72], [75, 5], [75, 93], [76, 40], [76, 87], [77, 12], [77, 97], [77, 36], [77, 74], [78, 22], [78, 90], [78, 17], [78, 88], [78, 20], [78, 76], [78, 16], [78, 89], [78, 1], [78, 78], [78, 1], [78, 73], [79, 35], [79, 83], [81, 5], [81, 93], [85, 26], [85, 75], [86, 20], [86, 95], [87, 27], [87, 63], [87, 13], [87, 75], [87, 10], [87, 92], [88, 13], [88, 86], [88, 15], [88, 69], [93, 14], [93, 90], [97, 32], [97, 86], [98, 15], [98, 88], [99, 39], [99, 97], [101, 24], [101, 68], [103, 17], [103, 85], [103, 23], [103, 69], [113, 8], [113, 91], [120, 16], [120, 79], [126, 28], [126, 74], [137, 18], [137, 83]])

# type of kernel we use in this sample
def gaussian_kernel(distance, bandwidth):
    return (1 / (bandwidth * np.sqrt(2 * np.pi))) * np.exp(-0.5 * ((distance / bandwidth)) ** 2)

STOP_THRESHOLD = 1e-3
CLUSTER_THRESHOLD = 1e-1

class MeanShift:
    def __init__(self, bandwidth=20, kernel=gaussian_kernel):
        self.bandwidth=bandwidth
        self.kernel=kernel

    def _distance(self, a, b):
        return np.linalg.norm(np.array(a) - np.array(b))

    def _shift_point(self, point, points):
        shift_x = 0.0
        shift_y = 0.0
        scale = 0.0

        for p in points:
            dist = self._distance(point, p)

            # shift point location based on the distance weight
            weight = self.kernel(dist, self.bandwidth)
            shift_x += p[0] * weight
            shift_y += p[1] * weight
            scale += weight

        # remove scale (weights) value 
        shift_x = shift_x / scale
        shift_y = shift_y / scale

        new_point = [shift_x, shift_y]
        distance = self._distance(new_point, point)
        return (distance, new_point)

    def _cluster_points(self, points):
        clusters = []
        cluster_idx = 0
        cluster_centers = []

        for i, point in enumerate(points):
            if(len(clusters) == 0):
                clusters.append(cluster_idx)
                cluster_centers.append(point)
                cluster_idx += 1
            else:
                for center in cluster_centers:
                    dist = self._distance(point, center)
                    if(dist < CLUSTER_THRESHOLD):
                        clusters.append(cluster_centers.index(center))

                if(len(clusters) < i + 1):
                    clusters.append(cluster_idx)
                    cluster_centers.append(point)
                    cluster_idx += 1

        return clusters

    def fit_predict(self, X):
        shift_points = X.copy()
        shifting = [True] * X.shape[0]

        # prevent infinity loop, 
        prev_dist = 0
        threshold = 0

        while True:
            # update points locations 
            max_dist = 0
            for i in range(0, len(shift_points)):
                if not shifting[i]:
                    continue

                # update point location
                distance, shift_points[i] = self._shift_point(shift_points[i], X)
                max_dist = max(max_dist, distance)
                shifting[i] = (distance > STOP_THRESHOLD)

            if threshold >= 10:
                break
            elif prev_dist >= max_dist:
                threshold += 1

            prev_dist = max_dist


        
        clusters = self._cluster_points(shift_points.tolist())
        return clusters

if __name__ == "__main__":
    # define model
    model = MeanShift(bandwidth=23)

    # assign a cluster to each example
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
