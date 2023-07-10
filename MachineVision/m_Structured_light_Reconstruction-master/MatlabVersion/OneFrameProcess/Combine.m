tmp_proMat = CalibMat.pro * [CalibMat.rot, CalibMat.trans];
x_match_res = zeros(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH);
for frm_idx = 2:40
    fid = fopen(['pc_multi', num2str(frm_idx), '.txt'], 'w+');
    for pvec_idx = 1:ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH
        h_pro = ProInfo.coord_trans(pvec_idx,1);
        w_pro = ProInfo.coord_trans(pvec_idx,2);
        A = EpiLine.lineA(h_pro,w_pro);
        B = EpiLine.lineB(h_pro,w_pro);
        M = ParaSet.M(pvec_idx,:);
        D = ParaSet.D(pvec_idx,:);
        depth = depth_fine_vecs{frm_idx,1}(pvec_idx);
        
        x_cam = (M(1)*depth+D(1)) / (M(3)*depth+D(3));
        y_cam = -A/B * x_cam + 1/B;
        x_pro = (w_pro-1)*ProInfo.pix_size + ProInfo.range_mat(1,1) - 1;
        
        tmp_vec = [(x_cam - CalibMat.cam(1,3)) / CalibMat.cam(1,1); ...
            (y_cam - CalibMat.cam(2,3)) / CalibMat.cam(2,2); ...
            1];
        Cam_M = (tmp_proMat(:,1:3)*tmp_vec)';
        Cam_D = tmp_proMat(:,4)';

        z_wrd = -(Cam_D(1)-Cam_D(3)*x_pro) / (Cam_M(1)-Cam_M(3)*x_pro);
        x_wrd = (x_cam - CalibMat.cam(1,3)) / CalibMat.cam(1,1) * z_wrd;
        y_wrd = (y_cam - CalibMat.cam(2,3)) / CalibMat.cam(2,2) * z_wrd;

        fprintf(fid, '%.4f %.4f %.4f\n', x_wrd, y_wrd, z_wrd);
    end
    fclose(fid);
end
figure(2), imshow(x_match_res,[711, 911]);
