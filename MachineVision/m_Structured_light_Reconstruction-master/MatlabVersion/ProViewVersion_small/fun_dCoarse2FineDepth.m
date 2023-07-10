function [depth_coarse_vec] = fun_dCoarse2FineDepth(d_depth_coarse_vec, ...
    depth_fine_vec, ...
    ProInfo)

    depth_coarse_vec = zeros(size(depth_fine_vec));
    for pvec_idx = 1:ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH
        h_pro = ProInfo.coord_trans(pvec_idx,1);
        w_pro = ProInfo.coord_trans(pvec_idx,2);
        h_c_pro = ceil(h_pro/ProInfo.win_size);
        w_c_pro = ceil(w_pro/ProInfo.win_size);
        cpvec_idx = (h_c_pro-1)*ProInfo.RANGE_C_WIDTH + w_c_pro;
        depth_coarse_vec(pvec_idx,1) = ...
            d_depth_coarse_vec(cpvec_idx,1) ...
            + depth_fine_vec(pvec_idx,1);
    end

end
