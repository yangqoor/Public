%Script for Feature Extraction for KTH Dataset
clear all;
clc;

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
    for action = 1:1:num_of_actions
        action_name = set_of_classes{action};
        for set = 1:1:num_of_sets
                tline_header = fgetl(fileID);
                [tline_1 frame_count_subseq] = sscanf(tline_header,'%c');
                nums = sscanf(tline_1,'%*s%*s %d-%d, %d-%d, %d-%d, %d-%d');
                nums = reshape(nums,2,length(nums)/2);
                seq_divs{action,(p - 1) * num_of_sets + set} = nums;
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
        action = n(3);
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
        boundingboxes{action,(p-1)*num_of_sets + set} = nums_cell; % this keeps overwriting with the new nums_cell(which gets updates for every subsequence)
        start_end_frames{action,(p-1)*num_of_sets + set} = st_end_frame;
end
fileID(close);


%% Extracting Features from MHI video data
% Set the path variable to read the STIP points for each video sequence

path_mhi = '/home/prci/Datasets/KTH/MHI';
path_video = '/home/prci/Datasets/KTH';
path_features = '/home/prci/Datasets/KTH/Features';
% Set->Action->Person->subSeq
%figure(1);
%title('Image Annotated with Bounding Boxes');
Features = cell(num_of_actions,num_of_persons);

%%
tic
%Iterate through sets
for p = 1:1:num_of_persons
    %Iterate through person
    for action = 6:1:num_of_actions
        action_name = set_of_classes{action};
        Features_per_set = cell(max_num_of_subseqs,num_of_sets);
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
            
            % A check to see if the number of entries in the bounding box
            % is the same as that of the seq_div_current
            
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
                
                for k = 2:1:num_of_frames
                %for k = start_frame:end_frame
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
%                     
%                     % save images of current image and optical flow
%                     if(action == 6 && k > 33 && k< 40)
%                         figure(1);
%                     end
                    
                    
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
                    H_Flow = [H_Flow ; H];
                    L_Flow = [L_Flow ; L];
                    R_Flow = [R_Flow ; R];
                        %fprintf('Frame - %d\n',k);
                    %end
                    %prev_img = current_img;
                    
                % End of subsequence frames
                end
                Features_per_subseq{1} = H_Flow;
                Features_per_subseq{2} = L_Flow;
                Features_per_subseq{3} = R_Flow;
                Features_per_set{subseq_num,set} = Features_per_subseq;
                fprintf('Features Extracted for Sequence person%d_%s_d%d_uncomp: Subsequence = %d\n',p,action_name,set,subseq_num);
                
            % End of Subsequence loop    
            end
            
            % removing the unzipped directory for that sequence
            rmdir(features_dir,'s');
            
        % End of Set loop    
        end
        Features{action,p} = Features_per_set;
    % End of action loop    
    end

% End of person loop
end
toc

% Saving the featuresx
save('ForegroundFeatures_KTH.mat','Features');










