%% Script for evaluating using the trained CRBM and Auto-encoder models.
addpath(genpath('/home/prci/Dropbox/ActionLocalization/Algorithm/'))
% Written and copyrighted by Binu M Nair
% Date : 01/11/2015

% This script tests for action classification accuracy applied to full
% sequences and temporal action localization accuracy applied to partial
% sequences of 30 frames. 

%%%%% Loading trained models for action %%%%%%%
% In future, each of the action models with be a structure holding the
% trainined auto-encoder, the trained CRBM model, the clusters
% corresponding to each action and the global set of codewords
% algo.actionModel{1},... algo.global_C,....etc...
% the resuls are stored in another structure. such as results.Test,
% results.actionDetectionOverlap... etc..

%%%%%%%%%%% Action classification accuracy : full sequence %%%%%%%%%%%
% For action classification, the entire sequence is reconstructed using
% auto-encoder alone and results are obtained.x

%%%%%%%%%%% Action labels per frame ( Action Detection) %%%%%%%%%%%%
% Per-frame action label accuracy can be obtained from the output of the
% stacked auto-encoder for the continous streaming sequence. This accuracy
% is similar to action detection but with a classification label with a
% background label as well. This can also be extended to use the CRBM model
% as well so that the generated next frame is used in the reconstruction to
% determine the action label of a frame of a sequence.

%%%%%%%%%%% Action Segment detection (Action localization) %%%%%%%%%%%%
% Here, a L-frame segment is classified as an action or non-action using
% the trained auto-encoder and CRBM models. Two variants are computed for
% this test. 
%%% Variant 1
% One is a full sequence action classification accuracy where
% for every segment of L frames with a shift of 2*nt frames, the stats are
% accumulated for the whole sequence. This is action classification. 
%%% Variant 2
% The
% second variant is classifying the L-frame segment seperately and compute
% the action localization statistic : action segment overlap measure with
% ground truth. Moreover, an accumulated action classification stat can be
% computed by considering these segments as independent. 
%%% Action Detection
% However, for action detection (action against background), the auto-encoder
% output should be sufficient. For now, a threshold can be set in the
% auto-encoder reconstruction error where if error is large, then no action
% detected. This however should be tested on the complete sequence where a
% person dissappears for a while and comes back ( eg: actions such as
% walking , running and jogging). Other actions such as boxing, hand
% clapping and hand waving can be tested from another dataset).

%%%%%%%%%%% Features for training and testing %%%%%%%%%%%%%%%%
% The features for training and testing are stored in 'Features_train' and
% 'Features_test'. For now, 'Features_test' contain only the sub-sequences
% where a person is present. This is suitable for finding the action labels
% per frame.

% loading the stacked auto-encoder workspace and the CRBM .
% In future, just load one workspace which holds a structure to all of the
% required variables.

%load SAE_Workspace
%load CRBM_Trained_Layers

%%
%%%%%%%%%%%%%%%%%%%%% ACTION LABELS PER FRAME %%%%%%%%%%%%%%%%%%%%%

%% Test 1 : Action labels per frame : Setting up the structures
[num_of_actions,num_of_test_seqs] = size(Features_test);

% cell array to hold stats corresponding to results from a single sequence
% such as action labels/per frame, action segment detection etc..
% the zeroth label is the background label
results.seq_stats = cell(num_of_actions,num_of_test_seqs);
results.action_labels_per_frame_acc_auto = zeros(num_of_actions,1);
results.action_labels_per_frame_acc_auto_localwin = zeros(num_of_actions,1);
results.action_labels_per_frame_acc_auto_crbm = zeros(num_of_actions,1);
results.total_frames_per_action = zeros(num_of_actions,1);
results.total_frames_per_action_non_dup = zeros(num_of_actions,1);

for act_num = 1:1:num_of_actions
    results.total_frames_per_action(act_num) = 0;
    for seq_num = 1:1:num_of_test_seqs
        num_frames = size(Features_test{act_num,seq_num},1);
        results.total_frames_per_action(act_num) = results.total_frames_per_action(act_num) + num_frames;
        
        % Three different variants for action labels/frame
        results.seq_stats{act_num,seq_num}.action_labels_per_frame_auto = zeros(1,num_frames);
        results.seq_stats{act_num,seq_num}.action_labels_per_frame_auto_localwin = zeros(1,num_frames); % using a local window of say (2*nt+1) frames with a shift of a single frame
        results.seq_stats{act_num,seq_num}.action_labels_per_frame_auto_crbm = zeros(1,num_frames); % using a window of (2*nt) frames to generate the next frame
        results.seq_stats{act_num,seq_num}.action_labels_per_frame_gd = act_num*ones(1,num_frames); 
    end
end

%% Test 1 : Action labels per frame using auto-encoder reconstruction ( single frame at a time)
% for seq_row = 1:1:num_of_actions
%     for seq_num = 1:1:num_of_test_seqs
%         
%         test_seq = Features_test{seq_row,seq_num};
%         
%         % Find the corresponding cluster to each frame
%         [ids,dis] = yael_nn(single(global_C'),single(test_seq'));
%         num_test_frames = size(test_seq,1);
%         
%         % Replace each frame with the codeword
%         X_test = zeros(num_test_frames,size(test_seq,2));
%         for k = 1:1:num_test_frames
%             X_test(k,:) = global_C(ids(k),:);
%         end
%         
%         % Remove consecutive duplicate codewords in the sequences
%         last_codeword_encoun = X_test(1,:);
%         dup_ids = zeros(num_test_frames,1);
%         for k = 2:1:num_test_frames
%             sum_dist = sum(sum((last_codeword_encoun - X_test(k,:)).^2));
%             if(sum_dist == 0) % duplicate : no change in last_codeword seen
%                 dup_ids(k) = 1;
%             else % if no duplicate
%                 last_codeword_encoun = X_test(k,:);
%             end
%         end
%         non_dup_ids = (~dup_ids);
%         rel_ids = find(non_dup_ids ~= 0);
%         
%         X_test_short = X_test(rel_ids,:);
%         num_frames_gen = size(X_test_short,1);
%         
%         dist_to_each_action_per_frame_auto = zeros(num_of_actions,num_test_frames);
%         for act_num = 1:1:num_of_actions
%             % get the corresponding auto-encoder
%             st = sae{act_num};
%             
%             % apply the auto-encoder
%             [X_test_out,a_X_test_out] = sae_nn_ff(st,X_test);
%             
%             dist_to_each_action_per_frame_auto(act_num,:) = sum(((X_test_out-X_test).^2),2)';
%         end
%         
%         % minimum of each frame
%         [C, results.seq_stats{seq_row,seq_num}.action_labels_per_frame_auto] = min(dist_to_each_action_per_frame_auto);
%         
%         % find indices with the correct frame labelling
%         ind = find(results.seq_stats{seq_row,seq_num}.action_labels_per_frame_auto == results.seq_stats{seq_row,seq_num}.action_labels_per_frame_gd);
%         
%         num_frames_corr = length(ind);
%         results.action_labels_per_frame_acc_auto(seq_row) = results.action_labels_per_frame_acc_auto(seq_row) + num_frames_corr;
%     end
% end
% % generating the result
% results.action_labels_per_frame_acc_auto = results.action_labels_per_frame_acc_auto * 100./results.total_frames_per_action;

%% Test 1 : Action labels per frame using auto-encoder reconstruction ( 2*nt+1 frames at a time)
% Done after removal of duplicates
% results.total_frames_per_action = zeros(num_of_actions,1);
% for seq_row = 1:1:num_of_actions
%     for seq_num = 1:1:num_of_test_seqs
%         
%         test_seq = Features_test{seq_row,seq_num};
%         
%         % Find the corresponding cluster to each frame
%         [ids,dis] = yael_nn(single(global_C'),single(test_seq'));
%         num_test_frames = size(test_seq,1);
%         
%         % Replace each frame with the codeword
%         X_test = zeros(num_test_frames,size(test_seq,2));
%         for k = 1:1:num_test_frames
%             X_test(k,:) = global_C(ids(k),:);
%         end
%         
%         % Remove consecutive duplicate codewords in the sequences
%         last_codeword_encoun = X_test(1,:);
%         dup_ids = zeros(num_test_frames,1);
%         for k = 2:1:num_test_frames
%             sum_dist = sum(sum((last_codeword_encoun - X_test(k,:)).^2));
%             if(sum_dist == 0) % duplicate : no change in last_codeword seen
%                 dup_ids(k) = 1;
%             else % if no duplicate
%                 last_codeword_encoun = X_test(k,:);
%             end
%         end
%         non_dup_ids = (~dup_ids);
%         rel_ids = find(non_dup_ids ~= 0);
%         
%         X_test = X_test(rel_ids,:);
%         num_frames_gen = size(X_test,1);
%         
%         results.total_frames_per_action(seq_row) = results.total_frames_per_action(seq_row) + num_frames_gen-2*nt;
%         
%         dist_to_each_action_per_frame_auto = zeros(num_of_actions,num_frames_gen);
%         for act_num = 1:1:num_of_actions
%             % get the corresponding auto-encoder
%             st = sae{act_num};
%             
%             % for each frame starting from 2*nt+1 till end
%             nt = opts_crbm.nt;
%             for k = 2*nt+1:1:num_frames_gen
%                 X_test_loc = X_test(k-2*nt:1:k,:);
%                 [X_test_loc_out, a_X_test_loc_out] = sae_nn_ff(st,X_test_loc);
%                 dist_to_each_action_per_frame_auto(act_num,k) = sum(sum(((X_test_loc - X_test_loc_out).^2),2));
%             end
%         end
%         
%         % minimum of each frame
%         [C, results.seq_stats{seq_row,seq_num}.action_labels_per_frame_auto_localwin] = min(dist_to_each_action_per_frame_auto(:,2*nt+1:end));
%         results.seq_stats{seq_row,seq_num}.action_labels_per_frame_gd = seq_row * ones(1,num_frames_gen);
%         
%         % find indices with the correct frame labelling
%         ind = find(results.seq_stats{seq_row,seq_num}.action_labels_per_frame_auto_localwin == results.seq_stats{seq_row,seq_num}.action_labels_per_frame_gd(1,2*nt+1:end));
%         
%         num_frames_corr = length(ind);
%         results.action_labels_per_frame_acc_auto_localwin(seq_row) = results.action_labels_per_frame_acc_auto_localwin(seq_row) + num_frames_corr;
%     end
% end
% % generating the result
% results.action_labels_per_frame_acc_auto_localwin = results.action_labels_per_frame_acc_auto_localwin * 100./results.total_frames_per_action;

%% Test 1 : Action labels per frame using auto-encoder and crbm reconstruction ( 2*nt+1 frames at a time)
% Done after removal of duplicates
results.total_frames_per_action = zeros(num_of_actions,1);
for seq_row = 1:1:num_of_actions
    for seq_num = 1:1:num_of_test_seqs
        
        test_seq = Features_test{seq_row,seq_num};
        
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
        
        X_test = X_test(rel_ids,:);
        num_frames_gen = size(X_test,1);
        
        dist_to_each_action_per_frame_auto = zeros(num_of_actions,num_frames_gen);
        nt = opts_crbm.nt;
        win_length = 4*nt;
        win_skip = nt;
        
        for act_num = 1:1:num_of_actions
            % get the corresponding auto-encoder
            st = sae{act_num};
            crbm_local = crbm{act_num};
            
            % for each frame starting from 2*nt+1 till end
            for k = win_length:win_skip:num_frames_gen
                X_test_loc = X_test(k-win_length+1:1:k,:);
                [X_test_loc_out, a_X_test_loc_out] = sae_nn_ff(st,X_test_loc);
                
                % Normalizing the data to pass it to CRBM
                a_X_test_loc_out_norm = (a_X_test_loc_out - repmat(crbm_local.data_mean,win_length,1))./(repmat(crbm_local.data_std,win_length,1));
                
                crbm_local.numGibbs = 1000;
                
                % computing the generated seqeucence within a shift of nt
                % frames
                dist_for_each_frame = zeros(1,nt);
                for start_fr_num = 1:1:nt
                    short_win = 3*nt;
                    [a_X_test_loc_out_rec_norm,hidden1,hidden2] = testCRBM(crbm_local,short_win,a_X_test_loc_out_norm,start_fr_num);

                    % get the unnormalized version from the regenerated sequence
                    a_X_test_loc_out_rec = (a_X_test_loc_out_rec_norm .* repmat(crbm_local.data_std,short_win,1)) + repmat(crbm_local.data_mean,short_win,1);

                    % apply the decoder
                    X_test_loc_out_rec = sae_ff_nn_decoder(st,a_X_test_loc_out_rec);
                    
                    dist_for_each_frame(start_fr_num) = sum(sum((X_test_loc(start_fr_num:1:short_win + start_fr_num-1,:) - X_test_loc_out_rec).^2));
                
                end
               
                % distance to each action is computed for every 5th frame
                %dist_to_each_action_per_frame_auto(act_num,k) = sum(sum((X_test_loc(2*nt+1:win_length,:) - X_test_loc_out_rec(2*nt+1:win_length,:)).^2));
                dist_to_each_action_per_frame_auto(act_num,k) = sum(dist_for_each_frame)/nt;
            end
        end
        
        % minimum of each frame
        [C, results.seq_stats{seq_row,seq_num}.action_labels_per_frame_auto_crbm] = min(dist_to_each_action_per_frame_auto(:,win_length:win_skip:num_frames_gen));
        results.seq_stats{seq_row,seq_num}.action_labels_per_frame_gd = seq_row * ones(1,num_frames_gen);
        
        % find indices with the correct frame labelling
        ind = find(results.seq_stats{seq_row,seq_num}.action_labels_per_frame_auto_crbm == results.seq_stats{seq_row,seq_num}.action_labels_per_frame_gd(1,win_length:win_skip:num_frames_gen));
        
        num_frames_corr = length(ind);
        results.action_labels_per_frame_acc_auto_crbm(seq_row) = results.action_labels_per_frame_acc_auto_crbm(seq_row) + num_frames_corr;
        
        results.total_frames_per_action(seq_row) = results.total_frames_per_action(seq_row) + length(win_length:win_skip:num_frames_gen);
    end
end
% generating the result
results.action_labels_per_frame_acc_auto_crbm = results.action_labels_per_frame_acc_auto_crbm * 100./results.total_frames_per_action;
