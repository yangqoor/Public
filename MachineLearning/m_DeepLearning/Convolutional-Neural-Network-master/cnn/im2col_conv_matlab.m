function col = im2col_conv(input_n, layer, h_out, w_out)

%% Input
% input.height: height of input
% input.width : width of input
% input.channel: channel of input

% layer.k
% layer.pad
% layer.stride

%% Output
% the input in a 1D vector

%% Dimensions
h_in = input_n.height;
w_in = input_n.width;
c = input_n.channel;
k = layer.k;
pad = layer.pad;
stride = layer.stride;

im = reshape(input_n.data, [h_in, w_in, c]);
assert(pad == 0, 'pad must be 0');
% im = padarray(im, [pad, pad], 0);
col = zeros(k*k*c, h_out*w_out);
for h = 1:h_out
    for w = 1:w_out
        matrix_hw = im((h-1)*stride + 1 : (h-1)*stride + k, (w-1)*stride + 1 : (w-1)*stride + k, :);
        col(:, h + (w-1)*h_out) = matrix_hw(:);
    end
end
col = col(:);
end