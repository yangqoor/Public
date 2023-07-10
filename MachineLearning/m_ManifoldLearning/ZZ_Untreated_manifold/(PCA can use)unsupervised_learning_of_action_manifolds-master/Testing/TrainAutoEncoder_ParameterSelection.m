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

for sz = 4%5:1:9
    auto_sizes{sz}
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
    
    
    
    %% Pre-processing of the features. Temporal filtering for each sequence
    testIndex = [9    25    10    24    18    19     5     6];
    for rr = 1:1:num_of_runs
        % 2/3rd of training ; 1/3rd of testing
        % select random 1/3rd of the person
        %testIndex = randperm(num_of_persons, floor(1/3 * num_of_persons));
        tid_train = tic;
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
        parfor act_num = 1:num_of_actions
            sae{act_num} = stacked_autoencoder(Inputs_per_action{act_num},opts_auto_per_action{act_num},true);
            fprintf('\n\t********************TRAINING AUTO-ENCODER FOR ACTION %d COMPLETED RUN: %d ************************************\n',act_num,rr);
        end
        
        sae_filename = sprintf('SAE_Workspace_Run%d_AutoEncoder_Sizes_%d_%d.mat',rr,opts_auto.sizes(1),opts_auto.sizes(2));
        save(sae_filename,'sae','opts_auto','Features_train','Features_test','testIndex');
        
        %%%%%%%%%%%%%%%%%%%%% Computing Global clusters %%%%%%%%%%%%%%%%%
        clusters = cell(num_of_actions,1);
        parfor act_num = 1:num_of_actions
            
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
        
        clusters_filename = sprintf('Cluster_Workspace_Run%d_Sizes_%d_%d.mat',rr,opts_auto.sizes(1),opts_auto.sizes(2));
        save(clusters_filename,'clusters','global_C','global_C_indices');
        
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
        
        svm_filename = sprintf('SVM_Workspace_Run%d_Sizes_%d_%d.mat',rr,opts_auto.sizes(1),opts_auto.sizes(2));
        save(svm_filename,'svm_model','opts_svm','A_mean','a_data');
        
        fprintf('\n\n ************************ END OF TRAINING : RUN %d *******************************\n\n',rr);
        time_to_train = toc(tid_train);
        fprintf('\nTime Take to train the networks = %f hours\n',time_to_train/3600);
        
        %% TESTING PHASE 2: ACTION LABELS PER FRAME
        tid_test_phase2 = tic;
        [num_of_actions,num_of_seqs_test] = size(Features_test);
        
        % results structure
        results.action_labels_per_frame_confusionmatrix = zeros(num_of_actions,num_of_actions);
        
        % Iterating through each sub-sequence
        for seq_row = 1:1:num_of_actions
            for seq_num = 1:1:(num_of_seqs_test/(num_of_sets))
                
                % accumulate the frames of a single sequence belonging to one
                % set and one person : There are 16 subsequences
                test_seqs_all = Features_test(seq_row,(seq_num-1)*num_of_sets+1:seq_num*num_of_sets);
                test_seqs_all = test_seqs_all';
                test_seq = cell2mat(test_seqs_all);
                
                if(isempty(test_seq))
                    continue;
                end
                
                % check if sequence is empty
                if(isempty(test_seq))
                    continue;
                end
                
                % boolean array to indicate the presence of an action or
                % background
                num_test_frames = size(test_seq,1);
                
                %%%%%% Action Detection at each frame %%%%%%%%%%%%%
                % apply the SVM classifier
                a_data_test = test_seq;
                K_data_test = slmetric_pw(a_data_test',a_data','chisq');
                K_combined_test = exp(-1/A_mean * K_data_test);
                data_test = [ (1:size(a_data_test,1))' , K_combined_test];
                
                [predicted_label,accuracy,decision_values] = libsvmpredict(rand(size(a_data_test,1),1),data_test,svm_model,'-b 1 -q');
                
                action_detected = (~predicted_label);
                
                %%%%% Action Classification per frame %%%%%%%%%%%%
                % Find the corresponding cluster to each frame
                [ids,dis] = yael_nn(single(global_C'),single(test_seq'));
                
                % Replace each frame with the codeword. No removal of duplicate
                % codewords here
                X_test = zeros(num_test_frames,size(test_seq,2));
                for k = 1:1:num_test_frames
                    X_test(k,:) = global_C(ids(k),:);
                end
                
                % Computing the error between reconstructed codewords and
                % actual detected codewords from each auto-encoder
                dist_to_each_action = zeros(num_of_actions,num_test_frames);
                for act_num = 1:1:num_of_actions
                    
                    % get the corresponding auto-encoder
                    st = sae{act_num};
                    
                    % apply the auto-encoder
                    [X_test_out,a_X_test_out] = sae_nn_ff(st,X_test);
                    
                    % Try also chi-squared distance since its a histogram type
                    % measures
                    dist1 = slmetric_pw(X_test',X_test_out','chisq');
                    dist2 = diag(dist1); % only taking measures at the same frame instances
                    
                    % storing the distance for each frame
                    dist_to_each_action(act_num,:) = dist2';
                end
                
                % find the minimum distance for each frame
                [mi,id] = min(dist_to_each_action);
                true_class = seq_row;
                
                results.action_labels_per_frame_distancemeasures{seq_row,seq_num} = dist_to_each_action;
                results.action_labels_per_frame_probEstimates{seq_row,seq_num} = exp(-dist_to_each_action);
                
                for k = 1:1:num_test_frames
                    if(action_detected(k) == 1) % presense of action
                        est_class = id(k);
                        results.action_labels_per_frame_confusionmatrix(true_class,est_class) = results.action_labels_per_frame_confusionmatrix(true_class,est_class) + 1;
                    end
                end
                
            end
        end
        
        results_phase2 = results;
        results_phase2.action_labels_per_frame_confusionmatrix_percent = results_phase2.action_labels_per_frame_confusionmatrix./repmat(sum(results_phase2.action_labels_per_frame_confusionmatrix,2),1,num_of_actions);
        
        results_filename = sprintf('Results_Phase2_Run_Sizes_%d_%d.mat',opts_auto.sizes(1),opts_auto.sizes(2));
        save(results_filename,'results_phase2');
        
        fprintf('\n***************** PHASE 2 COMPLETED *****************\n');
        time_to_test_phase2 = toc(tid_test_phase2);
        fprintf('\nTime taken for phase 2 = %f hours\n',time_to_test_phase2/3600);
        
        clear results
        
        %% PHASE 1
        tid_test_phase1 = tic;
        try
            
            % Action classification confusion matrixes
            results.action_class_fullseq_confusionmatrix = zeros(num_of_actions,num_of_actions);
            results.action_class_winseq_confusionmatrix = cell(length(test_params.win_lengths),1);
            for w = 1:1:length(test_params.win_lengths)
                results.action_class_winseq_confusionmatrix{w} = zeros(num_of_actions,num_of_actions);
            end
            
            % Action classification distance measures represented as likelihood
            % functions. Graph representations
            % the cell array below accumulates distance measures for each sequence for
            % both hypothesis H0(belonging to action) and H1(not belonging to an
            % action). Each hypothesis measures are stored in a row array.
            results.action_class_distance_measures = cell(num_of_actions,1);
            
            % Iterating through each sequence in the test
            for seq_row = 1:1:num_of_actions
                acc_dist_for_each_action = [];
                for seq_num = 1:1:num_of_seqs_test
                    
                    % get the test sequence
                    test_seq = Features_test{seq_row,seq_num};
                    
                    % check if sequence is empty
                    if(isempty(test_seq))
                        continue;
                    end
                    
                    % Find the corresponding cluster to each frame
                    [ids,dis] = yael_nn(single(global_C'),single(test_seq'));
                    num_test_frames = size(test_seq,1);
                    
                    % Replace each frame with the codeword
                    X_test = zeros(num_test_frames,size(test_seq,2));
                    for k = 1:1:num_test_frames
                        X_test(k,:) = global_C(ids(k),:);
                    end
                    
                    % Remove consecutive duplicate codewords in the sequences
                    last_codeword_encoun = X_test(1,:);
                    dup_ids = zeros(num_test_frames,1);
                    for k = 2:1:num_test_frames
                        sum_dist = sum(sum((last_codeword_encoun - X_test(k,:)).^2));
                        if(sum_dist == 0) % duplicate : no change in last_codeword seen
                            dup_ids(k) = 1;
                        else % if no duplicate
                            last_codeword_encoun = X_test(k,:);
                        end
                    end
                    non_dup_ids = (~dup_ids);
                    rel_ids = find(non_dup_ids ~= 0);
                    
                    % Make the list of codewords found in the complete sequence
                    X_test = X_test(rel_ids,:);
                    num_codewords_detected = size(X_test,1);
                    
                    % Computing the error between reconstructed codewords and
                    % actual detected codewords from each auto-encoder
                    dist_to_each_action = zeros(num_of_actions,1);
                    for act_num = 1:1:num_of_actions
                        
                        % get the corresponding auto-encoder
                        st = sae{act_num};
                        
                        % apply the auto-encoder
                        [X_test_out,a_X_test_out] = sae_nn_ff(st,X_test);
                        
                        % Try also chi-squared distance since its a histogram type
                        % measures
                        dist1 = slmetric_pw(X_test',X_test_out','chisq');
                        dist2 = diag(dist1); % only taking measures at the same frame instances
                        
                        dist_to_each_action(act_num) = sum(dist2)/num_codewords_detected;
                        
                    end
                    
                    % Find the distance with the minimum measurement
                    [mi,class_id] = min(dist_to_each_action);
                    est_class = class_id;
                    true_class = seq_row;
                    
                    % updating the confusion matrix
                    results.action_class_fullseq_confusionmatrix(true_class,class_id) = results.action_class_fullseq_confusionmatrix(true_class,class_id) + 1;
                    
                    % results.action_class_distance_measures
                    acc_dist_for_each_action = [acc_dist_for_each_action dist_to_each_action];
                    
                end
                
                results.action_class_distance_measures{seq_row,1} = acc_dist_for_each_action;
            end
            
            results.action_class_fullseq_confusionmatrix_percent = results.action_class_fullseq_confusionmatrix./repmat(sum(results.action_class_fullseq_confusionmatrix,2),1,num_of_actions);
            results.action_class_fullseq_overallacc = sum(diag(results.action_class_fullseq_confusionmatrix))./sum(results.action_class_fullseq_confusionmatrix(:));
            
            %%%%%%%% Testing of Sequence using partial windows %%%%%%%%%%
            % Iterating through each sequence in the test
            % iterate through each window size
            for w = 1:1:length(test_params.win_lengths)
                win_length = test_params.win_lengths(w);
                win_skip = test_params.win_lengths(w);
                
                % Iterating through each sequence
                for seq_row = 1:1:num_of_actions
                    for seq_num = 1:1:num_of_seqs_test
                        % get the test sequence
                        test_seq = Features_test{seq_row,seq_num};
                        
                        % check if sequence is empty
                        if(isempty(test_seq))
                            continue;
                        end
                        num_test_frames = size(test_seq,1);
                        
                        for kl = win_length:win_skip:num_test_frames
                            % get a windowed sequence
                            test_seq_loc = test_seq(kl-win_length+1:1:kl,:);
                            
                            % Find the corresponding cluster to each frame
                            [ids,dis] = yael_nn(single(global_C'),single(test_seq_loc'));
                            
                            % Replace each frame with the codeword
                            X_test = zeros(win_length,size(test_seq_loc,2));
                            for k = 1:1:win_length
                                X_test(k,:) = global_C(ids(k),:);
                            end
                            
                            % Remove consecutive duplicate codewords in the sequences
                            last_codeword_encoun = X_test(1,:);
                            dup_ids = zeros(win_length,1);
                            for k = 2:1:win_length
                                sum_dist = sum(sum((last_codeword_encoun - X_test(k,:)).^2));
                                if(sum_dist == 0) % duplicate : no change in last_codeword seen
                                    dup_ids(k) = 1;
                                else % if no duplicate
                                    last_codeword_encoun = X_test(k,:);
                                end
                            end
                            non_dup_ids = (~dup_ids);
                            rel_ids = find(non_dup_ids ~= 0);
                            
                            % Make the list of codewords found in the complete sequence
                            X_test = X_test(rel_ids,:);
                            num_codewords_detected = size(X_test,1);
                            
                            dist_to_each_action = zeros(num_of_actions,1);
                            for act_num = 1:1:num_of_actions
                                
                                % get the corresponding auto-encoder
                                st = sae{act_num};
                                
                                % apply the auto-encoder
                                [X_test_out,a_X_test_out] = sae_nn_ff(st,X_test);
                                
                                % Try also chi-squared distance since its a histogram type
                                % measures
                                dist1 = slmetric_pw(X_test',X_test_out','chisq');
                                dist2 = diag(dist1); % only taking measures at the same frame instances
                                
                                dist_to_each_action(act_num) = sum(dist2)/num_codewords_detected;
                                
                            end
                            
                            % Find the distance with the minimum measurement
                            [mi,class_id] = min(dist_to_each_action);
                            est_class = class_id;
                            true_class = seq_row;
                            
                            % updating the confusion matrix
                            results.action_class_winseq_confusionmatrix{w}(true_class,class_id) = results.action_class_winseq_confusionmatrix{w}(true_class,class_id) + 1;
                            
                        end
                        
                        % end of seq_num
                    end
                end
                
                fprintf('\n Testing done for window length and overlap : (%d,%d)\n',test_params.win_lengths(w),test_params.win_overlap(w));
                
                results.action_class_winseq_confusionmatrix_percent{w} = results.action_class_winseq_confusionmatrix{w}./repmat(sum(results.action_class_winseq_confusionmatrix{w},2),1,num_of_actions);
                results.action_class_winseq_overallacc{w} = sum(diag(results.action_class_winseq_confusionmatrix{w}))./sum(results.action_class_winseq_confusionmatrix{w}(:));
                
                % end of win_length loop : selection of different temporal
                % windows
            end
            
            %%%%%%%%%%%% End of action classification for windowed seqs %%%%%%%%
            
            % save results of phase 1
            results_filename = sprintf('Results_Phase1_Run_Sizes_%d_%d.mat',opts_auto.sizes(1),opts_auto.sizes(2));
            results_phase1 = results;
            save(results_filename,'results_phase1');
            
        catch exception
            disp(exception)
        end
        
        fprintf('\n***************** PHASE 1 COMPLETED *****************\n');
        time_to_test_phase1 = toc(tid_test_phase1);
        fprintf('\nTime taken for phase 1 = %f hours\n',time_to_test_phase1/3600);

        clear results
    
        
    end
end

