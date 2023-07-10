function error_value = fun_ErrorFunction(image_vec, ...
    projected_vec, ...
    last_image_vec, ...
    last_projected_vec, ...
    valid_index, ...
    last_depth_vec, ...
    delta_depth_vec, ...
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
    % data_vec = (projected_vec - image_vec.*valid_vec);
    data_vec = ((projected_vec-last_projected_vec) - (image_vec-last_image_vec));
    data_value = sum(data_vec.^2);

    % Regular Term
    regular_vec = ParaSet.gradOpt * (last_depth_vec + delta_depth_vec);
    regular_value = sum(regular_vec.^2);

    error_value = data_value + theta * regular_value;
end
