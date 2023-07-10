function [output] = inner_product_forward(input, layer, param)

%% Input:
% input.batch_size: batch_size of input
% input.height: height of input
% input.width : width of input
% input.data: the actual data of input
% input.data is of size (input.height*input.width*input.channel, input.batch_size)
% layer.num: output dimension of this layer

% param.w: weight parameter of this layer, is of size 
% (input.height*input.width*input.channel, layer.num) * input.channel = 50,
% layer.num = 500
% param.b: bias parameter of this layer, is of size (1, layer.num);

%% Output
% output: the output of inner_product_forward


%% The inner product forward propagation
% Set the shape of output
output.height = 1;
output.width = 1;
output.channel = layer.num;
batch=input.batch_size;
output.batch_size = batch;

% Sanity check
d = size(input.data, 1);
assert(size(param.w, 1) == d, 'dimension mismatch in inner_product layer');

% Initialize the outupt data
output.data = zeros(layer.num, batch);

output.data= (param.w)'*(input.data)+repmat((param.b)',1,batch);
    

end
