function delta_depth_mats = GetDeltaDepthsFromBeliefField(belief_field, ...
    mask_mats, ...
    cal_para, ...
    viewportMatrix)
    
    [LAYER_NUM, ~] = size(belief_field);
    [CAMERA_HEIGHT, CAMERA_WIDTH] = size(belief_field{1, 1});
    
    delta_depth_mats = cell(LAYER_NUM, 1);
    for l = 1:LAYER_NUM
        delta_depth_mats{l, 1} = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                if mask_mats{l, 1}(h, w) == 1
                    [~, max_idx] = max(belief_field{l, 1}{h, w});
                    delta_depth = (max_idx - cal_para.hVoxelRange - 1) * cal_para.voxelSize;
                    delta_depth_mats{l, 1}(h, w) = delta_depth;
                end
            end
        end
    end
    
end
