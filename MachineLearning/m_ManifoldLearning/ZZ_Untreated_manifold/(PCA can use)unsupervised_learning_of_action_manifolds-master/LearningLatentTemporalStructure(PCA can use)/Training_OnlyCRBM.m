% Training File
% Here, 2/3rd of the Features are used for training an auto-encoder and a
% CRBM. The trained auto-encoder and CRBM are saved for different
% combinations of the training and testing features.
clear all; clc;
addpath('/home/prci/Dropbox/ActionLocalization/Algorithm/FeatureExtraction');
load ForegroundFeatures;
load Background_Features;

% Parameters of training
num_of_runs = 1;
[num_of_actions,num_of_seqs] = size(Features);
num_of_sets = 4;
num_of_persons = 25;
max_num_of_subseqs = 4;
num_manifold_steps = 2000;
fun_s = @(x) size(x,1);

% Parameters for CRBM Training
opts_crbm.n{1} = 5;
opts_crbm.n{2} = 5;
opts_crbm.sizes = [100 100]; % originally 150
opts_crbm.gsd = 1;
opts_crbm.nt = 5; % number of previous frames used for computing weights in the current frame
opts_crbm.batchsize = 100;
opts_crbm.epsilon_w = 1e-5; % changed to 10^-4 because 10^-3 wasn't converging
opts_crbm.epsilon_bi = 1e-5;
opts_crbm.epsilon_bj = 1e-5;
opts_crbm.epsilon_A = 1e-5;
opts_crbm.epsilon_B = 1e-5;
opts_crbm.w_decay = 0.0002;
opts_crbm.momentum = 0.9;
opts_crbm.num_epochs = 500; % 2000 iterations not required as error is same at 500 iterations % 1000 iterations better but worse than 500
opts_crbm.numGibbs = 200;
opts_crbm.dropRate = 1;

fprintf('\n\n***************Training of CRBM Begin**********************\n\n');
fprintf('nt = %d\n',opts_crbm.nt);
fprintf('sizes = %d\n',opts_crbm.sizes(1));
fprintf('Number of iterations =%d\n',opts_crbm.num_epochs);

training_params_filename = sprintf('Training_Params.mat');
save(training_params_filename,'num_manifold_steps','max_num_of_subseqs','num_of_persons','num_of_sets');

%% Pre-processing of the features. Temporal filtering for each sequence

for rr = 1:1:num_of_runs
    
    % load SAE Workspace
    sae_filename = sprintf('SAE_Workspace_Run%d_OptimalAuto.mat',rr);
    load(sae_filename);
    % testIndex is already loaded by the SAE
    
    [Features_train,Features_test,params]  = getFeaturesTrain(Features,testIndex);
 
    % getting the background of the training sequences
    Features_train_bg  = getFeaturesTrain_bg(Features_bg(4:6,:),testIndex,params);
    TrainingData_bg = Features_train_bg(:);
    
    Features_test_bg  = getFeaturesTest_bg(Features_bg(4:6,:),testIndex,params);
    TestingData_bg = Features_test_bg(:);
    [num_of_actions,num_of_seqs_train] = size(Features_train);
    [~,num_of_seqs_test] = size(Features_test);
    
    % Load the clusters for this runCluster_Workspace_Run_OptimalAuto
    clusters_filename = sprintf('Cluster_Workspace_Run%d_OptimalAuto.mat',rr);
    load(clusters_filename);
    
    % Load the SVM Classifiers
    svm_filename = sprintf('SVM_Workspace_Run%d_OptimalAuto.mat',rr);
    load(svm_filename);
    
    %%%%%%%%%%%%%%%%%%%%%% CRBM TRAINING %%%%%%%%%%%%%%%%%%%%%%%%%%

    % cell array holding structures for the trained crbm model
    crbm = cell(num_of_actions,1);
    opts_crbm_per_action = cell(num_of_actions,1);
    a_crbm_train_inputs_per_action = cell(num_of_actions,1);
    for act_num = 1:1:num_of_actions
        % get the stacked auto-encoder
        st = sae{act_num};
        
        % get all the training vectors for action class 'act_num'
        TrainingData = Features_train(act_num,:);
        Size = cellfun(fun_s,TrainingData);
        
        % Iterate through each sequence
        a_crbm_train_inputs = [];
        for ce = 1:1:length(TrainingData)       
            % Check for nan values
            if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
                TrainingData{ce} = [];
            end

            % Check if empty
            train_seq = TrainingData{ce};
            if(isempty(train_seq))
                continue;
            end

            % Find the nearest neighbors of the test sequence among the set of
            % codewords
            [ids,dis] = yael_nn(single(global_C'),single(train_seq'));
            num_train_frames = size(train_seq,1);

            % Replace each frame with the codeword
            X_train = zeros(num_train_frames,size(train_seq,2));
            for k = 1:1:num_train_frames
                X_train(k,:) = global_C(ids(k),:);
            end

            % Remove consecutive duplicate codewords in the sequences
            last_codeword_encoun = X_train(1,:);
            dup_ids = zeros(num_train_frames,1);
            for k = 2:1:num_train_frames
                sum_dist = sum(sum((last_codeword_encoun - X_train(k,:)).^2));
                if(sum_dist == 0) % duplicate : no change in last_codeword seen
                    dup_ids(k) = 1;
                else % if no duplicate
                    last_codeword_encoun = X_train(k,:);
                end
            end
            non_dup_ids = (~dup_ids);
            rel_ids = find(non_dup_ids ~= 0);

            % Selecting only the transitions
            X_train = X_train(rel_ids,:);
            num_frames_gen = size(X_train,1);

            % apply the auto-encoder to each action class
            [X_train_out,a_X_train_out] = sae_nn_ff(st,X_train);
            
            a_crbm_train_inputs = [a_crbm_train_inputs ; a_X_train_out];
            Size(ce) = size(a_X_train_out,1);
        end
        
        a_crbm_train_inputs_per_action{act_num} = a_crbm_train_inputs;
        
        opts_crbm_per_action{act_num} = opts_crbm;
        opts_crbm_per_action{act_num}.seq_lengths = Size;
    end
    
    % Training for each action class
    parfor act_num = 1:1:num_of_actions

        % training to model transitions from codeword to the next
        crbm{act_num} = trainCRBM(a_crbm_train_inputs_per_action{act_num},opts_crbm_per_action{act_num});
        
        
        fprintf('\n\n************************** COMPLETED CRBM TRAINING FOR ACTION CLASS %d. RUN: %d **********************************\n\n',act_num,rr); 
        
    end
    
    crbm_filename = sprintf('CRBM_Workspace_Run%d_OptimalAuto.mat',rr);
    %crbm_filename = sprintf('CRBM_Workspace_Run%d_OptimalAuto_MoreIterations.mat',rr);
    save(crbm_filename,'crbm','opts_crbm_per_action');
    
    fprintf('\n\n ************************ END OF TRAINING : RUN %d *******************************\n\n',rr);
    
end
