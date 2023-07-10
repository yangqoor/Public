function lr_t = get_lr(iter, epsilon, gamma, power)
%% input
% iter: number of iteratin
% epsilon: initial rate
% gamma: decaying param
% power: decaying param

%% Output
% the learning rate at a function of iter

%%
    lr_t=epsilon./((1+gamma.*iter).^power);

end
