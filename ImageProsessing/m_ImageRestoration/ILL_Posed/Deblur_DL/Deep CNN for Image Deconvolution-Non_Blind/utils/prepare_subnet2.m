function prepare_subnet2(input_x, input_y, model)
    global config mem;
    
    if(input_x < input_y)
        smaller_edge = input_x;
    else
        smaller_edge = input_y;
    end

    max_patch_size = 100;

    if(smaller_edge <= max_patch_size)
        p_size = smaller_edge;
    else
        p_size = max_patch_size;
    end
    
    config.input_size_sec = [p_size, p_size];
    config.kernal_size_sec = model.kernal_size_sec;
    config.hidden_size_sec = model.hidden_size_sec;
    config.batch_size_sec = 1;
    config.chs_sec = model.chs_sec;
    config.final_output_chs = model.final_output_chs;
    config.input_mean_sec = model.input_mean_sec;
    config.input_std_sec = model.input_std_sec;
    
    %r_sec = 0.1;
    config.weights.C1_sec = model.weights.C1_sec;
    config.weights.C2_sec = model.weights.C2_sec;
    config.weights.C3_sec = model.weights.C3_sec;
    config.weights.bc1_sec = model.weights.bc1_sec;
    config.weights.bc2_sec = model.weights.bc2_sec;
    config.weights.bc3_sec = model.weights.bc3_sec;
    
    config.output_row = config.input_size_sec(1) - config.kernal_size_sec(1, 1) + 1 + config.kernal_size_sec(2, 1) - 1;
    config.output_col = config.input_size_sec(2) - config.kernal_size_sec(1, 2) + 1 + config.kernal_size_sec(2, 2) - 1;
    mem.IN1_sec = gpuArray(single(zeros(config.kernal_size_sec(1, 1)*config.kernal_size_sec(1, 2)*config.chs_sec, ...
                        (config.input_size_sec(1)-config.kernal_size_sec(1, 1)+1)*(config.input_size_sec(2)-config.kernal_size_sec(1, 2)+1)*config.batch_size_sec)));
    mem.output_sec = gpuArray(single(zeros(config.output_row, config.output_col, config.final_output_chs)));
    mem.dA3_sec = gpuArray(single(zeros(config.kernal_size_sec(2, 1) * config.kernal_size_sec(2, 2) * config.final_output_chs, ...
                        (config.input_size_sec(1)-config.kernal_size_sec(1, 1)+1)*(config.input_size_sec(2)-config.kernal_size_sec(1, 2)+1))));
    
    t = reshape(1:(config.output_row*config.output_col), [config.output_row, config.output_col]);
    config.misc.accu_idx_sec = gpuArray(single(im2col(t, [config.kernal_size_sec(2, 1) config.kernal_size_sec(2, 2)])));
    
    counts = gpuArray(single(ones(config.kernal_size_sec(2, 1)*config.kernal_size_sec(2, 2), (config.input_size_sec(1)-config.kernal_size_sec(1, 1)+1)*(config.input_size_sec(2)-config.kernal_size_sec(1, 2)+1))));
    counts = reshape(accumarray(config.misc.accu_idx_sec(:), counts(:)), config.output_row, config.output_col);
    config.average_weights = 1 ./ counts;

    
    
    npatches = (p_size - config.kernal_size_sec(1, 1) + 1) ^ 2;

    overlap_pixels = 30;
    problem_pixels = 0;
    mask = zeros(p_size - config.kernal_size_sec(2, 1) - problem_pixels);
    mask = padarray(mask, [problem_pixels/2 problem_pixels/2], 1);
    mask = logical(mask);
    mask = repmat(mask, [1 1 6]);
    
    start_rows = [1];
    start_cols = [1];    
    while(1)
        next_start_row = start_rows(length(start_rows)) + p_size - overlap_pixels;
        if(next_start_row + p_size - 1 > input_x)
            next_start_row = input_x - p_size + 1;
            if(next_start_row ~= start_rows(length(start_rows)))
                start_rows = [start_rows next_start_row];
            end
            break;
        else
            start_rows = [start_rows next_start_row];
        end
    end
    
    while(1)
        next_start_col = start_cols(length(start_cols)) + p_size - overlap_pixels;
        if(next_start_col + p_size - 1 > input_y)
            next_start_col = input_y - p_size + 1;
            if(next_start_col ~= start_cols(length(start_cols)))
                start_cols = [start_cols next_start_col];
            end
            break;
        else
            start_cols = [start_cols next_start_col];
        end
    end
    config.MEM.p_size = p_size;
    config.MEM.npatches = npatches;
    config.MEM.start_rows = start_rows;
    config.MEM.start_cols = start_cols;
    config.MEM.mask = mask;
end