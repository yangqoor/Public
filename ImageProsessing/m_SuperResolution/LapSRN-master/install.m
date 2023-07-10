% -------------------------------------------------------------------------
%   Description:
%       Script to compile matconvnet
%
%   Citation: 
%       Fast and Accurate Image Super-Resolution with Deep Laplacian Pyramid Networks
%       Wei-Sheng Lai, Jia-Bin Huang, Narendra Ahuja, and Ming-Hsuan Yang
%       arXiv, 2017
%
%   Contact:
%       Wei-Sheng Lai
%       wlai24@ucmerced.edu
%       University of California, Merced
% -------------------------------------------------------------------------

addpath('matconvnet/matlab');
vl_compilenn('enableGPu', true, 'enableCudnn', true);

