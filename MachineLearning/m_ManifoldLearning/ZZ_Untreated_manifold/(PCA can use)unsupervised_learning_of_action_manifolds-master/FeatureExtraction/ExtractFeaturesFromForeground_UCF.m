% %Script for Feature Extraction for KTH Dataset
% set_of_classes = {'dive','golf','kick','lift','ride','run','skate','swing1','swing2','walk'};
% num_of_actions = length(set_of_classes);
% 
% path_video = '/home/prci/Datasets/ucf_sports_actions_edited2';
% path_features = '/home/prci/Datasets/ucf_sports_actions_edited2/Features';
% path_gt = '/home/prci/Datasets/ucf_sports_actions_edited2/gt';
% path_mhi = '/home/prci/Datasets/ucf_sports_actions_edited2/MHI';
% Features = {};
% num_of_bins = 16;
% 
% % Error list - containing the sequence and frame number
% err_list = {};

%%
tic;
% problem with golf sequence after sequence 2...
for action = 4:1:num_of_actions
        path_features_per_action = sprintf('%s/%s',path_features,set_of_classes{action});
        path_gt_per_action = sprintf('%s/%s',path_gt,set_of_classes{action});
        %path_mhi_per_action = sprintf('%s/%s',path_mhi,set_of_classes{action});
        path_per_action = sprintf('%s/%s',path_video,set_of_classes{action});
        listing = dir(path_features_per_action);
        file_count = 1;
        for fi = 1:1:length(listing)
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
                
                listing_per_action_per_seq_features = dir(path_features_per_action_per_seq);
                listing_per_action_per_seq_gt = dir(path_gt_per_action_per_seq);
                
%                 try
%                     mhi_video = VideoReader(mhi_videofilename);
%                 catch exception
%                     disp(exception);
%                     continue;
%                 end
                %video = VideoReader(videofilename);

                % getting the number of frames : number of files in gt directory
                % offset is from 2 to number of frames(k = 2:1:num_of_frames)
                % the gt file is indexed by (k+2) : the 2 since there will be two dots like before the filename starts 
                num_of_frames = (length(listing_per_action_per_seq_features) - 2)/2 + 1;
                L_Flow = [];
                H_Flow = [];
                VL_Flow = [];
                R_Flow = [];
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
                    
                    % getting the previous optical flow direction
                    optDir_prev_file = sprintf('%s/optflow_dir_framecount_%d.txt',path_features_per_action_per_seq,k-1);
                    fileID = fopen(optDir_prev_file);
                    str1 = fgetl(fileID);
                    str2 = fgetl(fileID);
                    sizeA = str2num(str2);
                    A = fscanf(fileID,'%f',[sizeA(2) sizeA(1)]);
                    img_dir_prev = A';
                    fclose(fileID);

                    % getting the next optical flow direction
                    optDir_next_file = sprintf('%s/optflow_dir_framecount_%d.txt',path_features_per_action_per_seq,k+1);
                    fileID = fopen(optDir_next_file);
                    str1 = fgetl(fileID);
                    str2 = fgetl(fileID);
                    sizeA = str2num(str2);
                    A = fscanf(fileID,'%f',[sizeA(2) sizeA(1)]);
                    img_dir_next = A';
                    fclose(fileID);
                    
                     % loading the MHI data as well
                    %current_img = read(video,k);
                    %img_mhi = double(rgb2gray(read(mhi_video,k)));
                    img_mask = ones(size(img_mag,1),size(img_mag,2));
%                     img_dir_cube = [];
%                     try
%                         % forming the cube of img_dir for VLBFP.m
%                         img_dir_cube(:,:,1) = QuantizeDirection(img_dir_prev,num_of_bins);
%                         img_dir_cube(:,:,1) = QuantizeDirection(img_dir_prev,num_of_bins);
%                         img_dir_cube(:,:,2) = QuantizeDirection(img_dir,num_of_bins);
%                         img_dir_cube(:,:,3) = QuantizeDirection(img_dir_next,num_of_bins);
%                     catch exception
%                         %err_disp(exception)
%                         err_seq = {file_dir ; k};
%                         err_list = [err_list err_seq];
%                         H = zeros(1,size(H_Flow,2));
%                         L = zeros(1,size(L_Flow,2));
%                         %VL = zeros(1,size(L_Flow,2));
%                         R = zeros(1,size(R_Flow,2));
%                         
%                         H_Flow = [H_Flow ; H];
%                         L_Flow = [L_Flow ; L];
%                         R_Flow = [R_Flow ; R];
%                         %VL_Flow = [VL_Flow; VL];
%                         continue;
%                     end
% 
                    % loading the ground truth
                    if(~(length(listing_per_action_per_seq_gt) - 2 == 0)) % no ground truth files
                        % create the bounding box from the mask computed from the image magnitude
                        % Since the background is very stationary
                        % bounding box is the entire frame
                         % opening the ground truth file for that frame
                        filename = sprintf('%s/%s',path_gt_per_action_per_seq,listing_per_action_per_seq_gt(k+2).name);
%                         filename_prev = sprintf('%s/%s',path_gt_per_action_per_seq,listing_per_action_per_seq_gt(k+1).name);
%                         filename_next = sprintf('%s/%s',path_gt_per_action_per_seq,listing_per_action_per_seq_gt(k+3).name);
                        
                        % current bounding box
                        fileID = fopen(filename); % opening the file
                        bound_box = fscanf(fileID,'%d',[1 4]);
                        fclose(fileID);
                        
%                         % previous bounding box
%                         fileID = fopen(filename_prev); % opening the file
%                         bound_box_prev = fscanf(fileID,'%d',[1 4]);
%                         fclose(fileID);
%                         
%                         % next bounding box
%                         fileID = fopen(filename_next); % opening the file
%                         bound_box_next = fscanf(fileID,'%d',[1 4]);
%                         fclose(fileID);       
                    else
                        bound_box = [1 1 size(img_mag,2) size(img_mag,1)];
%                         bound_box_prev = bound_box;
%                         bound_box_next = bound_box;
                    end
%                    
%                    bound_box_cube = [bound_box_prev ; bound_box ; bound_box_next];     
                    
                    img_mag = imcrop(img_mag,bound_box);
                    img_dir = imcrop(img_dir,bound_box);
                    img_mask_crop = imcrop(img_mask,bound_box);
                    %img = imcrop(current_img,bound_box);
                    %img_mhi = imcrop(img_mhi,bound_box);
                    
                   try
                        % compute LBPHOF/RT Flow
                        [H,L] = ComputeLBPHOF(img_mag,img_dir,img_mask_crop,true); % cropped version of the mask
                        %R = ComputeRTransform(img_mhi,2,img_mask_crop,true); % entire image mask created from MHI to get shape of MHI
                        R = ComputeRTransform(img_mag,2,img_mask_crop,true);
                        %VL = RIVLBFP(img_dir_cube, 1, 1, 2, 1, 1, 1, 0,bound_box_cube);
                        %VL = VL';
                    catch exception
                        disp(exception);
                        H = zeros(1,size(H_Flow,2));
                        L = zeros(1,size(L_Flow,2));
                        %VL = zeros(1,size(L_Flow,2));
                        R = zeros(1,size(R_Flow,2));
                   end
                        
                    H_Flow = [H_Flow ; H];
                    L_Flow = [L_Flow ; L];
                    R_Flow = [R_Flow ; R];
                    %VL_Flow = [VL_Flow; VL];
                end   
                Features_per_action_per_seq{1} = H_Flow;
                Features_per_action_per_seq{2} = L_Flow;
                Features_per_action_per_seq{3} = R_Flow;
                %Features_per_action_per_seq{4} = VL_Flow;
                Features{action,file_count} = Features_per_action_per_seq;

                fprintf('Features Extracted for action %s from sequence %s.avi\n',set_of_classes{action},file_dir);
                
                % removing the unzipped directory for that sequence
                rmdir(path_features_per_action_per_seq,'s');
                
                file_count = file_count + 1;
        end
end
toc;

% Saving the featuresx
save('ForegroundFeatures_UCF.mat','Features');










