# Subject-Independent-Drowsiness-Recognition-from-Single-Channel-EEG-with-an-Interpretable-CNN-LSTM
Pytorch implementation of the paper "Subject-Independent Drowsiness Recognition from Single-Channel EEG with an Interpretable CNN-LSTM model".
https://doi.org/10.1109/CW52790.2021.00041

If you find the codes useful, pls cite the paper:

J. Cui et al., "Subject-Independent Drowsiness Recognition from Single-Channel EEG with an Interpretable CNN-LSTM model," 2021 International Conference on Cyberworlds (CW), 2021, pp. 201-208, doi: 10.1109/CW52790.2021.00041.

The project contains 3 code files. They are implemented with Python 3.6.6.

"CNNLSTM.py" contains the model. required library: torch

"LeaveOneOut_acc.py" contains the leave-one-subject-out method to get the classifcation accuracies. It requires the computer to have cuda supported GPU installed. required library:torch,scipy,numpy,sklearn

"CNNLSTM_VisualizationTech.py" contains the visualization technique based on the modification of the LSTM model. It requires the computer to have cuda supported GPU installed. required library:torch,scipy,numpy,matplotlib,mne

The processed dataset has been uploaded to: https://figshare.com/articles/dataset/EEG_driver_drowsiness_dataset/14273687

If you have any problems, please Contact Dr. Cui Jian at cuij0006@ntu.edu.sg
