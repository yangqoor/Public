% Training File
% Here, 2/3rd of the Features are used for training an auto-encoder and a
% CRBM. The trained auto-encoder and CRBM are saved for different
% combinations of the training and testing features.
clear all; clc;
addpath('/home/prci/Dropbox/ActionLocalization/Algorithm/FeatureExtraction');
load ForegroundFeatures;
load Background_Features;

% Parameters of training
num_of_runs = 2;
[num_of_actions,num_of_seqs] = size(Features);
num_of_sets = 4;
num_of_persons = 25;
max_num_of_subseqs = 4;
num_manifold_steps = 2000;
fun_s = @(x) size(x,1);

% Parameters for auto-encoder
opts_auto.epsilon_w = 0.1;
opts_auto.epsilon_vb = 0.1;
opts_auto.epsilon_vc = 0.1;
opts_auto.momentum = 0.9;
opts_auto.weightcost = 0.0002;
opts_auto.numepochs = 50;
opts_auto.sizes = [100 30]; % the second layer as same as the original layer

% Parameters for SVM Training
C_val = 10; 
opts_svm = sprintf('-s 0 -t 4 -c %d -b 1 -q',C_val);

% Parameters for CRBM Training
opts_crbm.n{1} = 5;
opts_crbm.n{2} = 5;
opts_crbm.sizes = [200 200]; % originally 150
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
opts_crbm.num_epochs = 500; % 2000 iterations not required as error is same at 500 iterations
opts_crbm.numGibbs = 200;
opts_crbm.dropRate = 1;

training_params_filename = sprintf('Training_Params.mat');
save(training_params_filename,'num_manifold_steps','max_num_of_subseqs','num_of_persons','num_of_sets');

%% Pre-processing of the features. Temporal filtering for each sequence

for rr = 1:1:num_of_runs
     % 2/3rd of training ; 1/3rd of testing
     % select random 1/3rd of the person
     testIndex = randperm(num_of_persons, floor(1/3 * num_of_persons));
     [Features_train,Features_test,params]  = getFeaturesTrain(Features,testIndex);
   
     % getting the background of the training sequences
     Features_train_bg  = getFeaturesTrain_bg(Features_bg(4:6,:),testIndex,params);
     TrainingData_bg = Features_train_bg(:);
     
     Features_test_bg  = getFeaturesTest_bg(Features_bg(4:6,:),testIndex,params);
     TestingData_bg = Features_test_bg(:);  
     [num_of_actions,num_of_seqs_train] = size(Features_train);
     [~,num_of_seqs_test] = size(Features_test);
    
    %%%%%%%%%%%%%%%% AUTO-ENCODER TRAINING %%%%%%%%%%%%%%%%%%%%%%%%%%%% 
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

%             % perform median filtering
%             TrainingData{ce} = performTemporalFiltering(TrainingData{ce},5);
%             Size(ce) = size(TrainingData{ce},1);

            % Flip the matrix to convert to cell
            TrainingData{ce} = TrainingData{ce}';
        end
        Inputs = cell2mat(TrainingData);
        Inputs = Inputs';

        opts_auto.seq_size = Size;
        sae{act_num} = stacked_autoencoder(Inputs,opts_auto,true);
        %[pc,net] = nlpca(Inputs,3); // Command takes super long time!!!

        fprintf('\n\t********************TRAINING AUTO-ENCODER FOR ACTION %d COMPLETED RUN: %d ************************************\n',act_num,rr); 
    end
    
    sae_filename = sprintf('SAE_Workspace_Run%d.mat',rr);
    save(sae_filename,'sae','opts_auto','Features_train','Features_test','testIndex');
    
    %%%%%%%%%%%%%%%%%%%%% Computing Global clusters %%%%%%%%%%%%%%%%%
    clusters = cell(num_of_actions,1);
    for act_num = 1:1:num_of_actions
        
        % get the stacked auto-encoder
        st = sae{act_num};
            
        TrainingData = Features_train(act_num,:);
        Size = cellfun(fun_s,TrainingData);

        % flip the matrices in each cell
        for ce = 1:1:length(TrainingData)
            if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
                TrainingData{ce} = [];
            end
            TrainingData{ce} = TrainingData{ce}';
        end
        Inputs = cell2mat(TrainingData);
        Inputs = Inputs';
    
        % compute the outputs from the auto-encoder of class 'act_num'
        [Inputs_out,a_inputs_out] = sae_nn_ff(st,Inputs);
        
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
    
    clusters_filename = sprintf('Cluster_Workspace_Run%d.mat',rr);
    save(clusters_filename,'clusters','global_C','global_C_indices');
    
    fprintf('\n*** Finished computing global clusters per action class. RUN: %d ******\n',rr);
    
    %%%%%%%%%%%%%%%%%%%%%% CRBM TRAINING %%%%%%%%%%%%%%%%%%%%%%%%%%

    % cell array holding structures for the trained crbm model
    crbm = cell(num_of_actions,1);
    
    % Training for each action class
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
        
        opts_crbm.seq_lengths = Size;
    
        % training to model transitions from codeword to the next
        crbm_local = trainCRBM(a_crbm_train_inputs,opts_crbm);
        crbm{act_num} = crbm_local;
        
        fprintf('\n\n************************** COMPLETED CRBM TRAINING FOR ACTION CLASS %d. RUN: %d **********************************\n\n',act_num,rr); 
        
    end
    
    crbm_filename = sprintf('CRBM_Workspace_Run%d.mat',rr);
    save(crbm_filename,'crbm','opts_crbm');
    
    %%%%%%%%%%%%%%%%%%%% Training SVM Classifier per action %%%%%%%%%
    neg_data_svm = cell2mat(TrainingData_bg);
    neg_data_idx = randperm(size(neg_data_svm,1),num_manifold_steps*6);
    neg_data_svm = neg_data_svm(neg_data_idx,:);
    
    % Selecting only a few training points
    [C,I] = yael_kmeans(single(neg_data_svm'),num_manifold_steps*2,'init',0,'redo',10,'niter',100);
    neg_data_svm = double(C');
    
    neg_data_svm_test = cell2mat(TestingData_bg);
%     for act_num = 1:1:num_of_actions
%         
%         % get the stacked autoencoder
%         st = sae{act_num};
%         
%         a_pos_data = clusters{act_num};
%         
%         % Applying the stacked auto-encoder transformation
%         [neg_data_out,a_neg_data] = sae_nn_ff(st,neg_data_svm);
%         
%         % Perform clustering to get suitable approximation of manifold
%         [C,I] = yael_kmeans(single(a_neg_data'),num_manifold_steps*2,'init',0,'redo',10,'niter',100);
%         a_neg_data = double(C');
%         
%         % Arranging the data
%         a_data = [a_pos_data ; a_neg_data];
%         
% %         K_data = slmetric_pw(a_data',a_data','chisq');
% %         A_data = mean(K_data(:));
% %         K_combined = exp(-1/A_data * K_data);
% %         data = [ (1:size(a_data,1))' , K_combined];
%         
%         data = a_data;
%         labels = [zeros(size(a_pos_data,1),1) ; ones(size(a_neg_data,1),1)];
%         % Training the SVM
%         svm_model{act_num} = libsvmtrain(labels,data,opts_svm);
%         
%         % Test the SVM classifier foe verification
%         [neg_data_out_test,a_neg_data_test] = sae_nn_ff(st,neg_data_svm_test);
%         pos_data_svm_test = cell2mat(Features_test(act_num,:)');
%         [pos_data_out_test,a_pos_data_test] = sae_nn_ff(st,pos_data_svm_test);
%         
%         a_data_test = [a_pos_data_test ; a_neg_data_test];
%         
% %         K_data_test = slmetric_pw(a_data_test',a_data','chisq');
% %         K_combined_test = exp(-1/A_data * K_data_test);
% %         data_test = [ (1:size(a_data_test,1))' , K_combined_test];
%         
%         data_test = a_data_test;
%         labels_test = [zeros(size(a_pos_data_test,1),1) ; ones(size(a_neg_data_test,1),1)];
%         
%         [predicted_label,accuracy,decision_values] = libsvmpredict(labels_test,data_test,svm_model{act_num},'-b 1');
%     end
    
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
    
%     % Test the SVM
%     a_data_test = [pos_data_svm_test ; neg_data_svm_test];
%     K_data_test = slmetric_pw(a_data_test',a_data','chisq');
%     K_combined_test = exp(-1/A_data * K_data_test);
%     data_test = [ (1:size(a_data_test,1))' , K_combined_test];
%     
%     labels_test = [zeros(size(pos_data_svm_test,1),1) ; ones(size(neg_data_svm_test,1),1)];
%     
%     [predicted_label,accuracy,decision_values] = libsvmpredict(labels_test,data_test,svm_model,'-b 1');
    
    
    fprintf('*** Finished training SVM classifiers per action class. RUN: %d ******\n',rr);
    
    svm_filename = sprintf('SVM_Workspace_Run%d.mat',rr);
    save(svm_filename,'svm_model','opts_svm','A_mean','a_data');
    
    fprintf('\n\n ************************ END OF TRAINING : RUN %d *******************************\n\n',rr);
    
end