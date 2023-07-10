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

%%%%%%%%%%%%% FEATURE EXTRACTION PARAMS %%%%%%%%%%%%%%%%%%
set_of_classes = {'boxing','handclapping','handwaving','jogging','running','walking'};
num_of_actions = length(set_of_classes);
num_of_sets = 4;
num_of_persons = 25;
max_num_of_subseqs = 4;
seq_divs = cell(num_of_actions,num_of_sets * num_of_persons);
boundingboxes = cell(num_of_actions,num_of_sets*num_of_persons);
start_end_frames = cell(num_of_actions,num_of_sets*num_of_persons);
nums_cell = {};
st_end_frame = {};
b_inc = 10; % percent increase in bounding box

%% Divison of sequences into associated subsequences
subseq_attribute_path  = '/home/prci/Datasets/KTH/00sequences_copy.txt';
fileID = fopen(subseq_attribute_path);
comma = ',';
dash = '-';

for p = 1:1:num_of_persons
    for act_num = 1:1:num_of_actions
        action_name = set_of_classes{act_num};
        for set = 1:1:num_of_sets
                tline_header = fgetl(fileID);
                [tline_1 frame_count_subseq] = sscanf(tline_header,'%c');
                nums = sscanf(tline_1,'%*s%*s %d-%d, %d-%d, %d-%d, %d-%d');
                nums = reshape(nums,2,length(nums)/2);
                seq_divs{act_num,(p - 1) * num_of_sets + set} = nums;
        end
    end
end

tline = fgets(fileID);
fclose(fileID);

%% Extraction of Bounding Box for each subsequence
bounding_box_info_file = '/home/prci/Datasets/KTH/KTHBoundingBoxInfo.txt';
fileID = fopen(bounding_box_info_file);
% Get the first three line which gives the information
str1 = fgetl(fileID);
str2 = fgetl(fileID);
str3 = fgetl(fileID);
str4 = fgetl(fileID);
while(~feof(fileID))
        str4 = fgetl(fileID);
        n = str2num(str4);
        p = n(1); % person number
        set = n(2); % scenario number
        act_num = n(3);
        subseq_num = n(4);
        if(subseq_num == 1)
            nums_cell = {}; % reinitialization
            st_end_frame = {};
        end
        start_frame = n(5);
        end_frame = n(6);
        nums = n(7:length(n));
        nums = reshape(nums,4,length(nums)/4);
        nums_cell{subseq_num} = nums;    
        st_end_frame{subseq_num} = [start_frame,end_frame];
        boundingboxes{act_num,(p-1)*num_of_sets + set} = nums_cell; % this keeps overwriting with the new nums_cell(which gets updates for every subsequence)
        start_end_frames{act_num,(p-1)*num_of_sets + set} = st_end_frame;
end
fileID(close);

%%%%%%%%%%%%%%%%%% END OF FEATURE EXTRACTION PARAMS %%%%%%%%%%%%%%%%%

% load training file params 
training_params_filename = sprintf('Training_Params.mat');
load(training_params_filename);

% load features
load ForegroundFeatures
load Background_Features

% iterating through each run
for rr = 1:2
    
    % Action labels/frame : same as action classification but only a single
    % frame
    
    % load the test index and the stacked auto-encoders
    sae_filename = sprintf('SAE_Workspace_Run%d.mat',rr);
    load(sae_filename);
    
    % Load the clusters for this run
    clusters_filename = sprintf('Cluster_Workspace_Run%d.mat',rr);
    load(clusters_filename);
    
    % Load the SVM Classifiers
    svm_filename = sprintf('SVM_Workspace_Run%d.mat',rr);
    load(svm_filename);
    
    % Get the test features from annotated sequences and background
    [~, Features_test,params] = getFeaturesTrain(Features,testIndex);
    Features_test_bg  = getFeaturesTest_bg(Features_bg(4:6,:),testIndex,params);
     
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
            
            % find the minimum distance for each frame % Hard
            % Classification
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

    results_phase2 = results;
    results_filename = sprintf('Results_Phase2_Action_Classification_Run-%d.mat',rr);
    save(results_filename,'results_phase2');
    
end