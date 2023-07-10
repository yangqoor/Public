% New main function which computed the clusters in a different way
% HOW? 
% Get the set of points for each action class
num_manifold_steps = 2000;
%% Obtain outputs of training for the trained auto-encoders
% To show evidence set the opts.sizes - 
% vectors
color_code = {'b','r','g','k','c','m'};
%figure(1);
% h2 = figure(2);
% h3 = figure(3);
% outputs of sequences obtained from their respect autoencoder
Clusters = cell(size(Features,1),1); % first index is the cluster index and the second is the index to which each data point belongs to
%Sigmas = cell(size(Features,1),1);
%Weights = cell(size(Features,1),1);
MinMax_Vals = cell(size(Features,1),1);
Manifolds = cell(size(Features,1),1);

for k = 1:1:size(Features_train,1)
    % get the stacked auto-encoder
    st = sae{k};
    % get all the training vectors for action class k
    TrainingData = Features_train(k,:);
    Size = cellfun(fun_s,TrainingData);
    opts.seq_size = Size;

    % flip the matrices in each cell
    for ce = 1:1:length(TrainingData)
        if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
            TrainingData{ce} = [];
        end
        TrainingData{ce} = TrainingData{ce}';
    end
    Inputs = cell2mat(TrainingData);
    Inputs = Inputs';
    
    % compute the outputs from the auto-encoder
    [Inputs_out,a_inputs_out] = sae_nn_ff(st,Inputs);
     
    % compute the set of manifold steps as clusters of kmeans
    
    [C,I] = yael_kmeans(single(a_inputs_out'),num_manifold_steps,'init',0,'redo',10,'niter',1);
    %[w_C, C,sigma_C] = yael_gmm(single(a_inputs_out'),num_manifold_steps,'redo',10,'niter',100); 
    %[I,C] = kmeanspp(a_inputs_out',num_manifold_steps);
    C = double(C'); % number of rows refers to number of observation N x D
%     num_d1 = round(size(a_inputs_out,2) * 2/3);
%     num_d2 = size(a_inputs_out,2) - num_d1;
%     max_train_xy = max(train_xy(:));
%     min_train_xy = min(train_xy(:));
%     MinMax_Vals{k,1} = max_train_xy;
%     MinMax_Vals{k,2} = min_train_xy;
%     
%     % Setup the neural network
%     rand('state',0);
%     nn = nnsetup([num_d1 num_d2/2 num_d2]);
%     nn.testing = 0;
%     opts.numepochs = 5000;
%     opts.batchsize = 1000;
%     nn.activation_function = 'sigm';    %  Sigmoid activation function
%     nn.learningRate = 0.1;                %  Sigm require a lower learning rate
%     nn.output = 'linear';
%     
%     %train_xy = C;
%     num_of_batches = floor(size(a_inputs_out,1) / opts.batchsize);
%     
%     % getting the sample points
%     train_xy = a_inputs_out(1:num_of_batches * opts.batchsize,:);
%     
%     train_xy = (train_xy - min_train_xy)/(max_train_xy - min_train_xy);
%     
%     % get the training inputs and training outputs of the manifold
%     train_x = train_xy(:,1:num_d1);
%     train_y = train_xy(:,num_d1+1:num_d2+num_d1);
%     
%     nn = nntrain(nn,train_x,train_y,opts);
%     
%     Manifolds{k} = nn;
    
%     x = C(:,1); y = C(:,2); z = C(:,3);
%     
%     
%     foo = fit([x,y],z,'lowess');
%     figure(k);
%     plot(foo);
    
    figure(k);
    scatter3(C(:,1),C(:,2),C(:,3),'r','filled');
    
    figure(k+6);
    scatter3(a_inputs_out(:,1),a_inputs_out(:,2),a_inputs_out(:,3),'g*');
    
    %Clusters{k,1} = C;
    %Sigmas{k,1} = double(sigma_C);
    %Weights{k,1} = double(w_C);
    %Clusters{k,2} = I;
    
end

%% Finding a statistical equation/regression equation/network which can learn this manifold
% Here, for each action class, from the output of auto-encoder(d=30 dims), we learn a
% non-linear regression surface in d dimensions i.e x \in (0,d-1). The
% regressors are the variables (0,2/3 * d-1) and the response variables are
% (2/3*d, d). 



%% Computation of transition points along the manifold surface
% Here, from the regressors side, we take equal intervals from max to min,
% find the corresponding response variables for each action.
% These points will then be the transition points
% For each of these points in space, find the K-Nearest neoghbhors to
% approximate the variance surrounding the point 
% Set the variance of the transition points 



%% For each sequence, compute the feature responses to these transition points in the manifold.
% As we move along the sequence, the feature responses to the manifold also
% changes where some transition points stop firing and another set of
% transition points starts firing.


%% Train an RNN-RBM t