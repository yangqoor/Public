fid_res = fopen([FilePath.output_file_name, num2str(frm_idx), '.txt'], 'w+');
for pvec_idx = 1:ProInfo.R_HEIGHT*ProInfo.R_WIDTH
    h_pro = ProInfo.coord_trans(pvec_idx,1);
    w_pro = ProInfo.coord_trans(pvec_idx,2);
    x_pro = (w_pro-1)*3 + ProInfo.range_mat(1,1) - 1;
    y_pro = (h_pro-1)*3 + ProInfo.range_mat(2,1) - 1;

    z_wrd = depth_fine_vecs{frm_idx,1}(pvec_idx);
    x_wrd = (x_pro - CalibMat.pro(1,3)) / CalibMat.pro(1,1) * z_wrd;
    y_wrd = (y_pro - CalibMat.pro(2,3)) / CalibMat.pro(2,2) * z_wrd;
    fprintf(fid_res, '%.2f %.2f %.2f \n', x_wrd, y_wrd, z_wrd);
end
fclose(fid_res);
