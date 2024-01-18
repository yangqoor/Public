
function [DeIm] = NonBlindDeblurring(imOriginal,ker)
%%
[n,m,sz]=size(imOriginal);
DeIm=zeros(n,m,sz);
    % Non Blind Deblurring by Levin et al.
    for s=1:sz
        DeIm(:,:,s)=deconvSps(imOriginal(:,:,s), ker, 0.005, 200);
    end
   
end
