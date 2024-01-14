function Ax = filter_responces_for_cg(x,filts)

[h w c] = size(x);

Ax = zeros(h,w,c);

for i=1:length(filts)
    
    % compute A'Ax for filters
    G = filts(i).G;
    G_flip = fliplr(flipud(G));

    % apply weights
    lamdba = filts(i).lambda;
    W = filts(i).W;
    W = reshape(full(diag(W)), [h w]);
    W = repmat(W,[1 1 c]);
    
    AG = W.*imconv(x,G,'same');          
    AG = imconv(AG,G_flip,'same');         
    
    Ax = Ax + lamdba*AG;
end