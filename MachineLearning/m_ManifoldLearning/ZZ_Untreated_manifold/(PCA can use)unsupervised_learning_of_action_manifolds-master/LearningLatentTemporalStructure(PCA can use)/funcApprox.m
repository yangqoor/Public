% function which uses a MLP pre-trained with an RBM to learn the functional
% mapping from a multi-variable regressor with a multi-variate response
% variable
% Uses the deep learning toolbox
% X - N x D
% Y - N x d
function fn = funcApprox(X,Y,opts)

% Use a three layer approach (same as MLP)
dim_X = size(X,2);
dim_Y = size(Y,2);
num_of_points = size(X,1); % number of points or observations

fn.sizes = [dim_X opts.sizes dim_Y]; 
num_rbms = numel(fn.sizes) - 2; % the last layer is not trained with RBM

% Pre-train the weights of the first layer with RBM for initialization
% randomize the hidden-output layer
fprintf('Pretraining the network with %d RBMs\n',num_rbms);

% initialize the corresponding rbms in the deep belief architecture
for u = 1:1:num_rbms
    % setting the options for each rbm
    fn.rbm{u}.epsilon_w = opts.epsilon_w;
    fn.rbm{u}.epsilon_vb = opts.epsilon_vb;
    fn.rbm{u}.epsilon_vc = opts.epsilon_vc;
    fn.rbm{u}.momentum = opts.momentum;
    fn.rbm{u}.weightcost = opts.weightcost;
    
    % initializing the weights and weight increments of each rbm
    fn.rbm{u}.W = 0.1 * randn(fn.sizes(u+1),fn.sizes(u));
    fn.rbm{u}.del_W = zeros(fn.sizes(u+1),fn.sizes(u));
    
    % bias for visible 
    fn.rbm{u}.bv = zeros(fn.sizes(u),1);
    fn.rbm{u}.del_bv = zeros(fn.sizes(u),1);
    
    % bias for hidden
    fn.rbm{u}.bh = zeros(fn.sizes(u+1),1);
    fn.rbm{u}.del_bh = zeros(fn.sizes(u+1),1);
end

% Pre-training the layers with RBMs
X_next = X;
fprintf('\nTraining the %d RBM\n',1);
fn.rbm{1} = rbmtrain_seq(fn.rbm{1},X_next,opts,flag_seq);
% training the middle layers
for u = 2:1:num_rbms-1
    X_next = applyRBM(fn.rbm{u-1},X_next);
    fprintf('\nTraining the %d RBM\n',u);
    %X_next = rbmup(sae.rbm{u-1},X_next); % propagating and obtaining the outputs of previous rbm
    fn.rbm{u} = rbmtrain_seq(fn.rbm{u},X_next,opts,flag_seq); 
end

% Now initializing the neural network with the corresponding RBM weights
for u = 1:1:num_rbms
    fn.W{u} = 0.1*randn(fn.sizes(u+1),fn.sizes(u)+1); % the plus one is for adding the bias term
    fn.W{u} = [fn.rbm{u}.W fn.rbm{u}.bh]; % appending the hidden biases with the weights as the total set of weights in the neural network
end
% initializing the last layer with random weights
fn.W{u} = 0.1*randn(fn.sizes(end),fn.sizes(end-1));

% Do back-propagation learning the second layer outputs and for fine tuning 
% Fine-tuning back-propagation training of sae
opts.numepochs = opts.numepochs * 1.5;
fprintf('\nPreTraining complete\n');
fprintf('Training the neural network as a function approximator\n');

% output the function network with the Input X and Input Y


end

