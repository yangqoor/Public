clc;clear all;
% The data and corresponding class labels are stored in data.mat.
% First load data.mat to make sure the variable 'data' and 'labels' are in
% the workspace. Then culculate the distance matrix. Finally apply the
% Isomap algorithm.
%
% The code for the Isomap algorithm is written by Josh Tenenbaum. See
% details in the comments of 'IsomapII'.

alpha = 0.5;
K = 10;
[data,labels]=size(data);

D=distance(data, labels, alpha);
options.dims = [2];
[Y, R, E] = IsomapII(D, 'k', K, options); 