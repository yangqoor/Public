function [output] = relu_forward(input, layer)

%% Input
% input.data: actual input data of relu layer

%% Output
% output: the output of relu_forward function

%% Dimensions of output
output.height = input.height;
output.width = input.width;
output.channel = input.channel;
output.batch_size = input.batch_size;

output.data = (input.data).*(input.data >0);

end
