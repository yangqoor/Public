
function filts = compute_filter_weights(I,filts,a)

if (nargin == 2)
    a = 0.8;
end

[h w c] = size(I);

min_err = 0.003;

for i=1:length(filts)
    
    G = filts(i).G;
    G_flip = fliplr(flipud(G));

    Igray = mean(I,3);
    IG = imconv(Igray,G,'same');
    
    % sparse prior weight
    weights = max(abs(IG),min_err).^(a-2);  

    filts(i).W = sparse(1:h*w, 1:h*w, weights(:), h*w, h*w);    
    
end