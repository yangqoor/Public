function im = col2im_conv(col, input, layer, h_out, w_out)
h_in = input.height;
w_in = input.width;
c = input.channel;
k = layer.k;
pad = layer.pad;
stride = layer.stride;

im = zeros(h_in, w_in, c);
assert(pad == 0, 'pad must be 0');
% im = padarray(im, [pad, pad], 0);
col = reshape(col, [k*k*c, h_out*w_out]);
for h = 1:h_out
    for w = 1:w_out
        im((h-1)*stride + 1 : (h-1)*stride + k, (w-1)*stride + 1 : (w-1)*stride + k, :) ...
            = im((h-1)*stride + 1 : (h-1)*stride + k, (w-1)*stride + 1 : (w-1)*stride + k, :) + ...
            reshape(col(:, h + (w-1)*h_out), [k, k, c]);
    end
end
im = im(pad+1:end-pad, pad+1:end-pad, :);
end