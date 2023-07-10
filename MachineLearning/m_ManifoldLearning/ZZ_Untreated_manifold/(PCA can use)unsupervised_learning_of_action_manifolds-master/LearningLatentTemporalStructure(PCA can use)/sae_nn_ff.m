function [X_out,a_out] = sae_nn_ff(st,X)
% This function gets a set of inputs X computed the reconstructed output
% X_out and its internal latent representation

num_images = size(X,1);

%%% Encoder part %%%%
X_next = X;

% sigmoid activation function 
for u = 1:1:numel(st.rbm)-1
    data = [X_next ones(num_images,1)];
    w = st.W{u}'; % getting the layer u weights
    
    % obtaining the output of layer u
    data_a = 1./(1 + exp(-1*(data*w)));
    
    % serving as input to next layer
    X_next = data_a;
    
end

% last layer of encoder which is linear
data = [X_next ones(num_images,1)];
w = st.W{numel(st.rbm)}';
data_a = data*w;
a_out = data_a;

%%%% Decoder part %%%%
X_next = data_a;
for u = numel(st.rbm)+1:1:2*numel(st.rbm)
    data = [X_next ones(num_images,1)];
    w = st.W{u}'; % getting the layer u weights
    
    % obtaining the output of layer u
    data_a = 1./(1 + exp(-1*(data*w)));
    
    % serving as input to next layer
    X_next = data_a;
end

% feeding out the reconstructed data
X_out = X_next;

end

