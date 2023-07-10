function [ delta_depth_mat ] = Intersection( last_delta_depth_mat, mask_mat, viewportMatrix )

    k_nearest = 8;
    delta_depth_mat = last_delta_depth_mat;

    for h = viewportMatrix(2,1):viewportMatrix(2,2)
        for w = viewportMatrix(1,1):viewportMatrix(1,2)
            if mask_mat == 1
                continue;
            end
            point_set = FindNearestPoint(k_nearest, h, w, mask_mat, viewportMatrix);
            point_set_dis = sqrt(point_set(:,1).^2 + point_set(:,2).^2);
            d_max = sum(point_set_dis);
            weighted = (ones(k_nearest, 1) - point_set_dis/d_max).^2;
            weighted = weighted / sum(weighted);
            delta_depth_mat(h, w) = 0;
            for i = 1:k_nearest
                h_idx = point_set(i, 1) + h;
                w_idx = point_set(i, 2) + w;
                delta_depth_mat(h, w) = delta_depth_mat(h, w) + weighted(i, 1) * last_delta_depth_mat(h_idx, w_idx);
            end
        end
        if mod(h, 40) == 0
            fprintf('i');
        end
    end
    fprintf('\n');
end
