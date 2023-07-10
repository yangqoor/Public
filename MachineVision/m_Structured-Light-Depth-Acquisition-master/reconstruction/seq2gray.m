% used to comvert rgb sequence into grayscle format
function output_seq = seq2gray(seq)
    % get size and dimension of input sequence 
    [height, width, ~, dim] = size(seq);
    output_seq = zeros(height, width, dim);
    
    % convert sequence into grayscale format
    for n=1:dim
        output_seq(:,:,n)=rgb2gray(seq(:,:,:,n));
    end
    
end