% minibatch is the data passed into the rbm layer for training.
% This RBM is an RBM dependent on previous time-steps
% flag_gaussian : if set, then use gaussian, other wise Binary
function rbm = crbm_train_layer(rbm,batchdata,batchdata_inds,flag_gaussian)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% finding the number of mini-batches
num_batches = length(batchdata_inds);
num_dims = rbm.num_dims;
num_hid = rbm.num_hid;
nt = rbm.nt; % order of the rbm

w = rbm.w;
A = rbm.A;
B = rbm.B;
bi = rbm.bi;
bj = rbm.bj;

w_update = rbm.w_update;
bi_update = rbm.bi_update;
bj_update = rbm.bj_update;
A_update = rbm.A_update;
B_update = rbm.B_update;
gsd = rbm.gsd;

if(~flag_gaussian)
    gsd = 1;
end

% Entering the iteration/epoch loop
for epoch = 1:1:rbm.num_epochs
    
    % error sum : difference between the input and the reconstructed data
    err_sum = 0;
    
    % iterating through each set of data in the batchdata
    for b_num = 1:1:num_batches
        
        %%%%%%%% START POSITIVE PHASE %%%%%%%%%%%
        num_frames = length(batchdata_inds{b_num}); % get the number of frames in that batch data
        data_inds = batchdata_inds{b_num}; % get the data indices for that batch of data
        
        % Hack to ignore empty matrix indices
        if(isempty(data_inds))
            continue;
        end
        
        % form the corresponding input data
        data = zeros(num_frames,num_dims,nt+1);
        data(:,:,1) = batchdata(data_inds,:); % store the current frames or sub-sequences stored in batchdata_inds
        
        % storing the previous frame features with respect to the current
        % frame
        for hh = 1:1:nt
            data(:,:,hh+1) = batchdata(data_inds-hh,:);
        end
        
        % Compute contributions from directed auto-regressive connections
        % There are the dynamic biases to the visible nodes
        bi_star = zeros(num_dims,num_frames);
        for hh=1:1:nt
            bi_star_per_hh = A(:,:,hh)*data(:,:,hh+1)'; % computing the contribution from t-1(previous frame) to t (current frame) => if hh = 1
            bi_star = bi_star + bi_star_per_hh; % if hh = 2, contribution accumulated from hh = 1 and from t-2 to t-1th frame
        end
        
        % Compute contributions from directed visible-to-hidden connections
        % These are the dynamic biases to the hidden nodes
        bj_star = zeros(num_hid,num_frames);
        for hh = 1:1:nt
            bj_star_per_hh = B(:,:,hh) * data(:,:,hh+1)';
            bj_star = bj_star + bj_star_per_hh;
        end
        
        % compute the posterior probability of the hidden nodes given the
        % visible units :=> using the dynamic basis
        prob_Hj_V_pos = 1./(1 + exp(-1*( w * (data(:,:,1)./gsd)' + repmat(bj,1,num_frames) + bj_star )));
        
        if(~flag_gaussian)
            hid_states = prob_Hj_V_pos' > rand(num_frames,num_hid);
        else
            hid_states = double(prob_Hj_V_pos' > rand(num_frames,num_hid));
        end
        
        % calculate the positive gradients 
        w_grad = hid_states' * (data(:,:,1)./gsd); % SHOULDN'T IT BE THE PROBABILITY PROB_HJ_V_POS. NEED TO TEST WITH THIS.
        bi_grad = sum(data(:,:,1)' - repmat(bi,1,num_frames) - bi_star , 2)./gsd^2;
        bj_grad = sum(hid_states,1)';
        
        for hh = 1:1:nt
            A_grad(:,:,hh) = (data(:,:,1)' - repmat(bi,1,num_frames) - bi_star)./gsd^2 * data(:,:,hh+1);
            B_grad(:,:,hh) = hid_states' * data(:,:,hh+1);
        end
        
        %%%%%%%%%% END OF POSITIVE PHASE : START NEGATIVE PHASE%%%%%%%%%%%%%
        % Find the mean of the Gaussian
        mean_data = gsd.* (hid_states * w); % this is topdown
        neg_data = mean_data + repmat(bi',num_frames,1) + bi_star';
        
        % If Binary CRBM, then neg_data is 1./(1+exp(-neg_data));
        if(~flag_gaussian)
            neg_data = 1./(1 + exp(-neg_data));
        end
        
        % computing the posterior probability of the hidden nodes given the
        % reconstructed visible units
        prob_Hj_V_neg = 1./(1 + exp(-1*( w * (neg_data./gsd)' + repmat(bj,1,num_frames) + bj_star )));
        
        % compute negative gradients
        neg_w_grad = prob_Hj_V_neg * (neg_data./gsd);
        neg_bi_grad = sum(neg_data' - repmat(bi,1,num_frames) - bi_star, 2)./gsd^2;
        neg_bj_grad = sum(prob_Hj_V_neg,2);
        
        for hh = 1:1:nt
            neg_A_grad(:,:,hh) = (neg_data' - repmat(bi,1,num_frames) - bi_star)./gsd^2 * data(:,:,hh+1);
            neg_B_grad(:,:,hh) = prob_Hj_V_neg * data(:,:,hh+1);
        end
        
        %%%%%%%%%%% END NEGATIVE PHASE %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        err = sum( sum( data(:,:,1) - neg_data).^2);
        err_sum = err_sum + err;
        
        if epoch > 5
            momentum = rbm.momentum;
        else
            momentum = 0;
        end
        
        %%%%%%%%% UPDATE WEIGHTS AND BIASES %%%%%%%%%%%%%%%%%
        w_update = momentum * w_update + rbm.epsilon_w* ( (w_grad - neg_w_grad)/num_frames - rbm.w_decay*w);
        bi_update = momentum * bi_update + (rbm.epsilon_bi / num_frames) * (bi_grad - neg_bi_grad);
        bj_update = momentum * bj_update + (rbm.epsilon_bj / num_frames) * (bj_grad - neg_bj_grad);
        
        for hh = 1:1:nt
            A_update(:,:,hh) = momentum * A_update(:,:,hh) + rbm.epsilon_A * ( (A_grad(:,:,hh) - neg_A_grad(:,:,hh))/num_frames - rbm.w_decay * A(:,:,hh));
            B_update(:,:,hh) = momentum * B_update(:,:,hh) + rbm.epsilon_B * ( (B_grad(:,:,hh) - neg_B_grad(:,:,hh))/num_frames - rbm.w_decay * B(:,:,hh));
        end
        
        w = w + w_update;
        bi = bi + bi_update;
        bj = bj + bj_update;
        
        for hh = 1:1:nt
            A(:,:,hh) = A(:,:,hh) + A_update(:,:,hh);
            B(:,:,hh) = B(:,:,hh) + B_update(:,:,hh);
        end
        
        %%%%%%% END OF UPDATES %%%%%%%%%%
        
    end
    
     %every 10 epochs, show output
     if mod(epoch,10) ==0
         fprintf(1, 'epoch %4i error %6.1f  \n', epoch, err_sum); 
         %Could see a plot of the weights every 10 epochs
         %figure(3); weightreport
         %drawnow;
     end

end

% set back the weights
rbm.w = w;
rbm.bi = bi;
rbm.bj = bj;
rbm.A = A;
rbm.B = B;

end

