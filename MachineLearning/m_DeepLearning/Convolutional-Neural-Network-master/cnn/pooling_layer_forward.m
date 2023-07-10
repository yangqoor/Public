function [output] = pooling_layer_forward(input, layer)

%% Input:
% input.batch_size: batch_size of input
% input.height: height of input
% input.width : width of input
% input.data: the actual data of input
% input.data is of size (input.height*input.width*input.channel, input.batch_size)

% layer.k: kernel size of pooling operation
% layers.stride: stride of pooling operation
% layers.pad: pad of pooling operation


%% Output
% output: the output of inner_product_forward, with either MAX or AVERAGE
% methods

% Dimensions of the output shape
h_in = input.height;
w_in = input.width;
c = input.channel; 
batch= input.batch_size;
k = layer.k;
layer.pad = 0;
pad = layer.pad;
s = layer.stride;

h_out = (h_in + 2*pad - k) / s + 1;
w_out = (w_in + 2*pad - k) / s + 1;
assert(h_out == floor(h_out), 'h_out is not integer')
assert(w_out == floor(w_out), 'w_out is not integer')

% Set output shape
output.height = h_out;
output.width = w_out;
output.channel = c;
output.batch_size = batch;

switch layer.act_type
    case 'MAX'
        input_re = reshape(input.data, h_in, w_in, c, batch);
        output_temp = zeros(h_out,w_out,c,batch);
        for i = 1:h_out
            for j = 1:w_out
                output_temp(i,j,:,:) = max(max(input_re(s*(i-1)+1:s*(i-1)+k,s*(j-1)+1:s*(j-1)+k,:,:)));
            end
        end
        output.data= reshape(output_temp,h_out*w_out*c,batch);

        
        
    case 'AVE'
        input_re = reshape(input.data, h_in, w_in, c, batch);
        output_temp = zeros(h_out,w_out,c,batch);
        for i = 1:h_out
            for j = 1:w_out
                output_temp(i,j,:,:) = mean(mean(input_re(s*(i-1)+1:s*(i-1)+k,s*(j-1)+1:s*(j-1)+k,:,:)));
            end
        end
        output.data= reshape(output_temp,h_out*w_out*c,batch);        
end

end

