% Training File
% Here, 2/3rd of the Features are used for training an auto-encoder and a
% CRBM. The trained auto-encoder and CRBM are saved for different
% combinations of the training and testing features.
clear all; clc;
addpath('/home/prci/Dropbox/ActionLocalization/Algorithm/FeatureExtraction');
addpath('/home/prci/Dropbox/ActionLocalization/Algorithm/LearningLatentTemporalStructure');
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

% size for autoencoder
auto_sizes{1} = [100 30];
auto_sizes{2} = [100 60];
auto_sizes{3} = [200 60];
auto_sizes{4} = [200 120];
auto_sizes{5} = [300 120];
auto_sizes{6} = [300 150];
auto_sizes{7} = [100 60 30];
auto_sizes{8} = [200 120 60];
auto_sizes{9} = [300 150 75];
auto_sizes{10} = [2000 1000 500 30];
auto_sizes{11} = [1000 500 30];
auto_sizes{12} = [1000 100];
auto_sizes{13} = [1000 500];
auto_sizes{14} = [1000 250];

% Setting params for testing strategy
test_params.win_lengths = [10,15,20,25,30];
test_params.win_overlap = [5,10,15,20,25];

for sz = 2%5:1:9
    %auto_sizes{sz}
    % Parameters for auto-encoder
    opts_auto.epsilon_w = 0.1;
    opts_auto.epsilon_vb = 0.1;
    opts_auto.epsilon_vc = 0.1;
    opts_auto.momentum = 0.9;
    opts_auto.weightcost = 0.0002;
    opts_auto.numepochs = 200; % these many iterations are enough
    %opts_auto.sizes = [200 120]; % the second layer as same as the original layer
    opts_auto.sizes = auto_sizes{sz};
    
    % Parameters for SVM Training
    C_val = 10;
    opts_svm = sprintf('-s 0 -t 4 -c %d -b 1 -q',C_val);
    
    training_params_filename = sprintf('Training_Params.mat');
    save(training_params_filename,'num_manifold_steps','max_num_of_subseqs','num_of_persons','num_of_sets');
    
    sae_workspace = cell(num_of_persons,1);
    clusters_workspace = cell(num_of_persons,1);
    svm_workspace = cell(num_of_persons,1);
    
    %% Pre-processing of the features. Temporal filtering for each sequence
    %testIndex = [9    25    10    24    18    19     5     6];
    num_of_runs = num_of_persons;
    parfor rr = 1:num_of_runs
        % 2/3rd of training ; 1/3rd of testing
        % select random 1/3rd of the person
        %testIndex = randperm(num_of_persons, floor(1/3 * num_of_persons));
        tid_train = tic;
        testIndex = rr;
        [Features_train,Features_test,params]  = getFeaturesTrain(Features,testIndex);
        
        % getting the background of the training sequences
        Features_train_bg  = getFeaturesTrain_bg(Features_bg(4:6,:),testIndex,params);
        TrainingData_bg = Features_train_bg(:);
        
        Features_test_bg  = getFeaturesTest_bg(Features_bg(4:6,:),testIndex,params);
        TestingData_bg = Features_test_bg(:);
        [num_of_actions,num_of_seqs_train] = size(Features_train);
        
        %%%%%%%%%%%% Setting up the data %%%%%%%%%%%%%%%%%%%%
        % iterate through each action class
        sae = cell(num_of_actions,1);
        fun_s = @(x) size(x,1);
        opts_auto_per_action = cell(num_of_actions,1);
        Inputs_per_action = cell(num_of_actions,1);
        % Accumulate the Inputs per action
        for act_num = 1:1:num_of_actions
            % cumulate all features into one matrix with the sequence offsets
            
            TrainingData = Features_train(act_num,:);
            Size = cellfun(fun_s,TrainingData);
            
            % flip the matrices in each cell
            for ce = 1:1:length(TrainingData)
                if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
                    TrainingData{ce} = [];
                end
                
                %             % perform median filtering
                %             TrainingData{ce} = performTemporalFiltering(TrainingData{ce},5);
                %             Size(ce) = size(TrainingData{ce},1);
                
                % Flip the matrix to convert to cell
                TrainingData{ce} = TrainingData{ce}';
            end
            Inputs = cell2mat(TrainingData);
            Inputs = Inputs';
            Inputs_per_action{act_num} = Inputs;
            
            opts_auto_per_action{act_num} = opts_auto;
            opts_auto_per_action{act_num}.seq_size = Size;
        end
        
        %%%%%%%%%%%%%%%% AUTO-ENCODER TRAINING %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Training the Stacked Auto-Encoder parallely
        %parfor
        for act_num = 1:num_of_actions
            sae{act_num} = stacked_autoencoder(Inputs_per_action{act_num},opts_auto_per_action{act_num},true);
            fprintf('\n\t********************TRAINING AUTO-ENCODER FOR ACTION %d COMPLETED RUN: %d ************************************\n',act_num,rr);
        end
        
        %sae_filename = sprintf('SAE_Workspace_Run%d_AutoEncoder_Sizes_%d_%d_LOOP.mat',rr,opts_auto.sizes(1),opts_auto.sizes(2));
        %save(sae_filename,'sae','opts_auto','Features_train','Features_test','testIndex');
        
        sae_workspace{rr}.sae = sae;
        sae_workspace{rr}.opts_auto = opts_auto;
        
        %%%%%%%%%%%%%%%%%%%%% Computing Global clusters %%%%%%%%%%%%%%%%%
        clusters = cell(num_of_actions,1);
        %parfor
        for act_num = 1:num_of_actions
            
            % get the stacked auto-encoder
            st = sae{act_num};
            
            % compute the outputs from the auto-encoder of class 'act_num'
            [Inputs_out,a_inputs_out] = sae_nn_ff(st,Inputs_per_action{act_num});
            
            % Perform clustering to get suitable approximation of manifold
            [C,I] = yael_kmeans(single(a_inputs_out'),num_manifold_steps,'init',0,'redo',10,'niter',100);
            C = double(C');
            
            fprintf('\n*** Finished computing clusters for action class %d. RUN: %d ******\n',act_num,rr);
            
            clusters{act_num} = C;
        end
        
        global_C = [];
        global_C_indices = [];
        for act_num = 1:1:num_of_actions
            C = clusters{act_num};
            st = sae{act_num};
            
            % project the clusters back into the input space
            C_input = sae_ff_nn_decoder(st,C);
            
            global_C = [global_C ; C_input];
            
            if(act_num == 1)
                global_C_indices = 1:1:num_manifold_steps;
            else
                global_C_indices = [global_C_indices  (global_C_indices(end) + 1: global_C_indices(end) + num_manifold_steps)];
            end
        end
        
        %clusters_filename = sprintf('Cluster_Workspace_Run%d_Sizes_%d_%d_LOOP.mat',rr,opts_auto.sizes(1),opts_auto.sizes(2));
        %save(clusters_filename,'clusters','global_C','global_C_indices');
        clusters_workspace{rr}.clusters = clusters;
        clusters_workspace{rr}.global_C = global_C;
        clusters_workspace{rr}.global_C_indices = global_C_indices;
        fprintf('\n*** Finished computing global clusters per action class. RUN: %d ******\n',rr);
        
        %%%%%%%%%%%%%%%%%%%% Training SVM Classifier per action %%%%%%%%%
        neg_data_svm = cell2mat(TrainingData_bg);
        neg_data_idx = randperm(size(neg_data_svm,1),num_manifold_steps*6);
        neg_data_svm = neg_data_svm(neg_data_idx,:);
        
        % Selecting only a few training points
        [C,I] = yael_kmeans(single(neg_data_svm'),num_manifold_steps*2,'init',0,'redo',10,'niter',100);
        neg_data_svm = double(C');
        
        neg_data_svm_test = cell2mat(TestingData_bg);
        pos_data_svm = [];
        pos_data_svm_test = [];
        for act_num = 1:1:num_of_actions
            
            % get the stacked auto-encoder
            st = sae{act_num};
            C = clusters{act_num};
            
            % reconstruct the clusters
            C_input = sae_ff_nn_decoder(st,C);
            
            % accumulating the clusters in the input space
            pos_data_svm = [pos_data_svm ; C_input];
            
            pos_data_svm_test = [pos_data_svm_test ; cell2mat(Features_test(act_num,:)')];
            
        end
        
        % Selecting only a few training points
        [C,I] = yael_kmeans(single(pos_data_svm'),num_manifold_steps,'init',0,'redo',10,'niter',100);
        pos_data_svm = double(C');
        
        a_data = [pos_data_svm ; neg_data_svm];
        K_data = slmetric_pw(a_data',a_data','chisq');
        A_mean = mean(K_data(:));
        K_combined = exp(-1/A_mean * K_data);
        data = [ (1:size(a_data,1))' , K_combined];
        
        labels = [zeros(size(pos_data_svm,1),1) ; ones(size(neg_data_svm,1),1)];
        
        % Train the SVM
        svm_model = libsvmtrain(labels,data,opts_svm);
        
        fprintf('*** Finished training SVM classifiers per action class. RUN: %d ******\n',rr);
        
        %svm_filename = sprintf('SVM_Workspace_Run%d_Sizes_%d_%d_LOOP.mat',rr,opts_auto.sizes(1),opts_auto.sizes(2));
        %save(svm_filename,'svm_model','opts_svm','A_mean','a_data');
        svm_workspace{rr}.svm_model = svm_model;
        svm_workspace{rr}.opts_svm = opts_svm;
        svm_workspace{rr}.A_mean = A_mean;
        svm_workspace{rr}.a_data = a_data;
        
        fprintf('\n\n ************************ END OF TRAINING : RUN %d *******************************\n\n',rr);
        time_to_train = toc(tid_train);
        fprintf('\nTime Take to train the networks = %f hours\n',time_to_train/3600);
        

    end
end

