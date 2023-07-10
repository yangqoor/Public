% function to test a set of samples in batchs
function [X_test_out,a_test,err_sum] = sae_test(st,X_test,opts,flag_seq)
    err_sum = 0;

    if(flag_seq) % this section will probably change for testing sequences
        Size = cumsum(opts.seq_size);
        numbatches = length(opts.seq_size); % number of sequences
    else
        num_images = size(X_test,1);
        numbatches = num_images / opts.batch_size; % total number of mini-batches
    end
    
    if(flag_seq)
        % create a different ordering in which the sequence 
        seq_num = randperm(numbatches);
    else
        seq_num = randperm(num_images);
    end
    a_test = [];
    X_test_out = [];
    for l = 1:1:numbatches
        if(flag_seq)
            seq_idx = seq_num(l);
            start_idx = Size(seq_idx-1) + 1;
            end_idx = Size(seq_idx);

            % getting the features for a sequence
            x_batch = X_test(start_idx:end_idx,:);
        else
            x_batch = X_test(seq_num((l - 1) * opts.batch_size + 1 : l * opts.batch_size), :);
        end
        data = x_batch;
        
        [dataout,a_out] = sae_nn_ff(st,data);
        a_test = [a_test ; a_out];
        X_test_out = [X_test_out ; dataout];
        
        err_sum= err_sum +  1/(size(x_batch,1))*sum(sum( (data-dataout).^2 )); 
        
        % displaying the images
        fprintf(1,'Displaying in figure 1: Top row - real data, Bottom row -- reconstructions \n');
        output=[];
         for ii=1:15
          output = [output data(ii,:)' dataout(ii,:)'];
         end
         if l==1 
            close all 
            figure('Position',[100,600,1000,200]);
         else 
            figure(1)
         end
        mnistdisp(output);
        drawnow;
    end
    err_sum = err_sum /numbatches;
end