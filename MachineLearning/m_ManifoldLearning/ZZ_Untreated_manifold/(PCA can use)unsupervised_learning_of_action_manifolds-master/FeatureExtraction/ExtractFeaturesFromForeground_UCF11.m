%%% ReadGTData_UCF11.m : Reading the grounth truth data from VIPER GT
%%% By Binu M Nair

%% Setup up Viper GT in matlab
import javax.xml.parsers.*;
javaaddpath('/home/prci/Setups/viper-light/viper-gt.jar');
docBuilder = DocumentBuilderFactory.newInstance();
docBuilder.setNamespaceAware(true);

%%
% path of the dataset and features
path_video = '/home/prci/RemoteHDD/Datasets/UCF11/UCF11_edited';
path_features = '/home/prci/RemoteHDD/Datasets/UCF11/UCF11_edited/Features';
path_descriptors = '/home/prci/RemoteHDD/Datasets/UCF11/UCF11_edited/Descriptors';
num_of_bins = 16;

set_of_classes = {'basketball';'biking';'diving';'golf_swing';'horse_riding';'soccer_juggling';'swing';'tennis_swing';'trampoline_jumping';'volleyball_spiking';'walking'};
num_of_actions = length(set_of_classes);

% create the folder to store the descriptors
try
    mkdir(path_descriptors)
catch exception
    disp(exception)
end

% Iterate through each action class
for action = 9%1:1:num_of_actions
    
    % initialize the count for each action
    filecount_per_action = 192;
    
    % path to read the video file from
    path_per_action = sprintf('%s/%s',path_video,set_of_classes{action});
    
    % path to read features from 
    path_features_per_action = sprintf('%s/%s',path_features,set_of_classes{action});
    
    % path to store the descriptors to 
    path_descriptors_per_action = sprintf('%s/%s',path_descriptors,set_of_classes{action});
    try
        mkdir(path_descriptors_per_action)
    catch exception
        disp(exception)
    end

    % path to read the annotations
    path_gt_per_action = sprintf('%s/Annotation',path_per_action);
    
    % get the set of video files
    listing = dir(fullfile(path_per_action,'/v_*'));
    
    % iterating through each sequence
    for seq_num = 90:1:length(listing)
        try
            % get the corresponding video file
            video_file = listing(seq_num).name;
            
            % Read the video file
            full_video_file = sprintf('%s/%s',path_per_action,video_file);
            objVideo = VideoReader(full_video_file);
            img_data = read(objVideo);
            
            % sequence name
            seq_name = video_file(1:end-4);
            
            % get the tar file
            features_tar = sprintf('%s/%s.tar.gz',path_features_per_action,seq_name);
            
            % getting the directory which contains the optical flow vectors for an action 'm' and for a single sequence
            path_features_per_action_per_seq = sprintf('%s/%s',path_features_per_action,seq_name);
            
            % create the directory containing optical flow features
            try
                tid = tic;
                untar(features_tar,path_features_per_action);
                el_time = toc(tid);
                fprintf('%s untarred in %f secs\n',seq_name,el_time);
            catch exception
                disp(exception)
                continue;
            end
            
            % filename for viper gt data
            gt_filename = sprintf('%s/%s.xgtf',path_gt_per_action,seq_name);
            
            try
                % Read the VIPER GT data
                docElement = docBuilder.newDocumentBuilder().parse(gt_filename).getDocumentElement();
                parser = viper.api.impl.ViperParser;
                objviper = parser.parseDoc(docElement);
            catch exception
                disp(exception);
                rmdir(path_features_per_action_per_seq,'s');
                continue;
            end
            
            % always selecting the first person
            %p = 1; % for basketball , select the person 2
            num_persons = objviper.getChild(1).getChild(0).getNumberOfChildren - 1;
            
            for p = 1:1:num_persons
                str = char(objviper.getChild(1).getChild(0).getChild(p).getAttribute('Location').toString);
                
                % Get the bounding boxes
                bound_box = parseStr(str);
                
                % read each frame of the video
                numFrames = objVideo.NumberOfFrames;
                nRows = size(bound_box,1);
                
                n = min(numFrames,nRows);
                
                % initializing the descriptors for each person and each video
                % sequence
                L_Flow = [];
                H_Flow = [];
                R_Flow = [];
                
                tid2 = tic;
                % here the processing needs to go on.
                for k = 2:1:n
                    
                    % play image with bounding box
                    img = img_data(:,:,:,k);
                    img = imresize(img,0.5);
                    
                    %                 figure(1);
                    %                 imshow(img);
                    b_box = bound_box(k,:);
                    %                 rectangle('Position',b_box,'EdgeColor', 'r', 'LineWidth', 3);
                    
                    % Load optical flow magnitude and direction
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
                    
                    % resize the images
                    img_mag = imresize(img_mag,0.5);
                    img_dir = imresize(img_dir,0.5);
                    
                    % initialize the mask
                    img_mask = ones(size(img_mag,1),size(img_mag,2));
                    
                    % cropping the magnitude and direction and mask
                    img_mag = imcrop(img_mag,b_box);
                    img_dir = imcrop(img_dir,b_box);
                    img_mask_crop = imcrop(img_mask,b_box);
                    
                    % compute the descriptors
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
                    
                    % end of frame(k) loop
                end
                el_time2 = toc(tid2);
                Features_per_action_per_seq{1} = H_Flow;
                Features_per_action_per_seq{2} = L_Flow;
                Features_per_action_per_seq{3} = R_Flow;
                
                %Features{action,filecount_per_action} = Features_per_action_per_seq;
                descriptor_file_name = sprintf('%s/%s_p%d.mat',path_descriptors_per_action,seq_name,p);
                save(descriptor_file_name,'Features_per_action_per_seq')
                
                fprintf('Features Extracted for action %s from sequence %s.avi of person %d in time %f secs\n',set_of_classes{action},seq_name,p,el_time2);
                
                filecount_per_action = filecount_per_action + 1;
                
            end
        catch exception
            disp(exception);
            continue;
        end
        
        % delete the untarred directory
        % removing the unzipped directory for that sequence
        rmdir(path_features_per_action_per_seq,'s');
        
    end
    
    % save the Features of the action class
    %Features_per_action = Features(action,:);
    %mat_file_name = sprintf('Features_%s_action.mat',set_of_classes{action});
    %save(mat_file_name,Features_per_action);
    
    % clear the features
    %Features = {};
end


