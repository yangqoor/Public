function psf=resizePSF(psf,ret,n1,n2)
    psf=imresize(psf,ret);
    psf=max(psf,0);
    psf=fixsize(psf,n1,n2);
    if max(psf(:))>0
        psf=psf/sum(psf(:));
    end
end