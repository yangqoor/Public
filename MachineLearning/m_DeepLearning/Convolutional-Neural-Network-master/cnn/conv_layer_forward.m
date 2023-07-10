function [output] = conv_layer_forward(input, layer, param)
% conv layer forward

h_in = input.height;
w_in = input.width;
c = input.channel;
batch_size = input.batch_size;
k = layer.k;
pad = layer.pad;
stride = layer.stride;
group = layer.group;
num = layer.num;
% resolve output shape
h_out = (h_in + 2*pad - k) / stride + 1;
w_out = (w_in + 2*pad - k) / stride + 1;

assert(h_out == floor(h_out), 'h_out is not integer')
assert(w_out == floor(w_out), 'w_out is not integer')
assert(mod(c, group) == 0, 'c is not multiple of group')
assert(mod(num, group) == 0, 'c is not multiple of group');
input_n.height = h_in;
input_n.width = w_in;
input_n.channel = c;

% iterate over batches
for n = 1:batch_size
    input_n.data = input.data(:, n);
    % reshape the input feature to [k*k*c, h_out*w_out]
    % for ease of processing
    col = im2col_conv(input_n, layer, h_out, w_out);
    col = reshape(col, k*k*c, h_out*w_out);
    for g = 1:group
        col_g = col((g-1)*k*k*c/group + 1: g*k*k*c/group, :);
        weigth = param.w(:, (g-1)*num/group + 1 : g*num/group);
        b = param.b(:, (g-1)*num/group + 1 : g*num/group);
        % inner product
        tempoutput(:, (g-1)*num/group + 1 : g*num/group) = bsxfun(@plus, col_g'*weigth, b);
    end
    output.data(:, n) = tempoutput(:);
    clear tempoutput;
end

% set output shape
output.height = h_out;
output.width = w_out;
output.channel = num;
output.batch_size = batch_size;
end

