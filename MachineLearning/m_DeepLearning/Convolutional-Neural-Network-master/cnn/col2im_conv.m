function im = col2im_conv(col, input, layer, h_out, w_out)
h_in = input.height;
w_in = input.width;
c = input.channel;
k = layer.k;
pad = layer.pad;
stride = layer.stride;

% im = col2im_conv_c(col, h_in, w_in, c, k, pad, stride, h_out, w_out);
im = col2im_conv_matlab(col, input, layer, h_out, w_out);
end