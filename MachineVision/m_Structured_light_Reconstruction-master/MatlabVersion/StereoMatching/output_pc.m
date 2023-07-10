% error_thred = 1e5;
% final_depth_img = zeros(CamInfo.HEIGHT, CamInfo.WIDTH);
% fid_res = fopen([FilePath.output_file_name, '.txt'], 'w+');
% for h = 1:CamInfo.HEIGHT
%   for w = 1:CamInfo.WIDTH
%     match_error = error_mat(h, w);
%     z_wrd = depth_mat(h, w);
%     if (match_error < error_thred) && (z_wrd > 45) && (z_wrd < 52)
%       x_wrd = ((w-1) - CalibMat.cam_0(1,3)) / CalibMat.cam_0(1,1) * z_wrd;
%       y_wrd = ((h-1) - CalibMat.cam_0(2,3)) / CalibMat.cam_0(2,2) * z_wrd;
%       fprintf(fid_res, '%.3f %.3f %.3f\n', x_wrd, y_wrd, z_wrd);
%       final_depth_img(h, w) = z_wrd;
%     end
%   end
% end
% fclose(fid_res);
% 
fid = fopen('EpiLine_B.txt', 'w+');
for h = 1:CamInfo.HEIGHT
  for w = 1:CamInfo.WIDTH
    fprintf(fid, '%f ', EpiLine.lineB(h, w));
  end
  fprintf(fid, '\n');
end
fclose(fid);
