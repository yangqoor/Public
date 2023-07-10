function col = im2col_conv(input_n, layer, h_out, w_out)
% h_in = input_n.height;
% w_in = input_n.width;
% c = input_n.channel;
% k = layer.k;
% pad = layer.pad;
% stride = layer.stride;

% col = im2col_conv_c(input_n.data, h_in, w_in, c, k, pad, stride, h_out, w_out);
% col = im2col_conv_c(input_n.data, input_n.height, input_n.width, input_n.channel,...
%     layer.k, layer.pad, layer.stride, h_out, w_out);
col = im2col_conv_matlab(input_n, layer, h_out, w_out);
end