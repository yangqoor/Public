function [C_set] = fun_SetParaByFrame(depth_vec, ...
    ProInfo, ...
    ParaSet)
% Fill color & sigma parameter from t-1 information

    % Set output parameters
    C_set = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH,3);

    for pvec_idx = 1:ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH
        depth = depth_vec(pvec_idx);
        M = ParaSet.M(pvec_idx,:);
        D = ParaSet.D(pvec_idx,:);
        C_set(pvec_idx,:) = M*depth + D;
    end

end
