% function to quantize direction into bins
function D = QuantizeDirection(img_dir,num_bins)
% size of image
[rows,cols] = size(img_dir);

v_angles = img_dir(:);
B = num_bins; % num of bins
K=max(size(v_angles));

D = zeros(K,1);
for ang_lim=-pi:2*pi/B:pi - 2*pi/B        
    for k=1:K              
        if( (v_angles(k)>ang_lim) && (v_angles(k)<=ang_lim+2*pi/B) )   
            v_angles(k)=100;            
            D(k) = ang_lim + pi/B;          
        end        
    end
end

% organize back into image rows and cols
D = reshape(D,rows,cols);

end