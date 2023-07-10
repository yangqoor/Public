function X_out = sae_ff_nn_decoder(st,data_a)
%Decoder part of the trained auto-encoder

num_images = size(data_a,1);

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

