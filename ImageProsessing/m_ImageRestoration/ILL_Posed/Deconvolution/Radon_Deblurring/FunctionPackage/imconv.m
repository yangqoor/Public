function B = imconv(I,K,arg)

if (isstruct(K))
    if (strcmp(K.type,'spatiallyvarying'))
        B = imconv_spatially_varying(I,K,arg);
    else
        B = imconv_arbitrary(I,K);
    end
else
    [h w c] = size(I);
    [k1 k2] = size(K);
%     if (h*w*c*k1*k2 > 1e9)
%         B = fftconv(I,K,'same');
%     else
        B = double(imfilter(single(I),K,arg,'replicate','conv'));
%     end
end