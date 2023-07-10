%% Script for Testing Phase 2/Experiment 2 : Action Labels per frame
% Written and copyrighted by Binu M Nair
% Date : 01/17/2015

% This script generates results and illustrations for experiment 2 ( phase
% 2) which is computing action labels per frame with detection of
% background frame using an SVM. Since it is per-frame labels, we use both
% auto-encoders for classifying an action and an SVM for labelling the
% frame as background or foreground. So, first the frame is classified as
% fg/bg and then if fg, labeled as a specific class. No temporal
% information is used in labelling the frames as an action class or
% background but the key point is that classification and action detection
% can be done simultaeneosly on a per-frame basis.

% If a window of 10 frames are used in determining the label of the last
% frame in the window, it is nothing but action classification using
% overlap as 9 frames. So, per-frame action label provides an experimental
% result on how much localization is obtained from the system. 

% Here, the testing scenario will take a complete test sequence (provided
% by the 'testIndex' variable. This sequence is not divided into
% sub-sequences and so, features are recomputed from the optical flow. The
% structure of the code will be similar to 'ExtractFeaturesFromForeground'
% with the exception that the test sequence are being used. Each frame is
% then fed to the SVM and auto-encoder for computation.

% A single arbitrary test sequence can be used to display the action labels
% at each frame (black label as background) for illustration purposes.

%%%%%%%%%%% Action labels per frame ( Action Detection) %%%%%%%%%%%%
% Per-frame action label accuracy can be obtained from the output of the
% stacked auto-encoder for the continous streaming sequence. This accuracy
% is similar to action detection but with a classification label with a
% background label as well. This can also be extended to use the CRBM model
% as well so that the generated next frame is used in the reconstruction to
% determine the action label of a frame of a sequence.

%%%%%%%%%%% Features for training and testing %%%%%%%%%%%%%%%%
% The features for training and testing are stored in 'Features_train' and
% 'Features_test'. For now, 'Features_test' contain only the sub-sequences
% where a person is present. This is suitable for finding the action labels
% per frame.

addpath(genpath('/home/prci/Dropbox/ActionLocalization/Algorithm/'));

%%%%%%%%%%%%%%%%%% END OF FEATURE EXTRACTION PARAMS %%%%%%%%%%%%%%%%%

% load training file params 
training_params_filename = sprintf('Training_Params_UCF.mat');
load(training_params_filename);

% load features
load ForegroundFeatures_UCF
%load Background_Features

% iterating through each run
for rr = 1:2
    
    % Action labels/frame : same as action classification but only a single
    % frame
    
    % load the test index and the stacked auto-encoders
    sae_filename = sprintf('SAE_Workspace_Run%d_UCF.mat',rr);
    load(sae_filename);
    
    % Load the clusters for this run
    clusters_filename = sprintf('Cluster_Workspace_Run%d_UCF.mat',rr);
    load(clusters_filename);
    
%     % Load the SVM Classifiers
%     svm_filename = sprintf('SVM_Workspace_Run%d.mat',rr);
%     load(svm_filename);
    
%     % Get the test features from annotated sequences and background
%     [~, Features_test,params] = getFeaturesTrain(Features,testIndex);
%     Features_test_bg  = getFeaturesTest_bg(Features_bg(4:6,:),testIndex,params);
     
    [num_of_actions,num_of_test_seqs] = size(Features_test);
    
    % results structure
    results.action_labels_per_frame_confusionmatrix = zeros(num_of_actions,num_of_actions);
    
    % Iterating through each sub-sequence
    for seq_row = 1:1:num_of_actions
        for seq_num = 1:1:num_of_test_seqs
            
            % accumulate the frames of a single sequence belonging to one
            % set and one person : There are 16 subsequences
            test_seq = Features_test{seq_row,seq_num};
       
            if(isempty(test_seq))
                continue;
            end
            
            % boolean array to indicate the presence of an action or
            % background
            num_test_frames = size(test_seq,1);
                    
%             %%%%%% Action Detection at each frame %%%%%%%%%%%%%
%             % apply the SVM classifier
%             a_data_test = test_seq;
%             K_data_test = slmetric_pw(a_data_test',a_data','chisq');
%             K_combined_test = exp(-1/A_mean * K_data_test);
%             data_test = [ (1:size(a_data_test,1))' , K_combined_test];
%             
%             [predicted_label,accuracy,decision_values] = libsvmpredict(rand(size(a_data_test,1),1),data_test,svm_model,'-b 1 -q');
%             
%             action_detected = (~predicted_label);
            action_detected = ones(num_test_frames,1);
            
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
            
            for k = 1:1:num_test_frames
                if(action_detected(k) == 1) % presense of action
                    est_class = id(k);
                    results.action_labels_per_frame_confusionmatrix(true_class,est_class) = results.action_labels_per_frame_confusionmatrix(true_class,est_class) + 1;
                end
            end
            
        end
    end

    results.action_labels_per_frame_confusionmatrix_percent = results.action_labels_per_frame_confusionmatrix./repmat(sum(results.action_labels_per_frame_confusionmatrix,2),1,num_of_actions);
    
    results_phase2 = results;
    results_filename = sprintf('Results_Phase2_Action_Classification_Run-%d_UCF.mat',rr);
    save(results_filename,'results_phase2');
    
end