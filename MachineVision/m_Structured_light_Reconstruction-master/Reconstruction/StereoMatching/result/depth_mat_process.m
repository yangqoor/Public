file_path_0 = 'E:/Structured_Light_Data/20171125/StatueMRC_2/cam_0/dyna/';
file_path_1 = 'E:/Structured_Light_Data/20171125/StatueMRC_2/cam_1/dyna/';
range_mat = [52, 221; 472, 710];

for frm_idx = 0:26
  cam_mat_0 = imread([file_path_0, 'dyna_mat', num2str(frm_idx), '.png']);
  cam_mat_1 = imread([file_path_1, 'dyna_mat', num2str(frm_idx), '.png']);
  depth_mat = imread(['depth_mat', num2str(frm_idx), '.png']);
  point_mat = imread(['pc (', num2str(frm_idx+1), ').png']);
  pc_mat = point_mat(range_mat(1,1):range_mat(2,1), range_mat(1,2):range_mat(2,2));
  
  lu_mat = imresize(double(cam_mat_0) / 255, [512, 640]);
  ru_mat = imresize(double(cam_mat_1) / 255, [512, 640]);
  ld_mat = imresize(double(depth_mat) / 255, [512, 640]);
  rd_mat = imresize(double(pc_mat) / 255, [512, 640]);
  final_mat = [lu_mat, ru_mat; ld_mat, rd_mat];
  % imshow(final_mat);
  
  [X, map] = gray2ind(final_mat, 256);
  imshow(X, map);
  if frm_idx == 0
    imwrite(X, map, 'show.gif', 'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
  else
    imwrite(X, map, 'show.gif', 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
  end
end