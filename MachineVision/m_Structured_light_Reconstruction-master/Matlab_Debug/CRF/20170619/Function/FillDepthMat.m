function [depth_mat, valid_mask] = FillDepthMat(x_mat, ...
    y_mat, ...
    viewportMatrix)
    depth_mat = zeros(size(x_mat));
    valid_mask = zeros(size(x_mat));
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            x_p = x_mat(h, w);
            y_p = y_mat(h, w);
            if (x_p > 0) && (y_p > 0)
                depth_mat(h, w) = xpro2depth(w, h, x_p);
                valid_mask(h, w) = 1;
            else
                valid_mask(h, w) = 0;
            end
        end 
    end

end

