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
Features = {};
num_of_bins = 16;

set_of_classes = {'basketball';'biking';'diving';'golf_swing';'horse_riding';'soccer_juggling';'swing';'tennis_swing';'trampoline_jumping';'volleyball_spiking';'walking'};
num_of_actions = length(set_of_classes);

% Iterate through each action class
for action = 3:1:num_of_actions
    
    % path to read the video file from
    path_per_action = sprintf('%s/%s',path_video,set_of_classes{action});
    
    % path to read features from 
    path_features_per_action = sprintf('%s/%s',path_features,set_of_classes{action});

    % path to read the annotations
    path_gt_per_action = sprintf('%s/Annotation',path_per_action);
    
    % get the set of video files
    listing = dir(fullfile(path_per_action,'/v_*'));
    
    % iterating through each sequence
    for seq_num = 1:1:length(listing)
        
        % get the corresponding video file
        video_file = listing(seq_num).name;
        
        % Read the video file
        full_video_file = sprintf('%s/%s',path_per_action,video_file);
        objVideo = VideoReader(full_video_file);
        img_data = read(objVideo);
        
        % sequence name
        seq_name = video_file(1:end-4);
        
        % filename for viper gt data
        gt_filename = sprintf('%s/%s.xgtf',path_gt_per_action,seq_name);
        
        % Read the VIPER GT data
        docElement = docBuilder.newDocumentBuilder().parse(gt_filename).getDocumentElement();
        parser = viper.api.impl.ViperParser;
        objviper = parser.parseDoc(docElement);
        
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

            % here the processing needs to go on.
            for fr = 1:1:n
                img = img_data(:,:,:,fr);
                img = imresize(img,0.5);
                figure(1);
                imshow(img);

                b_box = bound_box(fr,:);
                %b_box = [b_box(2) b_box(1) b_box(3) b_box(4)];

                rectangle('Position',b_box,'EdgeColor', 'r', 'LineWidth', 3);

            end
        
        end
        
    end
    
    
end


