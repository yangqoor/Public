xpro_ori = corres_mat{1, 3}(2, 1);
ypro_ori = corres_mat{1, 3}(1, 1);

template = gene_mat(ypro_ori-2:ypro_ori+2, xpro_ori-2:xpro_ori+2);
result_mat = zeros(5, 5);
for h_srch = -2:2
    for w_srch = -2:2
        xpro_new = xpro_ori + w_srch;
        ypro_new = ypro_ori + h_srch;
        new_tlt = double(camera_image(ypro_new-2:ypro_new+2, xpro_new-2:xpro_new+2));
        result_mat(h_srch+3, w_srch+3) = sum(sum((template - new_tlt).^2));
    end
end

min_val = min(min(result_mat));
[h_val, w_val] = find(result_mat == min_val);
bias_h = h_val - 3;
bias_w = w_val - 3;