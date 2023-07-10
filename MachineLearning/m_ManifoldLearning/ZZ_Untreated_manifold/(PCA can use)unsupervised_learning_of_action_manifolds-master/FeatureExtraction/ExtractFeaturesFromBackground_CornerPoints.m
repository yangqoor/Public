%Script for Feature Extraction for KTH Dataset
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
Features_bg = cell(num_of_actions,num_of_persons);

%%
tic
%Iterate through sets
for p = 1:1:num_of_persons
    %Iterate through person
    for action = 4:1:num_of_actions % only from the 4th action
        action_name = set_of_classes{action};
        Features_per_set = cell(1,num_of_sets); % no subseq for background
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
            
            % Find the background frames in the complete sequence
            bg_frame_num = [];
            for s_num = 1:1:size(st_end_frame,2)
                if(s_num == 1)
                    st1 = st_end_frame{1}(1);
                    if(st1 ~= 1)
                        bg_frame_num = [bg_frame_num 1:1:st1-1];
                    end
                    continue;
                end
                st1 = st_end_frame{s_num-1}(2);
                st2 = st_end_frame{s_num}(1);
                
                % then some frames are missing
                if(st1 + 1 < st2)
                    bg_frame_num = [bg_frame_num st1+1:1:st2-1];
                end
            end
            
            % if there are background frames, compute the corresponding
            % features 
            % read the corresponding video frames
            subseq_video = read(obj_video);
            H_Flow = [];
            L_Flow = [];
            R_Flow = [];
            if(~isempty(bg_frame_num))   
                for k = bg_frame_num
                    current_img = subseq_video(:,:,:,k);
                    img_mask = ones(size(current_img,1),size(current_img,2));
                    
                    % Getting the optical flow direction and magnitude file
                    optMag_file = sprintf('%s/optflow_mag_framecount_%d.txt',features_dir,k+1);
                    optDir_file = sprintf('%s/optflow_dir_framecount_%d.txt',features_dir,k+1);
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
                   
                    % Compute corners of the image
                    cor_pts = corner(rgb2gray(current_img));
                        
                    for cc = 1:1:size(cor_pts,1);
                        pt.x = cor_pts(cc,1);
                        pt.y = cor_pts(cc,2);
                        rec = [pt.x - reg_width/2, pt.y - reg_height/2, reg_width, reg_height];
                        if(rec(1) < 1)
                            rec(1) = 1;
                        end
                        
                        if(rec(2) < 1)
                            rec(2) = 1;
                        end
                        
                        % get a 32 x 32 region
                        img_mag_crop = imcrop(img_mag,rec);
                        img_dir_crop = imcrop(img_dir,rec);
                        img_mask_crop = ones(size(img_mag_crop,1),size(img_mag_crop,2));
                        try
                            % compute LBPHOF/RT Flow
                            [H,L] = ComputeLBPHOF(img_mag_crop,img_dir_crop,img_mask_crop,true); % cropped version of the mask
                            R = ComputeRTransform(img_mag_crop,2,img_mask_crop,true); % entire image mask created from MHI to get shape of MHI
                        catch exception
                            disp(exception);
                            H = zeros(1,size(H_Flow,2));
                            L = zeros(1,size(L_Flow,2));
                            R = zeros(1,size(R_Flow,2));
                        end
                        H_Flow = [H_Flow ; H];
                        L_Flow = [L_Flow ; L];
                        R_Flow = [R_Flow ; R];
                    end
                    
                % End of subsequence frames
                end
                Features_per_subseq{1} = H_Flow;
                Features_per_subseq{2} = L_Flow;
                Features_per_subseq{3} = R_Flow;
                Features_per_set{1,set} = Features_per_subseq;
                fprintf('Features Extracted from the background for Sequence person%d_%s_d%d_uncomp: Subsequence = %d\n',p,action_name,set,subseq_num);
            end
            % removing the unzipped directory for that sequence
            rmdir(features_dir,'s');
            
        % End of Set loop    
        end
        Features_bg{action,p} = Features_per_set;
    % End of action loop    Features_per_set
    end

% End of person loop
end

save('BackgroundFeatures_Corners.mat','Features_bg');










