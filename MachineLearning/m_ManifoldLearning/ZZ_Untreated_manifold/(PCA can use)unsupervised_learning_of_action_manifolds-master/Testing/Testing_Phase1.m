%% Script for Testing Phase 1/Experiment 1 : Action Classification
addpath(genpath('/home/prci/Dropbox/ActionLocalization/Algorithm/'))
% Written and copyrighted by Binu M Nair
% Date : 01/15/2015

%%%%%%%%%%% Action classification accuracy : full sequence/ Partial Sequence %%%%%%%%%%%
% This script tests for action classification accuracy applied to full
% sequences and partial sequences of length 10, 15, 20, 25, 30 with overlap
% of 5, 10, 15, 20 frames. For action classification, the entire sequence is reconstructed using
% auto-encoder alone and results are obtained. Within a window of L frames,
% the frames are replaced by their global codewords. Duplicate codewords in
% the window are removed. These set of codewords are fed to each
% auto-encoder and reconstructed back. The model which gives the least
% error is the action class

%%%%%%%%%%% Features for training and testing %%%%%%%%%%%%%%%%
% The features for training and testing are stored in 'Features_train' and
% 'Features_test'. For now, 'Features_test' contain sub-sequences of
% individuals in the testing set. Each run has a different combination of
% testing.

%%%%%%%% RESULTS %%%%%%%%%%%%%%%%%%%%
% The results are stored in a structure which gives action classification
% confusion matrix for the full sequence as well as for the different sets
% of window sequences

%%%%%%%% ACTION CLASSIFICATION ( TRADITIONAL ) %%%%%%%%%%%%%%%%%%

clear all; clc;

% load training file params 
training_params_filename = sprintf('Training_Params.mat');
load(training_params_filename);

% load the background and foreground features
load ForegroundFeatures
load Background_Features

[num_of_actions,num_of_total_seqs] = size(Features);

% Setting params for testing strategy
test_params.win_lengths = [10,15,20,25,30];
test_params.win_overlap = [5,10,15,20,25];


% load the features 
for rr = 1:2
    
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
    
    % Loading the corresponding stacked_autoencoder ( obtains auto training
    % parameters, test indices used in the training run
    sae_filename = sprintf('SAE_Workspace_Run%d.mat',rr);
    load(sae_filename);
    
    % Get the test features for action classification
    [~,Features_test,params] = getFeaturesTrain(Features,testIndex);
    [num_of_actions,num_of_test_seqs] = size(Features_test);
    
    % Load the clusters for this run
    clusters_filename = sprintf('Cluster_Workspace_Run%d.mat',rr);
    load(clusters_filename);
    
    %%%%%%%%%%%%%%%%%% Testing of Full Sequence %%%%%%%%%%%%%%%%%%
    % Iterating through each sequence in the test
    for seq_row = 1:1:num_of_actions
        acc_dist_for_each_action = [];
        for seq_num = 1:1:num_of_test_seqs
            
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
            for seq_num = 1:1:num_of_test_seqs
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
    results_filename = sprintf('Results_Phase1_Action_Classification_Run-%d.mat',rr);
    results_phase1 = results;
    save(results_filename,'results_phase1');
    
end



