# http://www.oranlooney.com/post/ml-from-scratch-part-6-pca/
import numpy as np
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler

import warnings
warnings.filterwarnings("ignore", category=FutureWarning)

# data
X = np.array([[15, 39], [15, 81], [16, 6], [16, 77], [17, 40], [17, 76], [18, 6], [18, 94], [19, 3], [19, 72], [19, 14], [19, 99], [20, 15], [20, 77], [20, 13], [20, 79], [21, 35], [21, 66], [23, 29], [23, 98], [24, 35], [24, 73], [25, 5], [25, 73], [28, 14], [28, 82], [28, 32], [28, 61], [29, 31], [29, 87], [30, 4], [30, 73], [33, 4], [33, 92], [33, 14], [33, 81], [34, 17], [34, 73], [37, 26], [37, 75], [38, 35], [38, 92], [39, 36], [39, 61], [39, 28], [39, 65], [40, 55], [40, 47], [40, 42], [40, 42], [42, 52], [42, 60], [43, 54], [43, 60], [43, 45], [43, 41], [44, 50], [44, 46], [46, 51], [46, 46], [46, 56], [46, 55], [47, 52], [47, 59], [48, 51], [48, 59], [48, 50], [48, 48], [48, 59], [48, 47], [49, 55], [49, 42], [50, 49], [50, 56], [54, 47], [54, 54], [54, 53], [54, 48], [54, 52], [54, 42], [54, 51], [54, 55], [54, 41], [54, 44], [54, 57], [54, 46], [57, 58], [57, 55], [58, 60], [58, 46], [59, 55], [59, 41], [60, 49], [60, 40], [60, 42], [60, 52], [60, 47], [60, 50], [61, 42], [61, 49], [62, 41], [62, 48], [62, 59], [62, 55], [62, 56], [62, 42], [63, 50], [63, 46], [63, 43], [63, 48], [63, 52], [63, 54], [64, 42], [64, 46], [65, 48], [65, 50], [65, 43], [65, 59], [67, 43], [67, 57], [67, 56], [67, 40], [69, 58], [69, 91], [70, 29], [70, 77], [71, 35], [71, 95], [71, 11], [71, 75], [71, 9], [71, 75], [72, 34], [72, 71], [73, 5], [73, 88], [73, 7], [73, 73], [74, 10], [74, 72], [75, 5], [75, 93], [76, 40], [76, 87], [77, 12], [77, 97], [77, 36], [77, 74], [78, 22], [78, 90], [78, 17], [78, 88], [78, 20], [78, 76], [78, 16], [78, 89], [78, 1], [78, 78], [78, 1], [78, 73], [79, 35], [79, 83], [81, 5], [81, 93], [85, 26], [85, 75], [86, 20], [86, 95], [87, 27], [87, 63], [87, 13], [87, 75], [87, 10], [87, 92], [88, 13], [88, 86], [88, 15], [88, 69], [93, 14], [93, 90], [97, 32], [97, 86], [98, 15], [98, 88], [99, 39], [99, 97], [101, 24], [101, 68], [103, 17], [103, 85], [103, 23], [103, 69], [113, 8], [113, 91], [120, 16], [120, 79], [126, 28], [126, 74], [137, 18], [137, 83]])
X = StandardScaler().fit_transform(X)

class PCA:
    def __init__(self, n_components=None, whiten=False):
        self.n_components = n_components
        self.whiten = bool(whiten)

    def _householder_reflection(self, a, e):
        '''
        Given a vector a and a unit vector e,
        (where a is non-zero and not collinear with e)
        returns an orthogonal matrix which maps a
        into the line of e.
        '''
        
        assert a.ndim == 1
        assert np.allclose(1, np.sum(e**2))
        
        u = a - np.sign(a[0]) * np.linalg.norm(a) * e  
        v = u / np.linalg.norm(u)
        H = np.eye(len(a)) - 2 * np.outer(v, v)
        
        return H

    def _qr_decomposition(self, A):
        '''
        Given an n x m invertable matrix A, returns the pair:
            Q an orthogonal n x m matrix
            R an upper triangular m x m matrix
        such that QR = A.
        '''
        
        n, m = A.shape
        assert n >= m
        
        Q = np.eye(n)
        R = A.copy()
        
        for i in range(m - int(n==m)):
            r = R[i:, i]
            
            if np.allclose(r[1:], 0):
                continue
                
            # e is the i-th basis vector of the minor matrix.
            e = np.zeros(n-i)
            e[0] = 1  
            
            H = np.eye(n)
            H[i:, i:] = self._householder_reflection(r, e)

            Q = Q @ H.T
            R = H @ R
        
        return Q, R

    def _eigen_decomposition(self, A, max_iter=100):
        A_k = A
        Q_k = np.eye( A.shape[1] )
        
        for k in range(max_iter):
            Q, R = np.linalg.qr(A_k)
            Q_k = Q_k @ Q
            A_k = R @ Q

        eigenvalues = np.diag(A_k)
        eigenvectors = Q_k
        return eigenvalues, eigenvectors

    def fit(self, X):
        n, m = X.shape
        
        # subtract off the mean to center the data.
        self.mu = X.mean(axis=0)
        X = X - self.mu
        
        # whiten if necessary
        if self.whiten:
            self.std = X.std(axis=0)
            X = X / self.std
        
        # Eigen Decomposition of the covariance matrix
        C = X.T @ X / (n-1)
        self.eigenvalues, self.eigenvectors = self._eigen_decomposition(C)
        
        # truncate the number of components if doing dimensionality reduction
        if self.n_components is not None:
            self.eigenvalues = self.eigenvalues[0:self.n_components]
            self.eigenvectors = self.eigenvectors[:, 0:self.n_components]
        
        # the QR algorithm tends to puts eigenvalues in descending order 
        # but is not guarenteed to. To make sure, we use argsort.
        descending_order = np.flip(np.argsort(self.eigenvalues))
        self.eigenvalues = self.eigenvalues[descending_order]
        self.eigenvectors = self.eigenvectors[:, descending_order]

        return self

    def transform(self, X):
        X = X - self.mu
        
        if self.whiten:
            X = X / self.std
        
        return X @ self.eigenvectors
    
    @property
    def proportion_variance_explained(self):
        return self.eigenvalues / np.sum(self.eigenvalues)

if __name__ == "__main__":
    # algorithm
    pca = PCA(whiten=True)
    pca.fit(X)

    # assign PCA to data
    pca_T = pca.transform(X)
    X_new = pca_T# pca.inverse_transform(pca_T)

    # visualization
    plt.scatter(X[:, 0], X[:, 1], alpha=0.2, color="b", label="input")
    plt.scatter(X_new[:, 0], X_new[:, 1] * 0, alpha=0.8, color="b", label="PCA output")

    plt.grid()
    plt.legend()
    plt.show()
