fid_res = fopen([FilePath.output_file_name, num2str(frm_idx), '.txt'], 'w+');
for h_cam = 1:CamInfo.R_HEIGHT
    for w_cam = 1:CamInfo.R_WIDTH
        cvec_idx = (h_cam-1)*CamInfo.R_WIDTH + w_cam;
        x_pro = x_pro_mats{frm_idx,1}(h_cam,w_cam);
        if x_pro == 0
            continue;
        end
        M = ParaSet.M(cvec_idx,:);
        D = ParaSet.D(cvec_idx,:);
        x_cam = w_cam + CamInfo.range_mat(1,1) - 1;
        y_cam = h_cam + CamInfo.range_mat(2,1) - 1;
        
        z_wrd = -(D(1)-D(3)*x_pro) / (M(1)-M(3)*x_pro);
        x_wrd = (x_cam - CalibMat.cam(1,3)) / CalibMat.cam(1,1) * z_wrd;
        y_wrd = (y_cam - CalibMat.cam(2,3)) / CalibMat.cam(2,2) * z_wrd;
        
        fprintf(fid_res, '%.3f %.3f %.3f\n', x_wrd, y_wrd, z_wrd);
    end
end
fclose(fid_res);
