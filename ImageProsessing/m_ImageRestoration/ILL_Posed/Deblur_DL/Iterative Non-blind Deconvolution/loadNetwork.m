function [net,lambda] = loadNetwork(net_path)
% net: weights of network
% lambda: deconvolution hyper-parameters


% load deconvolution hyper-parameters
load(fullfile(net_path, 'lambda.mat'));

% load weights of the first iteration
load(fullfile(net_path, 'iter1_weights.mat'))
for i=1:6
    net(1,i).w = gpuArray(weights(i).weights{1});
    net(1,i).b = gpuArray(weights(i).weights{2});
end

% load weights of the second iteration
load(fullfile(net_path, 'iter2_weights.mat'))
for i=1:6
    net(2,i).w = gpuArray(weights(i).weights{1});
    net(2,i).b = gpuArray(weights(i).weights{2});
end

% load weights of the third iteration
load(fullfile(net_path, 'iter3_weights.mat'))
for i=1:6
    net(3,i).w = gpuArray(weights(i).weights{1});
    net(3,i).b = gpuArray(weights(i).weights{2});
end
