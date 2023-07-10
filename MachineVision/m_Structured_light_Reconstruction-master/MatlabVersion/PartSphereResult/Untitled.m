iteration_times = zeros(19,1);
for frm_idx = 2:20
    for idx = 1:100
        if error_value(frm_idx,idx) == 0
            iteration_times(frm_idx-1) = idx;
            break;
        end
    end
end