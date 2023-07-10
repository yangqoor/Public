clear
rand('seed', 100000)
randn('seed', 100000)

% add cnn, data and visualization folders
addpath(genpath('cnn'));
addpath(genpath('data set'));
addpath(genpath('visualize'));

% Configuration of the LeNet

% First layer is data
layers{1}.type = 'DATA';
layers{1}.height = 28;
layers{1}.width = 28;
layers{1}.channel = 1;
layers{1}.batch_size = 64;

% Second layer is the convolution layer
layers{2}.type = 'CONV';
layers{2}.num = 20; % # of output channels
layers{2}.k = 5; % kernel size
layers{2}.stride = 1; % stride size
layers{2}.pad = 0; % padding size
layers{2}.group = 1; % group of input feature maps

% Third layer is pooling layer 
layers{3}.type = 'POOLING'; 
layers{3}.act_type = 'MAX'; % use either max or mean pooling
layers{3}.k = 2; % kernel size
layers{3}.stride = 2; % stride size
layers{3}.pad = 0; % padding size

% Another convolution layer as the fourth layer
layers{4}.type = 'CONV';
layers{4}.k = 5;
layers{4}.stride = 1;
layers{4}.pad = 0;
layers{4}.group = 1;
layers{4}.num = 50;

% Another pooling as the fifth layer
layers{5}.type = 'POOLING';
layers{5}.act_type = 'MAX';
layers{5}.k = 2;
layers{5}.stride = 2;
layers{5}.pad = 0;

% Sixth layer is fully-connected inner product layer
layers{6}.type = 'IP'; 
layers{6}.num = 500; % # of output dimension
layers{6}.init_type = 'uniform'; % initialization method, Gaussian and uniform are provided. 

% ReLu layer
layers{7}.type = 'RELU'; % relu layer

layers{8}.type = 'LOSS'; % loss layer
layers{8}.num = 10; % number of classes (10 digits)


% Load data
% Data of all classes are shuffled
load_mnist_all

xtrain = [xtrain, xvalidate];
ytrain = [ytrain, yvalidate];
m_train = size(xtrain, 2);
batch_size = 64; % power of 2 for faster matrix operation

% Learning rate parameters
mu = 0.9; % Momentum update for faster converge
epsilon = 0.01; % Initialize learning rate
gamma = 0.0001; 
power = 0.75;
weight_decay = 0.0005; % Decaying weight to avoid over-shooting at the later stage of GDS

% Initialize parameters in all layers
params = init_convnet(layers);

% Display setting
test_interval = 500;
display_interval = 10;
snapshot = 5000;
max_iter = 10000;

% Buffer for SGD momentum
param_winc = params;
for l_idx = 1:length(layers)-1
    param_winc{l_idx}.w = zeros(size(param_winc{l_idx}.w));
    param_winc{l_idx}.b = zeros(size(param_winc{l_idx}.b));
end

for iter = 1 : max_iter
    % Minibath is practically faster than SGD
	% Randomly fetch a batch, but let's see if fetching in order continuously is better
    id = randi([1 m_train], batch_size, 1);

    % Forward and backward propagations
    [cp, param_grad] = conv_net(params, layers, xtrain(:, id), ytrain(id));

    % Update the decaying learning rate
    rate = get_lr(iter, epsilon, gamma, power);

    % Update parameters with momentum
    [params, param_winc] = sgd_momentum(rate, mu, weight_decay, params, param_winc, param_grad);

    if mod(iter, display_interval) == 0
        fprintf('iteration %d training cost = %f accuracy = %f\n', iter, cp.cost, cp.percent);
    end
    
    % Peek the test accuracy
    if mod(iter, test_interval) == 0
        layers{1}.batch_size = 10000;
        [cptest] = conv_net(params, layers, xtest, ytest);
        layers{1}.batch_size = 64;
        fprintf('test accuracy: %f \n\n', cptest.percent);

    end
    % Save learnt net parameters
    if mod(iter, snapshot) == 0
        filename = 'lenet.mat';
        save(filename, 'params');
    end
end
