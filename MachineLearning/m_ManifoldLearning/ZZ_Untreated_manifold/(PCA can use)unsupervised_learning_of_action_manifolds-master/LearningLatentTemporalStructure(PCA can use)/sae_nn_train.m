function st = sae_nn_train(st,X,opts,flag_seq)
% This function takes in a pre-trained stacked auotencoder to fine tuning
% the training
% The batch size will take in features from 1/4th of the total number of
% sequences taken in random order
% similar to backprop script file provided by Hinton

% We are going to apply the a congugate gradient minimization technique
% repeatedly for new batches of data

% getting the number of frames per sequence
if(flag_seq)
    Size = cumsum(opts.seq_size);
    numbatches = length(opts.seq_size); % number of sequences
    %num_of_seqs_batch = 10; % 10 sequences taken at a time with roughly 40 batches
    %num_of_seqs_batch = min(10,floor(length(Size)/4)); % either taken 10 sequences at a time or 1/4th the sequences at a time
    num_of_seqs_batch = floor(length(Size)/4);
else
    num_images = size(X,1);
    numbatches = num_images / opts.batch_size; % total number of mini-batches
    num_of_seqs_batch = 10; % number of mini-batches per batch
end

% for each epoch
for k = 1:1:opts.numepochs
    
    if(flag_seq)
        % create a different ordering in which the sequence 
        seq_num = randperm(numbatches);
    else
        seq_num = randperm(num_images);
    end
    
    %%%%% COMPUTE TRAIN RE-CONSTRUCTION ERROR %%%%%
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
        data = x_batch;
        
        [dataout,a_out] = sae_nn_ff(st,data);
        
        err_sum= err_sum +  1/(size(x_batch,1))*sum(sum( (data-dataout).^2 )); 
    end
    fprintf('Error before iteration %d = %f\n',k,err_sum/numbatches);
    % TODO: Code to check when err_sum reduces to a very small value and
    % then terminate
        
    % make bigger batchs : number of batches is increased 10 times for
    % MNIST datasets
    for tt = 1:1:floor(numbatches/num_of_seqs_batch)
        x_batch = [];
        if(flag_seq)
            for l = 1:1:num_of_seqs_batch
                seq_idx = seq_num((tt-1)*num_of_seqs_batch + l);
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
                x_batch = [x_batch ; X(start_idx:end_idx,:)];
            end
        else
            x_batch = X(seq_num((tt - 1) * opts.batch_size * num_of_seqs_batch + 1 : tt * opts.batch_size * num_of_seqs_batch), :); % bigger batch
        end
    
        data = x_batch;

        %%%%%%%%%%%%%%% PERFORM CONJUGATE GRADIENT WITH 3 LINESEARCHES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Similar to Hinton's code %%%%%
        max_iter=3;
        VV = [];
        for ll = 1:1:2*numel(st.rbm)
            w = st.W{ll}'; % same format as Hinton's code
            VV = [VV w(:)'];
        end
        VV = VV';
        Dim = st.backprop_size;


        [VV, fX] = minimize(VV,'congugateGradientAutoEncoder',max_iter,Dim,data);

        offset = 0;
        for ll = 1:1:2*numel(st.rbm)
            w = reshape(VV(offset + 1: offset + (Dim(ll)+1)*Dim(ll+1)),Dim(ll)+1,Dim(ll+1));
            offset = offset + (Dim(ll)+1)*Dim(ll+1);
            st.W{ll} = w'; % same format as Hinton's code
        end
    
    end
        
end



end

