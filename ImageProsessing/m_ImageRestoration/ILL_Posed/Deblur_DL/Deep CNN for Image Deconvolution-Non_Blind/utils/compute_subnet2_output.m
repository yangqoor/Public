function output = compute_subnet2_output(inputs)
    global config mem;
    
    for m = 1:config.batch_size_sec
        for n = 1:config.chs_sec
            mem.IN1_sec((n-1)*config.kernal_size_sec(1, 1)*config.kernal_size_sec(1, 2)+1:n*config.kernal_size_sec(1, 1)*config.kernal_size_sec(1, 2), ...
                        (m-1)*(size(mem.IN1_sec, 2)/config.batch_size_sec)+1:m*size(mem.IN1_sec, 2)/config.batch_size_sec) = ...
                    im2col_gpu(inputs(:,:,n,m), [config.kernal_size_sec(1, 1), config.kernal_size_sec(1, 2)]);
                    %im2col(inputs(:,:,n,m), [config.kernal_size_sec(1, 1), config.kernal_size_sec(1, 2)], 'sliding');
                    
        end
    end
    
    A1 = sigmoid(bsxfun(@plus, config.weights.C1_sec * mem.IN1_sec, config.weights.bc1_sec));    
    A2 = sigmoid(bsxfun(@plus, config.weights.C2_sec * A1, config.weights.bc2_sec));
    A3 = bsxfun(@plus, config.weights.C3_sec * A2, config.weights.bc3_sec);
    for m = 1:config.final_output_chs
        section = A3((m-1)*config.kernal_size_sec(2, 1)*config.kernal_size_sec(2, 2)+1:m*config.kernal_size_sec(2, 1)*config.kernal_size_sec(2, 2), :);
        mem.output_sec(:,:,m) = reshape(accumarray(config.misc.accu_idx_sec(:), section(:)), config.output_row, config.output_col);
    end    
    output = bsxfun(@times, mem.output_sec, config.average_weights);
end

