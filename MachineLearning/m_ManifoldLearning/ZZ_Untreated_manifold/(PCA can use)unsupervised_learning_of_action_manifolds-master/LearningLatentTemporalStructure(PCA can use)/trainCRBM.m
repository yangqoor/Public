% function which takes in the set of feature vectors obtained from
% the auto-encoder  
% X : inputs of dimensions N x D ( number of points multiplied by D)
% crbm : structure which holds the trained CRBM model
function crbm = trainCRBM(X,opts)


%%%%%%%%%%%%%%%%% NETWORK PROPERTIES %%%%%%%%%%%%%%%%%%%%%%%
% basic parameters to set up the CRBM ( Conditional Restricted Boltzmann
% Machine ) 
rand('state',sum(100*clock));
randn('state',sum(100*clock));

crbm.total_num_cases = size(X,1); % number of frames
crbm.num_input_dims = size(X,2); % number of visible units

% downsampling parameter
crbm.sizes = [crbm.num_input_dims opts.sizes]; % should be opts.sizes
crbm.num_layers = numel(crbm.sizes)-1; % should be opts.num_layers
crbm.gsd = 1; % should be opts.gsd ; gaussian standard deviation
crbm.modes = {'Gaussian','Binary'};
crbm.mode_str = 'Gaussian';
crbm.dropRate = opts.dropRate;
crbm.numGibbs = opts.numGibbs;

% setting the order of each layer : the order refers to how many
% previous time-steps does it depend on
for ii = 1:1:crbm.num_layers
    
    % intialize the weights and the biases of the rbm associated with it.
    num_hid = crbm.sizes(ii+1);
    num_dims = crbm.sizes(ii);
    nt = opts.nt; % opts.nt
    
    crbm.rbm{ii}.nt = nt;
    crbm.rbm{ii}.num_dims = num_dims;
    crbm.rbm{ii}.num_hid = num_hid;
    
    % intialize the weights of a single time step RBM
    crbm.rbm{ii}.w = 0.01*randn(num_hid,num_dims);
    crbm.rbm{ii}.bi = 0.01 * randn(num_dims,1);
    crbm.rbm{ii}.bj = -1 + 0.01 * randn(num_hid,1);
    
    % Initializing auto-regressive weights ; connecting the weights for
    % visible layers at previous time instants to the current visible layer
    crbm.rbm{ii}.A = 0.01 * randn(num_dims,num_dims,nt);
    
    % Initializing the temporal hidden weights : weights connecting from
    % the visible layers at previous time instants to the current hidden
    % layer
    crbm.rbm{ii}.B = 0.01 * randn(num_hid,num_dims,nt);
    
    % Initializing weight updates 
    crbm.rbm{ii}.w_update = zeros(size(crbm.rbm{ii}.w));
    crbm.rbm{ii}.bi_update = zeros(size(crbm.rbm{ii}.bi));
    crbm.rbm{ii}.bj_update = zeros(size(crbm.rbm{ii}.bj));
    crbm.rbm{ii}.A_update = zeros(size(crbm.rbm{ii}.A));
    crbm.rbm{ii}.B_update = zeros(size(crbm.rbm{ii}.B));
    
    % Setting the RBM train parameters
    crbm.rbm{ii}.epsilon_w = opts.epsilon_w; % undirected connections between visible and hidden at current state
    crbm.rbm{ii}.epsilon_bi = opts.epsilon_bi; % bias for visible update factor
    crbm.rbm{ii}.epsilon_bj = opts.epsilon_bj; % bias for hidden update factor
    crbm.rbm{ii}.epsilon_A = opts.epsilon_A; % auto-regressive update factor
    crbm.rbm{ii}.epsilon_B = opts.epsilon_B; % previous visible to hidden update factor
    crbm.rbm{ii}.w_decay = opts.w_decay;
    crbm.rbm{ii}.momentum = opts.momentum;
    crbm.rbm{ii}.num_epochs = opts.num_epochs; % should be opts.num_epochs
    crbm.rbm{ii}.gsd = opts.gsd;
end

crbm.batchsize = opts.batchsize; %% opts.batchsize

% preprocess2 : the batchdata is nothing but accumulation of frames
%from all possible sequences. Here, the input X is the batchdata

%%%%%%%%%SETTING UP TRAINING PARAMETERS AND TRAINING BATCHES %%%%%%%%%%%%%%%%

% data normalization
crbm.data_mean = mean(X,1); %%% NEED TO USE THESE TO NORMALIZE TEST DATA FOR SEQUENCE GENERATION
crbm.data_std = std(X,1);
X_norm = (X - repmat(crbm.data_mean,crbm.total_num_cases,1))./repmat(crbm.data_std,crbm.total_num_cases,1);

% Obtain the sequence lengths for that action class
crbm.seq_lengths = opts.seq_lengths; % an array containing the sequence length

% generate the frame indicies for each sequence for mini-batch training
% will contain the valid starting frame 
for jj = 1:1:length(crbm.seq_lengths) % iterate through each sequence
    if jj==1 % first sequence
        batchdataindex = opts.n{1}+1:crbm.seq_lengths(jj);
    else
        batchdataindex = [batchdataindex batchdataindex(end)+opts.n{1}+1:batchdataindex(end)+crbm.seq_lengths(jj)];
    end
end

% randomize the selection of the starting frames
permindex = batchdataindex(randperm(length(batchdataindex)));

% the number of full batches obtained from the trainined set
numfullbatches = floor(length(permindex)/crbm.batchsize);

% divide the training set into mini-batches ( without validation
% mini-batches)
minibatchindex = reshape(permindex(1:crbm.batchsize*numfullbatches),crbm.batchsize,numfullbatches);
minibatchindex = minibatchindex'; % the dimensions are number of batches x number of starting frames per batch

% converting the mini-batch index into a cell array
minibatch = num2cell(minibatchindex,2);
leftover = permindex(crbm.batchsize*numfullbatches+1:end);
minibatch = [minibatch ; num2cell(leftover,2)]; % this changes every loop ( each loop is training a single RBM layer)

% can create initial data for generating the sequence
% training the layer with the mini-batch data
mo = 1;
flag_gaussian = true;
X_next = X_norm; % This was not initially used for training

for ii = 1:1:crbm.num_layers
    if(ii ~= 1)
        flag_gaussian = false;
    end
    
    crbm.rbm{ii} = crbm_train_layer(crbm.rbm{ii},X_next,minibatch,flag_gaussian);
    
    % Write/Call a function to permeate the data through the trained layer
    % the outputs should be fed to the next layer : this is the
    % "getfilteringdist"
    num_cases = length(batchdataindex);
    num_hid = crbm.rbm{ii}.num_hid;
    num_dims = crbm.rbm{ii}.num_dims;
    nt = crbm.rbm{ii}.nt;
    gsd = crbm.rbm{ii}.gsd;
    
    fprintf(1,'\n\n****************Trained Layer %d CRBM, order %d: %d-%d**********************\n \n',ii,nt,num_dims,num_hid);
    
    if(ii == crbm.num_layers)
        % do something after training the last layer
        continue;
    end
    
    bj_star = zeros(num_hid,num_cases);
    for hh = 1:1:nt
        bj_star = bj_star + crbm.rbm{ii}.B(:,:,hh)* X_next(batchdataindex-hh,:)';
    end
    
    bottomup = crbm.rbm{ii}.w * (X_next(batchdataindex,:)./gsd)';
    
    eta = bottomup + repmat(crbm.rbm{ii}.bj,1,num_cases) + bj_star;
    
    filteringdist = 1./(1 + exp(-eta'));
    
    for jj = 1:1:length(crbm.seq_lengths) % iterate through each sequence
        if jj==1 % first sequence
            batchdataindex = opts.n{ii+1}+1:crbm.seq_lengths(jj)-opts.n{ii};
        else
            if(isempty(batchdataindex))
                batchdataindex = opts.n{ii+1}+1:crbm.seq_lengths(jj)-opts.n{ii};
            else
                batchdataindex = [batchdataindex batchdataindex(end)+opts.n{ii+1}+1:batchdataindex(end)+crbm.seq_lengths(jj)-opts.n{ii}];
            end
        end
    end
    
    % randomize the selection of the starting frames
    permindex = batchdataindex(randperm(length(batchdataindex)));
    
    % the number of full batches obtained from the trainined set
    numfullbatches = floor(length(permindex)/crbm.batchsize);
    
    minibatchindex = reshape(permindex(1:crbm.batchsize*numfullbatches),crbm.batchsize,numfullbatches);
    minibatchindex = minibatchindex'; % the dimensions are number of batches x number of starting frames per batch

    % converting the mini-batch index into a cell array
    minibatch = num2cell(minibatchindex,2);
    leftover = permindex(crbm.batchsize*numfullbatches+1:end);
    minibatch = [minibatch ; num2cell(leftover,2)];
    
    % inputs for next layer
    X_next = filteringdist;
    
end

%% Fine Tuning using gradient descent
% Here, this portion of the code is used to learn the gradient descent
% where the error between the next 'nt' frames from the initial '2*nt'
% frames. This portion of the code should be similar to testCRBM code but
% with an additional step where the error is computed and used in
% minimization problem to obtain the optimal weights. Do this if the test
% results from the pre-trained weights are very bad. 

end

