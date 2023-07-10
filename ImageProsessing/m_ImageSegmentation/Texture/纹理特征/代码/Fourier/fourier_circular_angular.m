function [ assin ] = fourier_circular_angular(I)
% input:image
% output:fourier descriptors
assin=[];
[M,N]=size(I);
IF=abs(fftshift(fft2(I)));
[r,f]=sep_angulares(M,4);
for ang=0:7
    [mi,mf,ni,nf]=quadrante(ang,M,N);
    mini=IF(mi:mf,ni:nf);
    minir=r(mi:mf,ni:nf);
    minif=f(mi:mf,ni:nf);
    for freq_radial=[3 6 9 12 15 18 21 24];
        minir_=minir<=freq_radial;
        minif_=minif==rem(ang,2);
        final=and(minir_,minif_);
        assin=[assin,sum(mini(find(final)))];
    end
end
end


end

