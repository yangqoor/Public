function [W, E, psnrs, ssims, mses, brisques, niqes, piqes] = mW_metrics(F, y, xref, options)
% modified Wiener iterations
% Keep track of metrics

% default value for 'a' from the image noise variance
if (size(y,3) ~= 1)
    ybw = rgb2gray(y);
    nsr = estimate_noise(ybw)^2 / var(ybw(:));
else
    nsr = estimate_noise(y)^2 / var(y(:));
end
a_def = nsr;

options.null = 0;
maxiter = getoptions(options, 'maxiter', 100);
a = getoptions(options, 'a', a_def);
show_denoised = getoptions(options, 'show_denoised', 0);

W = y;
FW = F(W);
H = fft2(FW)./(fft2(W)+eps);

E = [];
e = img_norm(y - FW);
E = [E; e];

if show_denoised == 1
    Wd = denoise(W);
    
    psnrs = [];
    curr_psnr = psnr(Wd, xref);
    psnrs = [psnrs; curr_psnr];
    
    ssims = [];
    curr_ssim = ssim(Wd, xref);
    ssims = [ssims; curr_ssim];
    
    mses = [];
    curr_mse = immse(Wd, xref);
    mses = [mses; curr_mse];
    
    brisques = [];
    curr_brisque = brisque(Wd);
    brisques = [brisques; curr_brisque];
    
    niqes = [];
    curr_niqe = niqe(Wd);
    niqes = [niqes; curr_niqe];
    
    piqes = [];
    curr_piqe = piqe(Wd);
    piqes = [piqes; curr_piqe];
else
    psnrs = [];
    curr_psnr = psnr(W, xref);
    psnrs = [psnrs; curr_psnr];
    
    ssims = [];
    curr_ssim = ssim(W, xref);
    ssims = [ssims; curr_ssim];
    
    mses = [];
    curr_mse = immse(W, xref);
    mses = [mses; curr_mse];
    
    brisques = [];
    curr_brisque = brisque(W);
    brisques = [brisques; curr_brisque];
    
    niqes = [];
    curr_niqe = niqe(W);
    niqes = [niqes; curr_niqe];
    
    piqes = [];
    curr_piqe = piqe(W);
    piqes = [piqes; curr_piqe];
end

for i=1:maxiter
    H = H*(i-1)/i + fft2(FW)./(fft2(W)+eps)/i;
    Hconj = conj(H);
    W = real(ifft2((Hconj./(Hconj.*H+a)).*fft2(y)));
    FW = F(W);
    
    e = img_norm(y - FW);
    E = [E; e];
    
    if show_denoised == 1
        Wd = denoise(W);
        
        curr_psnr = psnr(Wd, xref);
        psnrs = [psnrs; curr_psnr];
        
        curr_ssim = ssim(Wd, xref);
        ssims = [ssims; curr_ssim];
        
        curr_mse = immse(Wd, xref);
        mses = [mses; curr_mse];
        
        curr_brisque = brisque(Wd);
        brisques = [brisques; curr_brisque];
        
        curr_niqe = niqe(Wd);
        niqes = [niqes; curr_niqe];
        
        curr_piqe = piqe(Wd);
        piqes = [piqes; curr_piqe];
    else
        curr_psnr = psnr(W, xref);
        psnrs = [psnrs; curr_psnr];
        
        curr_ssim = ssim(W, xref);
        ssims = [ssims; curr_ssim];
        
        curr_mse = immse(W, xref);
        mses = [mses; curr_mse];
        
        curr_brisque = brisque(W);
        brisques = [brisques; curr_brisque];
        
        curr_niqe = niqe(W);
        niqes = [niqes; curr_niqe];
        
        curr_piqe = piqe(W);
        piqes = [piqes; curr_piqe];
    end
    
end

end

