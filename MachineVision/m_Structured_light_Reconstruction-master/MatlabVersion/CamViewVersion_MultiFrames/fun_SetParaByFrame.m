function [C_set] = fun_SetParaByFrame(depth_vec, ...
    CamInfo, ...
    ParaSet)
% Fill color & sigma parameter from t-1 information

    % Set output parameters
    C_set = zeros(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH,3);

    for cvec_idx = 1:CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH
        depth = depth_vec(cvec_idx);
        M = ParaSet.M(cvec_idx,:);
        D = ParaSet.D(cvec_idx,:);

        C_set(cvec_idx,:) = M*depth + D;
    end

end
