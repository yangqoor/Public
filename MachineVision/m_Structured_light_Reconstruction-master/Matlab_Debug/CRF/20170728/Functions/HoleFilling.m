function [ Result_mat ] = HoleFilling( raw_mat, ...
    half_search_size, ...
    viewportMatrix)
    
    Result_mat = raw_mat;
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            if (raw_mat(h, w) <= 0)
                sum_value = 0;
                sum_num = 0;
                for h_n = -half_search_size:half_search_size
                    for w_n = -half_search_size:half_search_size
                        if h + h_n >= viewportMatrix(2, 1) ...
                                && h + h_n <= viewportMatrix(2, 2) ...
                                && w + w_n >= viewportMatrix(1, 1) ...
                                && w + w_n <= viewportMatrix(1, 2)
                            if raw_mat(h + h_n, w + w_n) > 0
                                sum_value = sum_value + raw_mat(h + h_n, w + w_n);
                                sum_num = sum_num + 1;
                            end
                        end
                    end
                end
                Result_mat(h, w) = sum_value / sum_num;
            end
        end
    end

end

