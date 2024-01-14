function filts = compute_filter_weights_kernelEst(K,filts,a)

if (nargin == 2)
    a = repmat(0.8, [length(filts), 1]);
end
 
min_err = 0.003;

for i=1:length(filts)
    
    G = filts(i).G; 
 
    KG = imconv(K,G,'same');
    
    % sparse prior weight
    weights = max(abs(KG),min_err).^(a(i)-2);  

    filts(i).W = weights;   
end