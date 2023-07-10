% Version 1.000
%
% Code provided by Ruslan Salakhutdinov and Geoff Hinton
%
% Permission is granted for anyone to copy, use, modify, or distribute this
% program and accompanying programs and documents for any purpose, provided
% this copyright notice is retained and prominently displayed, along with
% a note saying that the original programs are available from our
% web page.
% The programs and documents are distributed without any warranty, express or
% implied.  As the programs were written for research purposes only, they have
% not been tested to the degree that would be advisable in any important
% application.  All use of these programs is entirely at the user's own risk.

% This program fine-tunes an autoencoder with backpropagation.
% Weights of the autoencoder are going to be saved in mnist_weights.mat
% and trainig and test reconstruction errors in mnist_error.mat
% You can also set maxepoch, default value is 200 as in our paper.
%
%

% This file is part of the Matlab Toolbox for Dimensionality Reduction v0.2b.
% The toolbox can be obtained from http://www.cs.unimaas.nl/l.vandermaaten
% You are free to use, change, or redistribute this code in any way you
% want. However, it is appreciated if you maintain the name of the original
% author.
%
% (C) Laurens van der Maaten
% Maastricht University, 2007

    % Initialize variables
    disp(' ');
    disp('Pretraining complete. Performing finetuning of autoencoder...');
    maxepoch = 200;
    [numcases numdims numbatches] = size(batchdata);
    N = numcases; 

    % Initialize weights of the autoencoder
    w1 = [vishid;   hidrecbiases];
    w2 = [hidpen;   penrecbiases];
    w3 = [hidpen2;  penrecbiases2];
    w4 = [hidtop;   toprecbiases];
    w5 = [hidtop';  topgenbiases]; 
    w6 = [hidpen2'; hidgenbiases2]; 
    w7 = [hidpen';  hidgenbiases]; 
    w8 = [vishid';  visbiases];

    % Store sizes of weights matrices
    l1 = size(w1, 1) - 1;
    l2 = size(w2, 1) - 1;
    l3 = size(w3, 1) - 1;
    l4 = size(w4, 1) - 1;
    l5 = size(w5, 1) - 1;
    l6 = size(w6, 1) - 1;
    l7 = size(w7, 1) - 1;
    l8 = size(w8, 1) - 1;
    l9 = l1;
    
    for epoch=1:maxepoch               
        % Perform conjugate gradient minimization method with 3 linesearches
        max_iter = 3;
        VV = [w1(:)' w2(:)' w3(:)' w4(:)' w5(:)' w6(:)' w7(:)' w8(:)']';
        Dim = [l1; l2; l3; l4; l5; l6; l7; l8; l9];
        [X, fX] = minimize(VV, 'cg_update', max_iter, Dim, batchdata);

        % Reconstruct weights from X
        w1 = reshape(X(1:(l1 + 1) * l2), l1 + 1, l2);
        xxx = (l1 + 1) * l2;
        w2 = reshape(X(xxx + 1:xxx + (l2 + 1) * l3), l2 + 1, l3);
        xxx = xxx + (l2 + 1) * l3;
        w3 = reshape(X(xxx + 1:xxx + (l3 + 1) * l4), l3 + 1, l4);
        xxx = xxx + (l3 + 1) * l4;
        w4 = reshape(X(xxx + 1:xxx + (l4 + 1) * l5), l4 + 1, l5);
        xxx = xxx + (l4 + 1) * l5;
        w5 = reshape(X(xxx + 1:xxx + (l5 + 1) * l6), l5 + 1, l6);
        xxx = xxx + (l5 + 1) * l6;
        w6 = reshape(X(xxx + 1:xxx + (l6 + 1) * l7), l6 + 1, l7);
        xxx = xxx + (l6 + 1) * l7;
        w7 = reshape(X(xxx + 1:xxx + (l7 + 1) * l8), l7 + 1, l8);
        xxx = xxx + (l7 + 1) * l8;
        w8 = reshape(X(xxx + 1:xxx + (l8 + 1) * l9), l8 + 1, l9);

        % Check if minimum reached
        if(X == VV), break; end
    end
    
    % Training is now complete; provide some info on the network ---------
    
    % Compute training reconstruction error
    train_err = 0;
    [numcases numdims numbatches] = size(batchdata);
    N = numcases;
    % Put data into network and extract output
    data = [batchdata ones(N, 1)];
    w1probs = 1 ./ (1 + exp(-data * w1));       w1probs = [w1probs ones(N,1)];
    w2probs = 1 ./ (1 + exp(-w1probs * w2));    w2probs = [w2probs ones(N,1)];
    w3probs = 1 ./ (1 + exp(-w2probs * w3));    w3probs = [w3probs ones(N,1)];
    w4probs = w3probs * w4;                     w4probs = [w4probs ones(N,1)];
    w5probs = 1 ./ (1 + exp(-w4probs * w5));    w5probs = [w5probs ones(N,1)];
    w6probs = 1 ./ (1 + exp(-w5probs * w6));    w6probs = [w6probs ones(N,1)];
    w7probs = 1 ./ (1 + exp(-w6probs * w7));    w7probs = [w7probs ones(N,1)];
    dataout = 1 ./ (1 + exp(-w7probs * w8));
    % Accumulate with squared error
    train_err = (1 / numcases) * sum(sum((data(:,1:end-1) - dataout) .^ 2));
    
    % Compute test reconstruction error
    test_err = 0;
    [testnumcases testnumdims testnumbatches] = size(testbatchdata);
    N = testnumcases;
    % Put data into network and extract output
    data = [testbatchdata ones(N, 1)];
    w1probs = 1 ./ (1 + exp(-data * w1));       w1probs = [w1probs ones(N,1)];
    w2probs = 1 ./ (1 + exp(-w1probs * w2));    w2probs = [w2probs ones(N,1)];
    w3probs = 1 ./ (1 + exp(-w2probs * w3));    w3probs = [w3probs ones(N,1)];
    w4probs = w3probs * w4;                     w4probs = [w4probs ones(N,1)];
    w5probs = 1 ./ (1 + exp(-w4probs * w5));    w5probs = [w5probs ones(N,1)];
    w6probs = 1 ./ (1 + exp(-w5probs * w6));    w6probs = [w6probs ones(N,1)];
    w7probs = 1 ./ (1 + exp(-w6probs * w7));    w7probs = [w7probs ones(N,1)];
    dataout = 1 ./ (1 + exp(-w7probs * w8));
    % Accumulate with squared error
    test_err = (1 / testnumcases) * sum(sum((data(:,1:end-1) - dataout) .^ 2));

    % Print out errors
    fprintf(1, 'Training completed.\nTraining data squared error: %4.6f\nTest data squared error: %4.6f\n', train_err, test_err);




