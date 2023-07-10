function norm_derv_vec = fun_ErrorFunctionDerv(image_vec, ...
    projected_vec, ...
    last_image_vec, ...
    last_projected_vec, ...
    valid_index, ...
    last_depth_vec, ...
    delta_depth_vec, ...
    projected_derv_vecmat, ...
    theta, ...
    ParaSet)
% Calculate E

    % Parameters set
    valid_vec = zeros(size(valid_index,1), 1);
    for i = 1:size(valid_index,1)
        if size(valid_index{i,1},1) > 0
            valid_vec(i,1) = 1;
        end
    end

    % Data Term
    minus_vec = (projected_vec - image_vec);
    % minus_vec = ((projected_vec-last_projected_vec) - (image_vec-last_image_vec));
    data_derv = 2 * (minus_vec' * projected_derv_vecmat)';
    norm_data_derv = data_derv / norm(data_derv, 2);

    % Regular Term
    regular_vec = ParaSet.gradOpt * (last_depth_vec + delta_depth_vec);
    regular_derv = ParaSet.gradOpt * regular_vec;
    norm_regular_derv = regular_derv / norm(regular_derv, 2);

    derv_vec = norm_data_derv + theta * norm_regular_derv;
    norm_derv_vec = derv_vec / norm(derv_vec);
end
