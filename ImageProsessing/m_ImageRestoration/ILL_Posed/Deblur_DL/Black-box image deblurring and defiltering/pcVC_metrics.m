function [TM, E, psnrs, ssims, mses, brisques, niqes, piqes] = pcVC_metrics(F, y, xref, options)
% Phase corrected Van-Cittert iterations 
% Keep track of metrics

options.null = 0;
maxiter = getoptions(options, 'maxiter', 100);
show_denoised = getoptions(options, 'show_denoised', 0);

TM = y;

E = [];
e = img_norm(y - F(TM));
E = [E; e];

if show_denoised == 1
    TMd = denoise(TM);
    
    psnrs = [];
    curr_psnr = psnr(TMd, xref);
    psnrs = [psnrs; curr_psnr];
    
    ssims = [];
    curr_ssim = ssim(TMd, xref);
    ssims = [ssims; curr_ssim];
    
    mses = [];
    curr_mse = immse(TMd, xref);
    mses = [mses; curr_mse];
    
    brisques = [];
    curr_brisque = brisque(TMd);
    brisques = [brisques; curr_brisque];
    
    niqes = [];
    curr_niqe = niqe(TMd);
    niqes = [niqes; curr_niqe];
    
    piqes = [];
    curr_piqe = piqe(TMd);
    piqes = [piqes; curr_piqe];
else
    psnrs = [];
    curr_psnr = psnr(TM, xref);
    psnrs = [psnrs; curr_psnr];
    
    ssims = [];
    curr_ssim = ssim(TM, xref);
    ssims = [ssims; curr_ssim];
    
    mses = [];
    curr_mse = immse(TM, xref);
    mses = [mses; curr_mse];
    
    brisques = [];
    curr_brisque = brisque(TM);
    brisques = [brisques; curr_brisque];
    
    niqes = [];
    curr_niqe = niqe(TM);
    niqes = [niqes; curr_niqe];
    
    piqes = [];
    curr_piqe = piqe(TM);
    piqes = [piqes; curr_piqe]; 
end


for i=1:maxiter
    H = fft2(F(TM))./(fft2(TM)+eps);
    TM = TM + real(ifft2((fft2(y)./(H+eps)-fft2(TM)).*abs(H)));
    
    e = img_norm(y - F(TM));
    E = [E; e];
    
    if show_denoised == 1
        TMd = denoise(TM);
        
        curr_psnr = psnr(TMd, xref);
        psnrs = [psnrs; curr_psnr];
        
        curr_ssim = ssim(TMd, xref);
        ssims = [ssims; curr_ssim];
        
        curr_mse = immse(TMd, xref);
        mses = [mses; curr_mse];
        
        curr_brisque = brisque(TMd);
        brisques = [brisques; curr_brisque];
        
        curr_niqe = niqe(TMd);
        niqes = [niqes; curr_niqe];
        
        curr_piqe = piqe(TMd);
        piqes = [piqes; curr_piqe]; 
    else
        curr_psnr = psnr(TM, xref);
        psnrs = [psnrs; curr_psnr];
        
        curr_ssim = ssim(TM, xref);
        ssims = [ssims; curr_ssim];
        
        curr_mse = immse(TM, xref);
        mses = [mses; curr_mse];
        
        curr_brisque = brisque(TM);
        brisques = [brisques; curr_brisque];
        
        curr_niqe = niqe(TM);
        niqes = [niqes; curr_niqe];
        
        curr_piqe = piqe(TM);
        piqes = [piqes; curr_piqe];   
    end
    
end

end

