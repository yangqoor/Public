function beliefField = FillInitialBeliefField(cameraImage, ...
    mask_mat, ...
    pattern, ...
    last_depth_mat, ...
    lineA, ...
    lineB, ...
    lineC, ...
    viewportMatrix, ...
    norm_sigma_u, ...
    voxelSize, ...
    halfVoxelRange)

    [CAMERA_HEIGHT, CAMERA_WIDTH] = size(cameraImage);
    beliefField = cell(CAMERA_HEIGHT, CAMERA_WIDTH);
    % beliefField = zeros(CAMERA_HEIGHT, CAMERA_WIDTH, halfVoxelRange * 2 + 1);

    % For every point in the QField
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
%             if mask_mat(h, w) == 0
%                 continue;
%             end
            beliefField{h, w} = zeros(halfVoxelRange * 2 + 1, 1);
            
            if h == 700 && w == 400
                fprintf('');
            end

%             x_p = depth2xpro(w, h, now_depth_mat(h, w));
%             y_p = xpro2ypro(w, h, x_p, lineA, lineB, lineC);
%             c_xy = GetColorByXYpro(x_p, y_p, pattern);
            c_xy = cameraImage(h, w);

            for d_idx = 1:halfVoxelRange * 2 + 1
                % Calculate depth value
                delta_depth = (d_idx - halfVoxelRange - 1) * voxelSize;
                depth = last_depth_mat(h, w) + delta_depth;
                % Get xpro, ypro from depth
                xpro = depth2xpro(w, h, depth);
                ypro = xpro2ypro(w, h, xpro, lineA, lineB, lineC);
                % Get color information
                p_xy = GetColorByXYpro(xpro, ypro, pattern);
                alpha = color_alpha(c_xy, p_xy);
                % alpha = 1 - abs(p_xy - c_xy);
                beliefField{h, w}(d_idx) = exp(- max(alpha, Phi_u(delta_depth, norm_sigma_u)));
            end
            % Normalize
            sum_value = sum(beliefField{h, w});
            if sum_value == 0
                % Problem: F20, h=316, w=441
                disp(h, w)
            end
            beliefField{h, w} = beliefField{h, w} / sum_value;
        end
        if mod(h, 40) == 0
            fprintf('x');
        end
    end
    fprintf('\n');

end
