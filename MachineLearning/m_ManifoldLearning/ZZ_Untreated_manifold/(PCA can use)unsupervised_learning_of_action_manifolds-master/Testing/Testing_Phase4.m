%% Script file to illustrate the view the percentage of completion with and without the use of CRBM
clear all; clc;
% Adding the path
addpath(genpath('/home/roshni.uppala/Documents/MATLAB/Binu_Dissertation/Algorithm/'))

% load the background and foreground features
load ForegroundFeatures
load Background_Features

%%%%%%%%%%%%% FEATURE EXTRACTION PARAMS %%%%%%%%%%%%%%%%%%
set_of_classes = {'boxing','handclapping','handwaving','jogging','running','walking'};
set_of_classes_disp = {'Box','HClap','HWave','Jog','Run','Walk'};
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
subseq_attribute_path  = '/home/roshni.uppala/Datasets/KTH/00sequences_copy.txt';
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
bounding_box_info_file = '/home/roshni.uppala/Datasets/KTH/KTHBoundingBoxInfo.txt';
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
%%
path_mhi = '/home/roshni.uppala/Datasets/KTH/MHI';
path_video = '/home/roshni.uppala/Datasets/KTH';
path_features = '/home/roshni.uppala/Datasets/KTH/Features';

% load training file params 
training_params_filename = sprintf('Training_Params.mat');
load(training_params_filename);

% set the required test parameters
nt = 5;
L = 50; % temporal window length of the sequence
L_dash = 3*nt; % minimum number of distinct codeword transitions within L
L_shift = 2*nt;

% iterating through each run
for rr = 1
   
    % Load the corresponding training files such as stacked_autoencoders,
    % CRBMS, clusters for each action class
    
    % load the test index and the stacked auto-encoders
    sae_filename = sprintf('SAE_Workspace_Run%d_OptimalAuto.mat',rr);
    load(sae_filename);
    
    % Load the clusters for this run
    clusters_filename = sprintf('Cluster_Workspace_Run%d_OptimalAuto.mat',rr);
    load(clusters_filename);
    
    % Load the SVM Classifiers
    svm_filename = sprintf('SVM_Workspace_Run%d_OptimalAuto.mat',rr);
    load(svm_filename);
    
    % Load the CRBM trained classifiers
    crbm_filename = sprintf('CRBM_Workspace_Run%d_OptimalAuto.mat',rr);
    load(crbm_filename);
    
    % Get the test features from annotated sequences and background
    [~, Features_test,params] = getFeaturesTrain(Features,testIndex);
    Features_test_bg  = getFeaturesTest_bg(Features_bg(4:6,:),testIndex,params);
    
    %Iterate through sets
    for p = testIndex(5)%1:1:num_of_persons
        %Iterate through person
        for action = 6%2:1:num_of_actions
            action_name = set_of_classes{action};
            
            %Iterate through action class
            for set = 1:1:num_of_sets
                if(p < 10)
                    mhi_video_file = sprintf('%s/%s/person0%d_%s_d%d_uncomp_mhi.avi',path_mhi,action_name,p,action_name,set);
                    video_file = sprintf('%s/%s/person0%d_%s_d%d_uncomp.avi',path_video,action_name,p,action_name,set);
                    features_tar = sprintf('%s/%s/person0%d_%s_d%d_uncomp.tar.gz',path_features,action_name,p,action_name,set);
                else
                    mhi_video_file = sprintf('%s/%s/person%d_%s_d%d_uncomp_mhi.avi',path_mhi,action_name,p,action_name,set);
                    video_file = sprintf('%s/%s/person%d_%s_d%d_uncomp.avi',path_video,action_name,p,action_name,set);
                    features_tar = sprintf('%s/%s/person%d_%s_d%d_uncomp.tar.gz',path_features,action_name,p,action_name,set);
                end
                features_dir = sprintf('%s/%s',path_features,action_name);

                % untar the file directory
                try
                    untar(features_tar,features_dir);
                catch exception
                    disp(exception)
                    continue;
                end
                % update the feature_dir
                if(p < 10)
                    features_dir = sprintf('%s/person0%d_%s_d%d_uncomp',features_dir,p,action_name,set);
                else
                    features_dir = sprintf('%s/person%d_%s_d%d_uncomp',features_dir,p,action_name,set);
                end
                
                try
                    obj_video = VideoReader(video_file);
                catch exception
                    disp(exception);
                    continue;
                end
                
                % Getting the sequence division of the current sequence
                seq_div_current = seq_divs{action,(p-1)*num_of_sets + set};
                boundingbox_cell = boundingboxes{action,(p-1)*num_of_sets + set};
                st_end_frame = start_end_frames{action,(p-1)*num_of_sets + set};
                
                for subseq_num = 1:1:size(seq_div_current,2)
                    % get the bounding box
                    b_box = boundingbox_cell{subseq_num}';
                    
                    % Converting the format of b_box from [y_min x_min y_max
                    % x_max] to [x_min y_min width height]
                    width = b_box(:,4) - b_box(:,2);
                    height = b_box(:,3) - b_box(:,1);
                    temp = b_box(:,2);
                    b_box(:,2) = b_box(:,1);
                    b_box(:,1) = temp;
                    b_box(:,3) = width;
                    b_box(:,4) = height;


                    L_Flow = [];
                    H_Flow = [];
                    R_Flow = [];
                    prev_img = [];

                    % Extract Features
                    temp = st_end_frame{subseq_num};
                    start_frame = temp(1);
                    end_frame = temp(2);

                    % read the corresponding video frames
                    subseq_video = read(obj_video,[start_frame end_frame]);
                    num_of_frames = size(subseq_video,4);
                    hf_feature = figure(1);
                    
                    output_video_file = sprintf('VideoDemo_VariationOfFeatures_%s.avi',action_name);
                    myObj_f = VideoWriter(output_video_file);
                    myObj_f.FrameRate = 10;
                    open(myObj_f);
                    
                    for k = 2:1:num_of_frames
                        
                        current_img = subseq_video(:,:,:,k);
                        img_mask = ones(size(current_img,1),size(current_img,2));
                    
                        % Getting the optical flow direction and magnitude file
                        optMag_file = sprintf('%s/optflow_mag_framecount_%d.txt',features_dir,start_frame+k-1);
                        optDir_file = sprintf('%s/optflow_dir_framecount_%d.txt',features_dir,start_frame+k-1);
                        fileID = fopen(optMag_file);
                        str1 = fgetl(fileID);
                        str2 = fgetl(fileID);
                        sizeA = str2num(str2);
                        A = fscanf(fileID,'%f',[sizeA(2) sizeA(1)]);
                        img_mag = A';
                        fclose(fileID);

                        fileID = fopen(optDir_file);
                        str1 = fgetl(fileID);
                        str2 = fgetl(fileID);
                        sizeA = str2num(str2);
                        A = fscanf(fileID,'%f',[sizeA(2) sizeA(1)]);
                        img_dir = A';
                        fclose(fileID);

                        % Here, remove mismatches in Optical Flow by Median
                        % Filtering
                        u = img_mag .* cosd(img_dir);
                        v = img_mag .* sind(img_dir);
                        
                        img_mag = sqrt(u.^2 + v.^2);
                        img_dir = atan2(v,u) *180 / pi ;

                        % TODO: Try to so
                        try
                            bound_box = b_box(k,:);
                        catch exception
                            print exception
                        end
                        bound_box(1:2) = bound_box(1:2) - b_inc/100*bound_box(3:4);
                        bound_box(3:4) = bound_box(3:4) + 2*b_inc/100*bound_box(3:4);

                        img_mag = imcrop(img_mag,bound_box);
                        img_dir = imcrop(img_dir,bound_box);
                        img_mask_crop = imcrop(img_mask,bound_box);
                        img = imcrop(current_img,bound_box);

                        %imshow(current_img);
                        %rectangle('Position',bound_box,'EdgeColor','r');
                        %pause(0.1);


                        try
                            % compute LBPHOF/RT Flow
                            [H,L] = ComputeLBPHOF(img_mag,img_dir,img_mask_crop,true); % cropped version of the mask
                            R = ComputeRTransform(img_mag,2,img_mask_crop,true); % entire image mask created from MHI to get shape of MHI
                        catch exception
                            disp(exception);
                            H = zeros(1,size(H_Flow,2));
                            L = zeros(1,size(L_Flow,2));
                            R = zeros(1,size(R_Flow,2));
                        end
                        
                        % Display the frame
                        ha2 = subplot(3,1,1);
                        plot(1:length(H),H); xlabel(ha2,'Number of Bins');ylabel(ha2,'HHOF');
                        ha3 = subplot(3,1,2);
                        plot(1:length(L),L); xlabel(ha3,'Number of Bins');ylabel(ha3,'LBFP');
                        ha4 = subplot(3,1,3);
                        plot(R); xlabel(ha4,'Number of Bins');ylabel(ha4,'RT');
                        
                        frame_f = getframe(hf_feature);
                        writeVideo(myObj_f,frame_f.cdata);
                        
                        H_Flow = [H_Flow ; H];
                        L_Flow = [L_Flow ; L];
                        R_Flow = [R_Flow ; R]; 
                    end
                    close(myObj_f);
                    % End of computation of features
                    
                    % Normalize the data using params
                    HOF_Flow = H_Flow ./ repmat(params.factor_HOF,size(H_Flow,1),1);
                    LBP_Flow = L_Flow ./ repmat(params.factor_LBP,size(L_Flow,1),1);
                    RT_Flow = R_Flow ./ repmat(params.factor_RT,size(R_Flow,1),1);
                    
                    % concatenate together to form the feature vector
                    test_seq = [HOF_Flow LBP_Flow RT_Flow];
                    
                    %% PHASE 3 COMPUTATION WITH ILLUSTRATION OF PERCENTAGE OF ILLUSTRATION
                    num_of_test_frames = size(test_seq,1);
                    
                    % Now, to simulate the streaming sequence
                    % Taking every L frames with a shift of L_shift
                    dist_of_temp_win = zeros(num_of_actions,length(L:L_shift:num_of_test_frames));
                    win_count = 0;
                    % hack for full sequence
                    L = num_of_test_frames;
                    for kl = L:L_shift:num_of_test_frames
                        
                        win_count = win_count + 1;
                        % get the L frames
                        test_seq_loc = test_seq(kl-L+1:1:kl,:);
                        
                        %%%%%% Action Detection at each frame %%%%%%%%%%%%%
                        % apply the SVM classifier
                        a_data_test = test_seq_loc;
                        K_data_test = slmetric_pw(a_data_test',a_data','chisq');
                        K_combined_test = exp(-1/A_mean * K_data_test);
                        data_test = [ (1:size(a_data_test,1))' , K_combined_test];
                        
                        [predicted_label,accuracy,decision_values] = libsvmpredict(rand(size(a_data_test,1),1),data_test,svm_model,'-b 1 -q');
                        
                        action_detected = (~predicted_label);
                        
                        % TODO: Check if there are consecutive background labels detected
                        % for L_shift frames
                        flag_consecutive_bg = false;
                        
                        % Proceed with finding appropriate codewords for frames
                        % with foreground detected
                        if(~flag_consecutive_bg)
                            % get the frames with only foreground
                            id_fg = find(action_detected == 1);
                            
                            % number of foreground segments detected
                            % here, if number of detected foreground frames are
                            % less than L/2 frames, no point in analyzing it
                            num_detected_fg = length(id_fg);
                            if(num_detected_fg < 3*L/4)
                                continue;
                            end
                            
                            test_seq_loc = test_seq_loc(id_fg,:);
                            num_of_test_frames_fg = size(test_seq_loc,1);
                            
                            % Find the corresponding cluster to each frame
                            [ids,dis] = yael_nn(single(global_C'),single(test_seq_loc'));
                            est_act_codewords_ids = ids;
                            
                            % Find the set of actual action codewords which get
                            % fired.
                            %[true_act_codewords_ids,~] = yael_nn(single(global_C'),single(test_seq_loc'));
                            
                            % Replace each frame with the codeword. No removal of duplicate
                            % codewords here
                            X_test = zeros(num_of_test_frames_fg,size(test_seq,2));
                            for k = 1:1:num_of_test_frames_fg
                                X_test(k,:) = global_C(ids(k),:);
                            end
                            
%                             % Remove consecutive duplicate codewords in the sequences
%                             last_codeword_encoun = X_test(1,:);
%                             dup_ids = zeros(num_of_test_frames_fg,1);
%                             for k = 2:1:num_of_test_frames_fg
%                                 sum_dist = sum(sum((last_codeword_encoun - X_test(k,:)).^2));
%                                 if(sum_dist == 0) % duplicate : no change in last_codeword seen
%                                     dup_ids(k) = 1;
%                                 else % if no duplicate
%                                     last_codeword_encoun = X_test(k,:);
%                                 end
%                             end
%                             non_dup_ids = (~dup_ids);
%                             rel_ids = find(non_dup_ids ~= 0);
%                             
%                             X_test = X_test(rel_ids,:);
                            L_M = size(X_test,1); % num_frames_gen in this file
                            
                            
                            % check if number of distinct transitions between
                            % codewords is smaller than the minimum length
                            if(L_M < L_dash)
                                % here, increase L by a significant amount
                                % go to next shift
                                continue;
                            end
                            
                            % Apply the set of distinct codewords detected in L
                            % frames to the set of action models
                            dist_to_each_action = zeros(num_of_actions,L_M);
                            w = zeros(num_of_actions,L_M-L_dash+1);
                            cum_perc = zeros(num_of_actions,L_M-L_dash+1);
                            w_cum_perc = zeros(num_of_actions,L_M-L_dash+1);
                            perc = zeros(num_of_actions,L_M-L_dash+1);
                            w_perc = zeros(num_of_actions,L_M-L_dash+1);
                            flag_cycle_complete = zeros(num_of_actions,L_M-L_dash+1); % oscillates between -1 and +1
                            w_flag_cycle_complete = zeros(num_of_actions,L_M-L_dash+1);
                            
                            output_video_file = sprintf('VideoDemo_PercentOfCompletion_%s.avi',action_name);
                            myObj = VideoWriter(output_video_file);
                            myObj.FrameRate = 1;
                            open(myObj);
                            
                            output_video_file2 = sprintf('VideoDemo_CRBMPrediction_%s.avi',action_name);
                            myObj2 = VideoWriter(output_video_file2);
                            myObj2.FrameRate = 1;
                            open(myObj2);
                            
                            % figure and axes handles to plot prediction on
                            % corresponding action plots
                            hf_pred = figure(2);plot(0,0);
                            ax_pred = get(hf_pred,'CurrentAxes');
%                             ax(1) = subplot(2,3,1);scatter3(0,0,0,'xg'); hold(ax(1));title(ax(1),set_of_classes_disp{1});
%                             ax(2) = subplot(2,3,2);scatter3(0,0,0,'xg'); hold(ax(2));title(ax(1),set_of_classes_disp{1});
%                             ax(3) = subplot(2,3,3);scatter3(0,0,0,'xg'); hold(ax(3));title(ax(1),set_of_classes_disp{1});
%                             ax(4) = subplot(2,3,4);scatter3(0,0,0,'xg'); hold(ax(4));title(ax(1),set_of_classes_disp{1});
%                             ax(5) = subplot(2,3,5);scatter3(0,0,0,'xg'); hold(ax(5));title(ax(1),set_of_classes_disp{1});
%                             ax(6) = subplot(2,3,6);scatter3(0,0,0,'xg'); hold(ax(6));title(ax(1),set_of_classes_disp{1});
                            for act_num = 1:1:num_of_actions
                                s_title = sprintf('%s Trained Model',set_of_classes_disp{act_num});
                                ax(act_num) = subplot(2,3,act_num);scatter3(0,0,0,'xg'); hold(ax(act_num));title(ax(act_num),s_title);
                            end
                                            
%                             hf_pred(1) = figure(1); scatter3(0,0,0,'xg'); ax(1) = get(hf_pred(1),'CurrentAxes'); hold(ax(1));
%                             hf_pred(2) = figure(2); scatter3(0,0,0,'xg'); ax(2) = get(hf_pred(2),'CurrentAxes'); hold(ax(2));
%                             hf_pred(3) = figure(3); scatter3(0,0,0,'xg'); ax(3) = get(hf_pred(3),'CurrentAxes'); hold(ax(3));
%                             hf_pred(4) = figure(4); scatter3(0,0,0,'xg'); ax(4) = get(hf_pred(4),'CurrentAxes'); hold(ax(4));
%                             hf_pred(5) = figure(5); scatter3(0,0,0,'xg'); ax(5) = get(hf_pred(5),'CurrentAxes'); hold(ax(5));
%                             hf_pred(6) = figure(6); scatter3(0,0,0,'xg'); ax(6) = get(hf_pred(6),'CurrentAxes'); hold(ax(6));
                            
                            % figure handle for percentage plots
                            hf_img = figure(3);plot(0,0);
                            ax_img = get(hf_img,'CurrentAxes');
                            
                            % Applying the crbm
                            for start_fr_num = 1:1:L_M-L_dash+1 
                                for act_num = 1:1:num_of_actions
                                    % get the corresponding auto-encoder
                                    st = sae{act_num};
                                    crbm_local = crbm{act_num};

                                    % apply to the auto-encoder of action class
                                    % 'act_num'
                                    [X_test_out, a_X_test_out] = sae_nn_ff(st,X_test);

                                    % Normalizing the data to pass it to CRBM
                                    a_X_test_out_norm = (a_X_test_out - repmat(crbm_local.data_mean,L_M,1))./(repmat(crbm_local.data_std,L_M,1));

                                    crbm_local.numGibbs = 1000;
                                    
                                    [a_X_test_out_rec_norm,hidden1,hidden2] = testCRBM(crbm_local,L_dash,a_X_test_out_norm,start_fr_num);
                                    
                                    % get the unnormalized version from the regenerated sequence
                                    a_X_test_out_rec = (a_X_test_out_rec_norm .* repmat(crbm_local.data_std,L_dash,1)) + repmat(crbm_local.data_mean,L_dash,1);
                                    
                                    a_X1 = a_X_test_out(start_fr_num+2*nt:1:L_dash + start_fr_num-1,:);
                                    a_X2 = a_X_test_out_rec(2*nt+1:L_dash,:);
                                    
                                    % average of the predictions and actual
                                    % codewords
                                    a_X1_avg = mean(a_X1,1);
                                    a_X2_avg = mean(a_X2,1);
                                    
                                    scatter3(ax(act_num),a_X1_avg(1,1),a_X1_avg(1,2),a_X1_avg(1,3),'b','filled');
                                    scatter3(ax(act_num),a_X2_avg(1,1),a_X2_avg(1,2),a_X2_avg(1,3),'r','filled');
                                    %axis(ax(act_num),[-1 1 -1 1 -1 1]);
                                   
                                    % apply the decoder
                                    X_test_out_rec = sae_ff_nn_decoder(st,a_X_test_out_rec);
                                    X1 = X_test(start_fr_num+2*nt:1:L_dash + start_fr_num-1,:);
                                    X2 = X_test_out_rec(2*nt+1:L_dash,:);
                                    
                                    dist1 = slmetric_pw(X1',X2','chisq');
                                    dist2 = diag(dist1); % only taking measures at the same frame instances
                                    dist_to_each_action(act_num,2*nt+start_fr_num-1)= sum(dist2);
                                    
                                    % plot the actual codeword and
                                    % predicted codeword at the first
                                    % predicted time instants ( not for rest
                                    % of nt time instants

                                    
                                    
                                    % compute the weights for this short window of
                                    % L_dash frames ( 3*nt)
                                    % For every frame shift of this window, a
                                    % corresponding weight is computed
                                    w(act_num,start_fr_num) = exp(-1/nt * sum(dist2));
                                    ids_of_ids = find((ids >= (act_num-1)*num_manifold_steps + 1) & (ids <= act_num*num_manifold_steps));
                                    actv_codewords_ids = ids(ids_of_ids);
                                    perc(act_num,start_fr_num) = length(actv_codewords_ids)/num_manifold_steps;
                                    w_perc(act_num,start_fr_num) = w(act_num,start_fr_num)*perc(act_num,start_fr_num);
                                    
                                    if(start_fr_num == 1)
                                        cum_perc(act_num,start_fr_num) = perc(act_num,start_fr_num);
                                        w_cum_perc(act_num,start_fr_num) = w_perc(act_num,start_fr_num);
                                        w_flag_cycle_complete(act_num,start_fr_num) = 1;
                                        flag_cycle_complete(act_num,start_fr_num) = 1;
                                    else
                                        cum_perc(act_num,start_fr_num) = cum_perc(act_num,start_fr_num-1) + perc(act_num,start_fr_num);
                                        w_cum_perc(act_num,start_fr_num) = w_cum_perc(act_num,start_fr_num-1) + w_perc(act_num,start_fr_num);
                                        w_flag_cycle_complete(act_num,start_fr_num) = w_flag_cycle_complete(act_num,start_fr_num-1);
                                        flag_cycle_complete(act_num,start_fr_num) = flag_cycle_complete(act_num,start_fr_num-1);
                                    end
                                    
                                    % check if cum_perc > 1 for an action,
                                    % reset all actions
                                    if(w_cum_perc(act_num,start_fr_num) >= 1)
                                        w_cum_perc(:,start_fr_num-1:start_fr_num) = 0;%w_perc(act_num,start_fr_num);
                                        w_flag_cycle_complete(act_num,start_fr_num) = -1 * w_flag_cycle_complete(act_num,start_fr_num-1);
                                    end
                                    
                                    % check if cum_perc > 1
                                    if(cum_perc(act_num,start_fr_num) >= 1)
                                        cum_perc(:,start_fr_num-1:start_fr_num) = 0;%perc(act_num,start_fr_num);
                                        flag_cycle_complete(act_num,start_fr_num) = -1 * flag_cycle_complete(act_num,start_fr_num-1);
                                    end
                                    
                                    % display each frame and percentage
                                    % accuracy
                                    % get the current img
                                    dist_to_each_action(act_num,L_dash+start_fr_num-1) = sum(sum((X_test(start_fr_num+2*nt:1:L_dash + start_fr_num-1,:) - X_test_out_rec(2*nt+1:L_dash,:)).^2));
                                    
                                end
                                
                                % code to display the frame and the
                                % percentage of completion
                                current_img = subseq_video(:,:,:,L_dash+start_fr_num-1);
                                disp_img = imresize(current_img,3);
                                imshow(disp_img,'Parent',ax_img);
                                for act_num = 1:1:num_of_actions
                                    str = sprintf('%s : %f\%',set_of_classes_disp{act_num},w_cum_perc(act_num,start_fr_num)*100);
                                    text(size(disp_img,2),size(disp_img,1)/12*(act_num-1)+1,str,'BackgroundColor',[1 1 1],'FontSize',11,'HorizontalAlignment','right','VerticalAlignment','top','Parent',ax_img);
                                end
                                bound_box = b_box(L_dash+start_fr_num-1,:);
                                rectangle('Position',bound_box*3,'EdgeColor','r','Parent',ax_img);                                
                                frame = getframe(hf_img);
                                writeVideo(myObj,frame.cdata);
                                
                                frame2 = getframe(hf_pred);
                                try
                                    writeVideo(myObj2,frame2.cdata);
                                catch exception
                                    disp(exception)
                                end
                                pause(0.001);
                            end
                            
                            % Now we get dist_to_each action for every 15 codeword
                            % window within the L_M set of distinct codewords
                            % after observing 3*nt=15 codewords at an instant within the
                            % L_M set of codewords, the action labels
                            
                            dist_of_temp_win(:,win_count) = (sum(dist_to_each_action(:,L_dash:L_M).^2, 2))/(length(L_dash:L_M));
                            
                        else
                            % set the result of the consecutive frames as zero
                            % label or background
                            % go to next shift
                            continue;
                        end
                        close(myObj);
                        close(myObj2);
                        fprintf('Finished testing window %d out of %d of seq %d-%d out of %d-%d\n',win_count,length(L:L_shift:num_of_test_frames),seq_row,seq_num,num_of_actions,(num_of_test_seqs/(num_of_sets)));
                        
                    end
                    
                    % Now, find the action class label for each window
                    % This is just to confirm if the labels for each action class
                    % are appropriate.
                    [mi,id] = min(dist_of_temp_win);
                    true_class = seq_row;
                    
                    for k = 1:1:length(id)
                        est_class = id(k);
                        results.action_class_L_framewindow(true_class,est_class) = results.action_class_L_framewindow(true_class,est_class) + 1;
                    end
                    
                    %%
                % end of sub-sequence    
                end
                
                
            % end of set 
            end
        
        % end of action
        end
    
    % end of person
    end
    
end