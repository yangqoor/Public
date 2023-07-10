% function used for 3D reconstruction 

% NOTE: this algorithm could run directly for sets whose (u,v) code have
% already stored in 'uv_code' folder without reading extra images, but
% still need the correct folder name

% Input *****************************************************
% folder: folder path of data set to read
% image_name: same prefix of image sequence
% first: first number of first image in sequence
% digit: digit number of image number
% format: image format
% e.g. 'own face': reconstruction3D('own_face','IMG_29',26, 2,'jpg')
% e.g. 'cube_T1': reconstruction3D('cube_T1','',0,4,'jpg')
function reconstruction3D(folder,img_name, first,digit,format)
    
    % load/compute uv code --------------------
    file_name = ['uv_code/',folder,'_uv.mat'];
    if exist(file_name)~=0
        fprintf('Loading (u,v) code...');
        load(file_name);
        fprintf('done\n');
    else
        fprintf('Computing (u,v) code...');
        % if read synthetic set: coded_pix = get_pix_code(folder, img_name, first, digit, format, true, true);
        coded_pix = get_pix_code(folder, img_name, first, digit, format, true, false);
        save(file_name,'coded_pix');
        fprintf('done\n');
    end
    
    % compute 3D point cloud ------------------
    fprintf('Computeing 3D point cloud...');
    [depth_map,point_cloud] = get_depth(coded_pix);
    
    mask = depth_map == -1;
    depth_map = mask.*(max(depth_map(:)))+(1-mask).*depth_map;
   
    figure;
    imagesc(depth_map),title('depth map');
    %saveas(gcf, ['depth_map_',folder,'.jpg']);
    fprintf('done\n');
    
    % save as PLY file -------------------------    
    fprintf('Saving as PLY file...');
    saveas_ply(point_cloud,folder);
    fprintf('done\n');
end