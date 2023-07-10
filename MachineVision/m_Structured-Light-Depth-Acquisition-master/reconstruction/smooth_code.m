function output_uv = smooth_code(uv_seq)
    [width,height,~] = size(uv_seq);
    output_uv = zeros(width, height,2);
    
    gau_win = gausswin(9)/sum(gausswin(9));
    
    % smooth u in vertical direction
    for i=1:height
        output_uv(:,i,1) = conv(uv_seq(:,i,1),gau_win,'same');
    end
    
    % smooth v in horizontal direction
    for j=1:width
        output_uv(j,:,2) = conv(uv_seq(j,:,2),gau_win, 'same');
    end
    
end