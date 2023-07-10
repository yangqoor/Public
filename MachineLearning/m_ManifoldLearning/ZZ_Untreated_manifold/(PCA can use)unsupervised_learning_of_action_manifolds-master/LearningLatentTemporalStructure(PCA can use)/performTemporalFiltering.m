function X_filtered = performTemporalFiltering(X,win_size)
% This function does the temporal filtering of a sequence X ( num_frames x
% dim) using a window size 'win_size'
% Here, we can use 'win_size' to be 5 frames and scan the whole sequence
% using this window. We compute the median values across each dimension in
% in a temporal window.
% 
% Written by Binu M Nair. Copyright.

num_frames = size(X,1);
num_dims = size(X,2);

num_wins = num_frames - win_size + 1; % ignoring first win_size-1 frames
X_filtered = zeros(num_wins,num_dims);
for k = win_size:1:num_frames
    X_temp = X(k:-1:k-win_size+1,:);
   
    % computing the median
    med_X = median(X_temp);
    
    X_filtered(k-win_size+1,:) = med_X;
end




end

