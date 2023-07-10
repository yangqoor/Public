CalibMat.cam_0 = [ 2432.058972474525, 0, 762.2933947666461;
  0, 2435.900798664577, 353.2790048217345;
  0, 0, 1];

for frm_idx = 27:29
  depth_mat = load(['depth_mat', num2str(frm_idx), '.txt']);
  error_mat = load(['error_mat', num2str(frm_idx), '.txt']);
  
  
  new_depth_mat = zeros(size(depth_mat));
  fid_res = fopen(['pc', num2str(frm_idx), '.txt'], 'w+');
  min_val = 40;
  max_val = 55;
  for h = 1:1024
    for w = 1:1280
      if error_mat(h, w) < 6
        z_wrd = depth_mat(h, w);
        if (z_wrd < 40) || (z_wrd > 55)
          continue;
        end
        new_depth_mat(h, w) = z_wrd;
        x_wrd = ((w-1) - CalibMat.cam_0(1,3)) / CalibMat.cam_0(1,1) * z_wrd;
        y_wrd = ((h-1) - CalibMat.cam_0(2,3)) / CalibMat.cam_0(2,2) * z_wrd;
        fprintf(fid_res, '%.3f %.3f %.3f\n', x_wrd, y_wrd, z_wrd);
      end
    end
  end
  fclose(fid_res);
  output_mat = (new_depth_mat - min_val) / (max_val - min_val);
  imwrite(output_mat, ['depth_mat', num2str(frm_idx), '.png']);
  fprintf('.');
end
fprintf('\n');