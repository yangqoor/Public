function [input_od] = relu_backward(output, input, layer)

%% Input
% output.data: output data of relu_forward
% output.diff: gradient w.r.t output.data

%% Output
% input_od: gradient w.r.t input.data

%% Initialize
input_od = zeros(size(input.data));

input_od = output.diff.*(input.data>0);

end
