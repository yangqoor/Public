function ACC = computeAccuracy(Y,Yhat)
% Compute classification accuracy.
%
%
% Refer to README.md and ELM_MatlabClass for further details.  
%
%
% Copyright 2015 Riccardo Taormina  
% riccardo.taormina@gmail.com 
%
%
% This file is part of ELM_MatlabClass.
%
%     ELM_MatlabClass is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     ELM_MatlabClass is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with ELM_MatlabClass.  If not, see <http://www.gnu.org/licenses/>.

% get confusion matrix elements
TP = sum(Y == 1 & Yhat == 1);
TN = sum(Y == 0 & Yhat == 0);
FP = sum(Y == 0 & Yhat == 1);
FN = sum(Y == 1 & Yhat == 0);

% compute total positive and negatives
P = TP + FP;
N = TN + FN;

% compute accuracy
ACC = (TP + TN) / (P + N);