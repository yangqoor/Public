% parameters
alpha = 2;
beta = 2;
theta = 1;
lambda = 5;
C_fine = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH,3);
for pvec_idx = 1:ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH
    M = ParaSet.M(pvec_idx,:);
    D = ParaSet.D(pvec_idx,:);
    depth = depth_fine_vecs{frm_idx-1,1}(pvec_idx);
    C_fine(pvec_idx,:) = M*depth + D;
end

% Set d_depth
d_depth_coarse_vecs{frm_idx,1} = zeros(ProInfo.RANGE_C_HEIGHT*ProInfo.RANGE_C_WIDTH,1);
frm_sta = frm_idx-1;
if frm_sta < start_frame
    frm_sta = start_frame;
end
frm_end = frm_idx;
