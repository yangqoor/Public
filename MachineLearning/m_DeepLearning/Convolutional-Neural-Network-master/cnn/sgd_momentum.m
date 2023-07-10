function [params, param_winc] = sgd_momentum(rate, mu, weight_decay, params, param_winc, param_grad)
% update the parameter with sgd with momentum

%% function input
% rate: learning rate at current step, /alpha
% mu: momentum, /mu
% weight_decay: weigth decay of w, 
% params: original weight parameter, old w
% param_winc: buffer to store history gradient accumulation, old\theta
% param_grad: gradient of parameter,

%% function output
% params: updated parameters, new w
% param_winc: updated buffer, new \theta

%params_winc.w=zeros(size(params_grad.w));
%params_winc.b=zeros(size(params_grad.b));

for i=1:length(params)
    param_winc{i}.w=mu*param_winc{i}.w+rate*(param_grad{i}.w+weight_decay*params{i}.w);
    param_winc{i}.b=mu*param_winc{i}.b+rate*param_grad{i}.b;
    
    params{i}.w=params{i}.w-param_winc{i}.w;
    params{i}.b=params{i}.b-param_winc{i}.b;
end

end
