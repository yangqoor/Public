function [f,df] = congugateGradientRegularNN(VV,Dim,XX,target)
% This is same as the CG_MNIST provided by Hinton but has more flexibility
% in the number of layers for autoencoder

% get the number of images in the batch
num_images = size(XX,1);
num_rbms = length(Dim)-1;

% get back the original weights
offset = 0;
for ll = 1:1:length(Dim)-1
    w = reshape(VV(offset + 1: offset + (Dim(ll)+1)*Dim(ll+1)),Dim(ll)+1,Dim(ll+1));
    offset = offset + (Dim(ll)+1)*Dim(ll+1);
    W{ll} = w'; % same format as Hinton's code
end

XX_next = XX;
w_probs = cell(num_rbms,1);

% sigmoid activation function 
for u = 1:1:num_rbms-1
    data = [XX_next ones(num_images,1)];
    if(u ~= 1)
        w_probs{u-1} = data;
    end
    w = W{u}'; % getting the layer u weights
    
    % obtaining the output of layer u
    data_a = 1./(1 + exp(-1*(data*w)));
    
    % serving as input to next layer
    XX_next = data_a;
end

% last layer of encoder which is linear ( for function Approximator)
data = [XX_next ones(num_images,1)];
w_probs{num_rbms-1} = data;
w = W{num_rbms}';
data_a = data*w;
a_out = data_a;

% To compute the objective function for a function approximator ; a_out -
% target


% compute the objective function for stacked auto-encoder
%f = -1/num_images*sum(sum( XX.*log(XXout) + (1-XX).*log(1-XXout)));

% compute the derivates of the weights
IO = 1/num_images*(XXout-XX); % absolute error between reconstructed data and original data
df = [];
Ix_last = IO;
for u = length(Dim)-1:-1:1
    if(u ~= length(Dim)-1)
        w = W{u+1}';
        if(u == (length(Dim)-1)/2) % referring to the linear layer
            Ix_last = (Ix_last*w');
        else
            Ix_last = (Ix_last*w').*w_probs{u}.*(1-w_probs{u});
        end
        Ix_last = Ix_last(:,1:end-1);
    end
    if(u ~= 1)
        dw = w_probs{u-1}'*Ix_last;
    else
        dw = w_probs{2*num_rbms}'*Ix_last;
    end
    df = [dw(:)' df];
end
df = df';


