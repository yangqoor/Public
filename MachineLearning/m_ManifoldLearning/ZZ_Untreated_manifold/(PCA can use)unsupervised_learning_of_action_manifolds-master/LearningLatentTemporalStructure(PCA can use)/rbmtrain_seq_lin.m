% this function is to train an rbm with a set of features computed for a
% set of sequences.
% each batch here would then correspond to the set of features from a
% single sequence
% the set of sequences are combined and can be indexed using the
% opts.batch_size
function rbm = rbmtrain_seq_lin(rbm,X,opts,flag_seq)

rand('state',0);
% set of commands taken from the original rbmtrain in toolbox
assert(isfloat(X), 'x must be a float');
assert(all(X(:)>=0) && all(X(:)<=1), 'all data in x must be in [0:1]');

if(flag_seq) % training for a sequence
    % getting the number of frames per sequence
    Size = cumsum(opts.seq_size);
    numbatches = length(opts.seq_size);
else
    num_images = size(X,1);
    numbatches = num_images / opts.batch_size;
end
    
% for each epoch
err_graph = zeros(opts.numepochs,1);

% for each epoch
for k = 1:1:opts.numepochs

    if(flag_seq)
        % create a different ordering in which the sequence 
        seq_num = randperm(numbatches);
    else
        seq_num = randperm(num_images);
    end
    
    err_sum = 0;
    for l = 1:1:numbatches
        if(flag_seq)
            seq_idx = seq_num(l);
            if(seq_idx == 1)
                start_idx = 1;
                end_idx = Size(seq_idx);
            else
                start_idx = Size(seq_idx-1) + 1;
                end_idx = Size(seq_idx);
            end
            % check for empty sequences
            if(start_idx-1 == end_idx)
                continue;
            end
            
            % getting the features for a sequence
            x_batch = X(start_idx:end_idx,:);
        else
            x_batch = X(seq_num((l - 1) * opts.batch_size + 1 : l * opts.batch_size), :);
        end

        %%%%% POSITIVE PHASE
        v0 = x_batch;
        num_images_per_batch = size(x_batch,1);
        num_hid = size(rbm.bh,1);
        
        % compute the conditional probability that P(H_j = 1| v) for the
        % per-frame features of each sequence
        prob_Hj_V_pos = v0 * rbm.W' + repmat(rbm.bh',num_images_per_batch,1);
        
        % <V_i*H_j> sampled from P(H|V)P(V)
        Vi_Hj_pos = (v0' * prob_Hj_V_pos)'; 
        
        % H_j sampled from P(H|V)P(V)
        Hj_pos = (sum(prob_Hj_V_pos))'; 
        
        % V_i sampled from P(V)
        Vi_pos = (sum(v0))';
        
        % computing the hidden states
        pos_Hj_states = prob_Hj_V_pos + randn(num_images_per_batch,num_hid);
        
        % equivalent command 
        %h0 = sigmrnd(repmat(rbm.c', opts.batchsize, 1) + v1 * rbm.W');
        
        %%%%% NEGATIVE PHASE
        v1 = 1./(1 + exp( -1 * (pos_Hj_states * rbm.W + repmat(rbm.bv',num_images_per_batch,1))));
        % compute P(H_j = 1|v) for negative phase
        prob_Hj_V_neg = v1 * rbm.W' + repmat(rbm.bh',num_images_per_batch,1);
        
        % <V_i*H_j> for negative phase
        Vi_Hj_neg = (v1' * prob_Hj_V_neg)';
        
        % H_j sampled from P(V,H)
        Hj_neg = (sum(prob_Hj_V_neg))';
        
        % V_j sampled from negative phase
        Vi_neg = (sum(v1))';
        
        % compute the error between the original data and the reconstructed
        % data
        err_1 = sum( sum((v0 - v1).^2))/num_images_per_batch; 
        err_sum = err_sum + err_1;   
        
        %%%% UDPATE RULE for weights and biases
        rbm.del_W = rbm.momentum * rbm.del_W + rbm.epsilon_w * ( (Vi_Hj_pos - Vi_Hj_neg)/num_images_per_batch - rbm.weightcost* rbm.W );
        rbm.del_bh = rbm.momentum * rbm.del_bh + (rbm.epsilon_vc/num_images_per_batch) * (Hj_pos - Hj_neg);
        rbm.del_bv = rbm.momentum * rbm.del_bv + (rbm.epsilon_vb/num_images_per_batch) * (Vi_pos - Vi_neg);

        rbm.W = rbm.W + rbm.del_W;
        rbm.bh = rbm.bh + rbm.del_bh;
        rbm.bv = rbm.bv + rbm.del_bv;
                
        %fprintf('Epoch %d - Batch - %d ; Error = %f\n',k,l,err_1);
    end
    
    err_graph(k) = err_sum;
    fprintf('Error at iteration %d = %f\n',k,err_sum/numbatches);
    
end





end

