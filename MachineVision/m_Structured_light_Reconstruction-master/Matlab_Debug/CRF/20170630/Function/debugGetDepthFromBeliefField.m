function depth_mats = debugGetDepthFromBeliefField(total_field, ...
    gt_depth_mats, ...
    viewportMatrix, ...
    para)

    [CAMERA_HEIGHT, CAMERA_WIDTH] = size(total_field{1});
    depth_mats = cell(size(total_field));

    for t = 1:4
        depth_mats{t} = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)

                if h == 700 && w == 400
                    fprintf('');
                end

                [~, max_idx] = max(total_field{t}{h, w});
                delta_depth = (max_idx - para.halfVoxelRange - 1) * para.voxelSize;
                depth_mats{t}(h, w) = delta_depth + gt_depth_mats{t}(h, w);
%                 if t == 1
%                     depth_mats{t}(h, w) = delta_depth + start_depth_mat(h, w);
%                 else
%                     depth_mats{t}(h, w) = delta_depth + depth_mats{t-1}(h, w);
%                 end
            end
        end
    end
end
