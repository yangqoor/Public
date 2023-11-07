function Ax = filter_responces_for_cg_kernelEst(K,filts)

[h w] = size(K);

Ax = zeros(h,w);

for i=1:length(filts)
    
    % compute A'Ax for filters
    G = filts(i).G;
    G_flip = fliplr(flipud(G));

    % apply weights
    lamdba = filts(i).lambda;
    W = filts(i).W; 
    
    AG = W.*imconv(K,G,'same');          
    AG = imconv(AG,G_flip,'same');         
    
    Ax = Ax + lamdba*AG;
end