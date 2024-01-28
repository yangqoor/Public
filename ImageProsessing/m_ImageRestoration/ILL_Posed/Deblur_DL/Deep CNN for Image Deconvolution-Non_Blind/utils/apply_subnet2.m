function output = apply_subnet2(input)
    global config;

    input_size = size(input);
    output = gpuArray(single(zeros(size(input, 1), size(input, 2), config.final_output_chs)));
    p_size = config.MEM.p_size;
    %npatches = config.MEM.npatches;
    size_differ = config.kernal_size_sec(1, 1) - config.kernal_size_sec(2, 1);
    count = zeros(size(input, 1), size(input, 2));
    for v = 1 : length(config.MEM.start_rows)
        for h = 1 : length(config.MEM.start_cols)
            v_start = config.MEM.start_rows(v);
            v_end = v_start + p_size - 1;
            h_start = config.MEM.start_cols(h);
            h_end = h_start + p_size - 1;
            if(v_end > input_size(1))
                v_end = input_size(1);
                v_start = v_end - p_size + 1;
            end
            if(h_end > input_size(2))
                h_end = input_size(2);
                h_start = h_end - p_size + 1;
            end
            input_piece = input(v_start:v_end, h_start:h_end,:);            
            output_piece = compute_subnet2_output(input_piece);            
            
            %config.MEM.output = bsxfun(@times, config.MEM.output, config.MEM.average_weights);
            %config.MEM.output(config.MEM.mask) = 0;
            output(v_start+(size_differ/2):v_end-(size_differ/2), h_start+(size_differ/2):h_end-(size_differ/2),:) = ...
                    output(v_start+(size_differ/2):v_end-(size_differ/2), h_start+(size_differ/2):h_end-(size_differ/2),:) + output_piece;
            count(v_start+(size_differ/2):v_end-(size_differ/2), h_start+(size_differ/2):h_end-(size_differ/2)) = ...
                    count(v_start+(size_differ/2):v_end-(size_differ/2), h_start+(size_differ/2):h_end-(size_differ/2)) + 1;
        end
    end
    count = max(count, 1);
    output = bsxfun(@rdivide, output, count);


end


