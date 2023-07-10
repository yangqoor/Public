function t_mat = t_alpha(time_num, norm_sigma_t)

%     t_mat = zeros(time_num, time_num);
%     for h = 1:time_num
%         for w = 1:time_num
%             t_mat(h, w) = exp( - (h - w)^2 / 2*norm_sigma_t^2);
%         end
%     end
    t_mat = eye(time_num);
end

