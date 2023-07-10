
-----------------------------------------------------------------------------------------
			ReadMe: The S-ISOMAP Package
-----------------------------------------------------------------------------------------

ATTN: This package is free for academic usage. You can run it at your own risk. For other
      purposes, please contact Prof. Zhi-Hua Zhou (zhouzh@nju.edu.cn)


To use this code package:
   
      1. You must prepair you data by yourself:
         Store the data (variable 'data', each column is a record) and corresponding class 
         labels (variable 'labels', integer array, each element corresponds to one record 
         in 'data') in the file data.mat in the same directory of the package.

      2. Run 'sIsomap.m'. The algorithm will return the mapped data in the variable 'Y'. 
         You can also modify the values of the parameters (alpha and K) in 'sIsomap.m'.

      3. For visualization purpose, you can directly visualize 'Y'.
         For classification purpose, you must approximate the mapping first (such as using 
         the Generalized Regression Network), and then map the given query into the feature 
         space and predict its class label (such as using K-NN).

      4. The code for the Isomap algorithm is written by Josh Tenenbaum. See details in the
         comments of 'IsomapII.m'.


Reference: X. Geng, D.-C. Zhan, and Z.-H. Zhou. Supervised nonlinear dimensionality
           reduction for visualization and classification. IEEE Transactions on Systems, 
           Man, and Cybernetics - Part B: Cybernetics, 2005, vol.35, no.6, pp.1098-1107.

ATTN2: This package was developed by Mr. Xin Geng (gengx@lamda.nju.edu.cn). For any problem
       concerning the code, please feel free to contact Mr. Geng.

-----------------------------------------------------------------------------------------