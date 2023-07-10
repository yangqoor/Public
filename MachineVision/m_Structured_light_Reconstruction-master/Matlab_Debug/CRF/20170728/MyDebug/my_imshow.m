function [  ] = my_imshow( show_mat, viewportMatrix, norm, mask_mat )
    if norm
        [mask_mat_h, mask_mat_w] = size(mask_mat);
        if mask_mat_h == 0 && mask_mat_w == 0
            imshow(show_mat(viewportMatrix(2,1):viewportMatrix(2,2), viewportMatrix(1,1):viewportMatrix(1,2)), []);
        else
            max_val = 0;
            min_val = Inf;
            for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
                for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                    if mask_mat(h, w) == 1
                        if max_val < show_mat(h, w)
                            max_val = show_mat(h, w);
                        end
                        if min_val > show_mat(h, w)
                            min_val = show_mat(h, w);
                        end
                    end
                end
            end
            imshow(show_mat(viewportMatrix(2,1):viewportMatrix(2,2), viewportMatrix(1,1):viewportMatrix(1,2)), [min_val, max_val]);
        end
    else
        imshow(show_mat(viewportMatrix(2,1):viewportMatrix(2,2), viewportMatrix(1,1):viewportMatrix(1,2)));
    end
end

