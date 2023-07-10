function [mappedA, mapping] = autoencoder(A, no_dims)
%AUTOENCODER Trains an autoencoder on a dataset to reduce dimensionality
%
%   [mappedA, mapping] = autoencoder(A, no_dims)
%
% Trains an autoencoder on dataset A to reduce its dimensionality to
% no_dims. The reduced data is returned in mappedA. The information on the
% trained encoder is returned in mapping.
%
%

% This file is part of the Matlab Toolbox for Dimensionality Reduction v0.3b.
% The toolbox can be obtained from http://www.cs.unimaas.nl/l.vandermaaten
% You are free to use, change, or redistribute this code in any way you
% want for non-commercial purposes. However, it is appreciated if you 
% maintain the name of the original author.
%
% (C) Laurens van der Maaten
% Maastricht University, 2007

    if ~exist('no_dims', 'var')
        no_dims = 2;
    end

    % Make sure data is zero-mean, unit variance
    mapping.mean = mean(A, 1);
    mapping.var  = var(A, 1);
    A = A -  repmat(mapping.mean, [size(A, 1) 1]);
    A = A ./ repmat(mapping.var,  [size(A, 1) 1]);

    % Set sizes of network layers
    numhid = ceil(size(A, 2) * 1.2) + 20;
    numpen2 = max([ceil(size(A, 2) / 4) no_dims + 1]);
    numpen = max([ceil(size(A, 2) / 2) + 3 numpen2 + 2]);
    numopen = no_dims;  
    
    % Set variables for RBM training
    disp(['Performing pretraining of ' num2str(size(A, 2)) '->' num2str(numhid) '-' num2str(numpen) '-' num2str(numpen2) '->' num2str(numopen) ' network...']);
    batchdata = A;          % training data
    maxepoch = 50;          % maximum # of epochs
    [numcases numdims numbatches] = size(batchdata);

    % Pretrain using Restricted Boltzmann Machine
    restart = 1; rbm;
        hidrecbiases = hidbiases; store_vishid = vishid; store_visbiases = visbiases;
    numhid = numpen; batchdata = batchposhidprobs; restart = 1; rbm;
        hidpen = vishid; penrecbiases = hidbiases; hidgenbiases = visbiases;
    numhid = numpen2; batchdata = batchposhidprobs; restart = 1; rbm;
        hidpen2 = vishid; penrecbiases2 = hidbiases; hidgenbiases2 = visbiases;
    numhid = numopen; batchdata = batchposhidprobs; restart = 1; rbmhidlinear;
        hidtop = vishid; toprecbiases = hidbiases; topgenbiases = visbiases;

    % Fine tune autoencoder using backpropagation
    indices = randperm(size(A, 1));
    testbatchdata = A(indices(1:round(length(indices) / 5)),:); 
    batchdata = A(indices(round(length(indices) / 5) + 1),:);            
    vishid = store_vishid; visbiases = store_visbiases;
    backprop;

    % Extract embedded data
    N = size(A, 1);
    w1probs = [1 ./ (1 + exp(-[A ones(N, 1)] * w1))     ones(N, 1)];
    w2probs = [1 ./ (1 + exp(-w1probs * w2))            ones(N, 1)];
    w3probs = [1 ./ (1 + exp(-w2probs * w3))            ones(N, 1)];
    mappedA = w3probs * w4;
    
    % As well reconstruct data for visualization purposes
    w4probs = [mappedA ones(N, 1)];
    w5probs = [1 ./ (1 + exp(-w4probs * w5))    ones(N, 1)];
    w6probs = [1 ./ (1 + exp(-w5probs * w6))    ones(N, 1)];
    w7probs = [1 ./ (1 + exp(-w6probs * w7))    ones(N, 1)];
    mapping.recon = 1 ./ (1 + exp(-w7probs * w8));
    
    % Store network
    mapping.w1 = w1;
    mapping.w2 = w2;
    mapping.w3 = w3;
    mapping.w4 = w4;
    