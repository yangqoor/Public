clear all; clc;
% Adding the path
addpath(genpath('/home/roshni.uppala/Documents/MATLAB/Binu_Dissertation/Algorithm/'))

% load the background and foreground features
load ForegroundFeatures_UCF.mat

%%%%%%%%%%%%% FEATURE EXTRACTION PARAMS %%%%%%%%%%%%%%%%%%

%Script for Feature Extraction for KTH Dataset
set_of_classes = {'dive','golf','kick','lift','ride','run','skate','swing1','swing2','walk'};
num_of_actions = length(set_of_classes);

path_video = '/home/roshni.uppala/Datasets/ucf_sports_actions_edited2';
path_features = '//home/roshni.uppala/Datasets/ucf_sports_actions_edited2/Features';
path_gt = '/home/roshni.uppala/Datasets/ucf_sports_actions_edited2/gt';
path_mhi = '/home/roshni.uppala/Datasets/ucf_sports_actions_edited2/MHI';
num_of_bins = 16;

% Error list - containing the sequence and frame number
err_list = {};

%%%%%%%%%%%%%%%%%% END OF FEATURE EXTRACTION PARAMS %%%%%%%%%%%%%%%%%

% load training file params 
training_params_filename = sprintf('Training_Params_UCF.mat');
load(training_params_filename);

% set the required test parameters
nt = 5;
L = 50; % temporal window length of the sequence
L_dash = 3*nt; % minimum number of distinct codeword transitions within L
L_shift = 2*nt;

% Iterating through each run
for rr = 1:2
    % load the test index and the stacked auto-encoders
    sae_filename = sprintf('SAE_Workspace_Run%d_UCF.mat',rr);
    load(sae_filename);
    
    % Load the clusters for this run
    clusters_filename = sprintf('Cluster_Workspace_Run%d_UCF.mat',rr);
    load(clusters_filename);
    
    % Load the CRBM trained classifiers
    crbm_filename = sprintf('CRBM_Workspace_Run%d_UCF.mat',rr);
    load(crbm_filename);
    
    %[~, Features_test,params] = getFeaturesTrain(Features,testIndex);
    [Features_train,params] = getFeaturesTrain_UCF_TestIndex(Features,testIndices);
    
    % iterating through each action
    for action = 1%1:1:num_of_actions
        action_name = set_of_classes{action};
        path_features_per_action = sprintf('%s/%s',path_features,set_of_classes{action});
        path_gt_per_action = sprintf('%s/%s',path_gt,set_of_classes{action});
        %path_mhi_per_action = sprintf('%s/%s',path_mhi,set_of_classes{action});
        path_per_action = sprintf('%s/%s',path_video,set_of_classes{action});
        listing = dir(path_features_per_action);
        file_count = 1;
        for fi = testIndices{action}(1)+2+1:1:length(listing)
            if(listing(fi).name == '.')
                    continue;
            end
            file_name = listing(fi).name;

            % get the tar file
            features_tar = sprintf('%s/%s',path_features_per_action,file_name);

            file_dir = file_name(1:end-7);

            % getting the directory which contains the optical flow vectors for an action 'm' and for a single sequence
            path_features_per_action_per_seq = sprintf('%s/%s',path_features_per_action,file_dir);
            path_gt_per_action_per_seq = sprintf('%s/%s',path_gt_per_action,file_dir);

            % create the directory containing optical flow features
            try
                untar(features_tar,path_features_per_action);
            catch exception
                disp(exception)
                continue;
            end

            %mhi_videofilename = sprintf('%s/%s_mhi.avi',path_mhi_per_action,file_dir);
            videofilename= sprintf('%s/%s.avi',path_per_action,file_dir);
            
            % open the video file for reading
            try
                obj_video = VideoReader(videofilename);
            catch exception
                disp(exception);
                continue;
            end
            

            listing_per_action_per_seq_features = dir(path_features_per_action_per_seq);
            listing_per_action_per_seq_gt = dir(path_gt_per_action_per_seq);
            
            num_of_frames = (length(listing_per_action_per_seq_features) - 2)/2 + 1;
            L_Flow = [];
            H_Flow = [];
            R_Flow = [];
            subseq_video = read(obj_video);
            b_box = [];
            % Iterating through each frame
            for k = 3:1:num_of_frames-1
                % loading the optical flow magnitude and direction
                optMag_file = sprintf('%s/optflow_mag_framecount_%d.txt',path_features_per_action_per_seq,k);
                optDir_file = sprintf('%s/optflow_dir_framecount_%d.txt',path_features_per_action_per_seq,k);
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
                
                img_mask = ones(size(img_mag,1),size(img_mag,2));
                if(~(length(listing_per_action_per_seq_gt) - 2 == 0)) % no ground truth files
                    filename = sprintf('%s/%s',path_gt_per_action_per_seq,listing_per_action_per_seq_gt(k+2).name);
                    fileID = fopen(filename); % opening the file
                    bound_box = fscanf(fileID,'%d',[1 4]);
                    b_box = [b_box ; bound_box];
                    fclose(fileID);
                else
                    bound_box = [1 1 size(img_mag,2) size(img_mag,1)];
                end
                
                img_mag = imcrop(img_mag,bound_box);
                img_dir = imcrop(img_dir,bound_box);
                img_mask_crop = imcrop(img_mask,bound_box);
                
                %current_img = subseq_video(:,:,:,k);
                %imshow(current_img);
                %rectangle('Position',bound_box,'EdgeColor','r');
                
                try
                    % compute LBPHOF/RT Flow
                    [H,L] = ComputeLBPHOF(img_mag,img_dir,img_mask_crop,true); % cropped version of the mask
                    R = ComputeRTransform(img_mag,2,img_mask_crop,true);
                catch exception
                    disp(exception);
                    H = zeros(1,size(H_Flow,2));
                    L = zeros(1,size(L_Flow,2));
                    R = zeros(1,size(R_Flow,2));
                end
                
                H_Flow = [H_Flow ; H];
                L_Flow = [L_Flow ; L];
                R_Flow = [R_Flow ; R];
                %pause(0.1);
            end
            % Computation of features done!!
            
            % Add that section of the code
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
                
                action_detected = ones(L,1);
                
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
                    %                             ax(1) = subplot(2,3,1);scatter3(0,0,0,'xg'); hold(ax(1));title(ax(1),set_of_classes{1});
                    %                             ax(2) = subplot(2,3,2);scatter3(0,0,0,'xg'); hold(ax(2));title(ax(1),set_of_classes{1});
                    %                             ax(3) = subplot(2,3,3);scatter3(0,0,0,'xg'); hold(ax(3));title(ax(1),set_of_classes{1});
                    %                             ax(4) = subplot(2,3,4);scatter3(0,0,0,'xg'); hold(ax(4));title(ax(1),set_of_classes{1});
                    %                             ax(5) = subplot(2,3,5);scatter3(0,0,0,'xg'); hold(ax(5));title(ax(1),set_of_classes{1});
                    %                             ax(6) = subplot(2,3,6);scatter3(0,0,0,'xg'); hold(ax(6));title(ax(1),set_of_classes{1});
                    for act_num = 1:1:num_of_actions
                        s_title = sprintf('%s Trained Model',set_of_classes{act_num});
                        ax(act_num) = subplot(2,num_of_actions/2,act_num);scatter3(0,0,0,'xg'); hold(ax(act_num));title(ax(act_num),s_title);
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
                            str = sprintf('%s : %f\%',set_of_classes{act_num},w_cum_perc(act_num,start_fr_num)*100);
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
            
        end
    end
end

