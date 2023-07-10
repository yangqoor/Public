img_path = 'E:/Structured_Light_Data/20171104/StatueRotation_part/dyna/';
pc_path = 'E:/Structured_Light_Data/20171104_/StatueRotation_part/';
output_name = 'output ';
pc_range = [372,595; 161,395];
total_frame = 40;
image_size = [400, 300];

for frm_idx = 1:total_frame-1
    pc_img = imread([pc_path, 'pc (', num2str(frm_idx), ').png']);
    cam_img = imread([img_path, 'dyna_mat', num2str(frm_idx), '.png']);
    pc_part_img = pc_img(pc_range(2,1):pc_range(2,2), ...
        pc_range(1,1):pc_range(1,2));
    rs_cam = imresize(cam_img, [400, 600]);
    rs_pc = imresize(pc_part_img, [400,400]);
    imwrite([rs_cam, rs_pc], [output_name, num2str(frm_idx), '.png']);
end
