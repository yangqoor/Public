function [param_grad, input_od] = inner_product_backward(output, input, layer, param)

%% Input
% output.data: output data of inner_product_forward
% output.diff: the gradient w.r.t otuput.data

%input dxbatch
%output nxbatch
%output.diff nxbatch

%% Output
% param_grad.w: gradient w.r.t param.w
% param_grad.b: gradient w.r.t param.b
% input_od: gradient w.r.t input.data

%% The inner product backward propagation

% Initialize the gradient w.r.t param
param_grad.w = zeros(size(param.w)); % gradient w.r.t param.w
param_grad.b = zeros(size(param.b)); % gradient w.r.t param.b
batch=input.batch_size;


input_od = zeros(size(input.data)); % is of size (h*w*c,batch_size);

param_grad.w=input.data*((output.diff)'); 

param_grad.b=ones(1,batch)*(output.diff)';

input_od =(param.w)*output.diff;
    

end
