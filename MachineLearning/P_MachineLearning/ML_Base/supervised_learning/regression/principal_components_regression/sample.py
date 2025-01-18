import pandas as pd  
import numpy as np  
import matplotlib.pyplot as plt  
from scipy.signal import savgol_filter  
from sklearn.decomposition import PCA  
from sklearn.preprocessing import StandardScaler  
from sklearn import linear_model  
from sklearn.model_selection import cross_val_predict  
from sklearn.metrics import mean_squared_error, r2_score  

# datasets
data = pd.read_csv("../../../_data/peach_spectra_brix.csv")
data.head()

y_train = data['Brix'].values
x_train = data.values[:, 1:]

def pcr(X,y,pc):  
    ''' Principal Component Regression in Python'''  

    ''' Step 1: PCA on input data'''    
    # Define the PCA object  
    pca = PCA()    
    
    # Preprocessing (1): first derivative  
    d1X = savgol_filter(X, 25, polyorder=5, deriv=1)    
    
    # Preprocess (2) Standardize features by removing the mean and scaling to unit variance  
    Xstd = StandardScaler().fit_transform(d1X[:,:])    
    
    # Run PCA producing the reduced variable Xred and select the first pc components  
    Xreg = pca.fit_transform(Xstd)[:,:pc]    
    
    ''' Step 2: regression on selected principal components'''    
    # Create linear regression object  
    regr = linear_model.LinearRegression()    
    
    # Fit  
    regr.fit(Xreg, y)    
    
    # Calibration  
    y_c = regr.predict(Xreg)    
    
    # Cross-validation  
    y_cv = cross_val_predict(regr, Xreg, y, cv=10)    
    
    # Calculate scores for calibration and cross-validation  
    score_c = r2_score(y, y_c)  
    score_cv = r2_score(y, y_cv)    
    
    # Calculate mean square error for calibration and cross validation  
    mse_c = mean_squared_error(y, y_c)  
    mse_cv = mean_squared_error(y, y_cv)    
    return(y_cv, score_c, score_cv, mse_c, mse_cv)  

if __name__ == "__main__":
    predicted, r2r, r2cv, mser, mscv = pcr(x_train, y_train, pc=6)    

    # Regression plot  
    z = np.polyfit(y_train, predicted, 1)  
    with plt.style.context(('ggplot')):  
        fig, ax = plt.subplots(figsize=(9, 5))  
        ax.scatter(y_train, predicted, c='red', edgecolors='k')  
        ax.plot(y_train, z[1]+z[0] * y_train, c='blue', linewidth=1)  
        ax.plot(y_train, y_train, color='green', linewidth=1)  
        plt.title('$R^{2}$ (CV): ' + str(r2cv))  
        plt.xlabel('Measured $^{\circ}$Brix')  
        plt.ylabel('Predicted $^{\circ}$Brix')  
        plt.show()



