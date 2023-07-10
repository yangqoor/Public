% Script file to train auto-encoders
% loading the features
%load -mat ActionFeatures_KTH_EqualDiv_New_Ver8_WithVLBP
%max_num_of_subseqs = 4;
num_manifold_steps = 100;
%win_size = 15;
%overlap = 14;
%% Select an arbitrary train and test set
testIndex = 2;
% get the training set
[Features_train,Features_test] = getFeaturesTrain(Features,testIndex);
[num_of_actions,num_of_seqs_train] = size(Features_train);
[~,num_of_seqs_test] = size(Features_test);

% Training Autoencoder for each class
%setting options
opts.epsilon_w = 0.1;
opts.epsilon_vb = 0.1;
opts.epsilon_vc = 0.1;
opts.momentum = 0.9;
opts.weightcost = 0.0002;
opts.numepochs = 50;
opts.sizes = [100 30];

% iterate through each action class
sae = cell(num_of_actions,1);
for act_num = 1:1:num_of_actions
    % cumulate all features into one matrix with the sequence offsets
    fun_s = @(x) size(x,1);
    TrainingData = Features_train(act_num,:);
    Size = cellfun(fun_s,TrainingData);

    % flip the matrices in each cell
    for ce = 1:1:length(TrainingData)
        if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
            TrainingData{ce} = [];
        end
        
        % perform median filtering
        TrainingData{ce} = performTemporalFiltering(TrainingData{ce},5);
        Size(ce) = size(TrainingData{ce},1);
        
        % Flip the matrix to convert to cell
        TrainingData{ce} = TrainingData{ce}';
    end
    Inputs = cell2mat(TrainingData);
    Inputs = Inputs';
    
    opts.seq_size = Size;
    sae{act_num} = stacked_autoencoder(Inputs,opts,true);
    %[pc,net] = nlpca(Inputs,3); // Command takes super long time!!!
    
    fprintf('\n\t********************TRAINING AUTO-ENCODER FOR ACTION %d COMPLETED************************************\n',act_num); 
end