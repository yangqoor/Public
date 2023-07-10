function [new_depth_vecs] = fun_SetNewDepthFromStep(depth_vecs, ...
    alpha, ...
    norm_derv_vecs)
% Set depth_vecs according to derv value

    flow_size = size(depth_vecs,1);
    new_depth_vecs = cell(flow_size,1);

    for flw_idx = 1:flow_size
        new_depth_vecs{flw_idx,1} = depth_vecs{flw_idx,1} ...
            - alpha * norm_derv_vecs{flw_idx,1};
    end

end
