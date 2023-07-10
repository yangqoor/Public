function [param_grad, input_od] = conv_layer_backward(output, input, layer, param)
% conv layer backward
h_in = input.height;
w_in = input.width;
c = input.channel;
batch_size = input.batch_size;
k = layer.k;
group = layer.group;
num = layer.num;

h_out = output.height;
w_out = output.width;
input_n.height = h_in;
input_n.width = w_in;
input_n.channel = c;
input_od = zeros(size(input.data));
param_grad.b = zeros(size(param.b));
param_grad.w = zeros(size(param.w));

for n = 1:batch_size
    input_n.data = input.data(:, n);
    col = im2col_conv(input_n, layer, h_out, w_out);
    col = reshape(col, k*k*c, h_out*w_out);
    col_diff = zeros(size(col));
    temp_data_diff = reshape(output.diff(:, n), [h_out*w_out, num]);
    for g = 1:group
        g_c_idx = (g-1)*k*k*c/group + 1: g*k*k*c/group;
        g_num_idx = (g-1)*num/group + 1 : g*num/group;
        col_g = col(g_c_idx, :);
        weight = param.w(:, g_num_idx);
        % get the gradient of param
        param_grad.b(:, g_num_idx) = param_grad.b(:, g_num_idx) + sum(temp_data_diff(:, g_num_idx));
        param_grad.w(:, g_num_idx) = param_grad.w(:, g_num_idx) + col_g*temp_data_diff(:, g_num_idx);
        col_diff(g_c_idx, :) = weight*temp_data_diff(:, g_num_idx)';
    end
    im = col2im_conv(col_diff(:), input, layer, h_out, w_out);
    % set the gradient w.r.t to input.data
    input_od(:, n) = im(:);
end
end