function [lm, E, psnrs, ssims, mses, brisques, niqes, piqes] = mLM_metrics(F, y, xref, options)
% Levenberg-Marquardt iterations
% Keep track of metrics

% default value for 'a' from the image noise variance
if (size(y,3) ~= 1)
    ybw = rgb2gray(y);
    nsr = estimate_noise(ybw)^2 / var(ybw(:));
else
    nsr = estimate_noise(y)^2 / var(y(:));
end
a_def = 100.0 * nsr;

options.null = 0;
maxiter = getoptions(options, 'maxiter', 100);
a = getoptions(options, 'a', a_def);
show_denoised = getoptions(options, 'show_denoised', 0);

lm = y;

E = [];
e = img_norm(y - F(lm));
E = [E; e];

if show_denoised == 1
    lmd = denoise(lm);
    psnrs = [];
    curr_psnr = psnr(lmd, xref);
    psnrs = [psnrs; curr_psnr];
    
    ssims = [];
    curr_ssim = ssim(lmd, xref);
    ssims = [ssims; curr_ssim];
    
    mses = [];
    curr_mse = immse(lmd, xref);
    mses = [mses; curr_mse];
    
    brisques = [];
    curr_brisque = brisque(lmd);
    brisques = [brisques; curr_brisque];
    
    niqes = [];
    curr_niqe = niqe(lmd);
    niqes = [niqes; curr_niqe];
    
    piqes = [];
    curr_piqe = piqe(lmd);
    piqes = [piqes; curr_piqe];
else
    psnrs = [];
    curr_psnr = psnr(lm, xref);
    psnrs = [psnrs; curr_psnr];
    
    ssims = [];
    curr_ssim = ssim(lm, xref);
    ssims = [ssims; curr_ssim];
    
    mses = [];
    curr_mse = immse(lm, xref);
    mses = [mses; curr_mse];
    
    brisques = [];
    curr_brisque = brisque(lm);
    brisques = [brisques; curr_brisque];
    
    niqes = [];
    curr_niqe = niqe(lm);
    niqes = [niqes; curr_niqe];
    
    piqes = [];
    curr_piqe = piqe(lm);
    piqes = [piqes; curr_piqe];
end


for i=1:maxiter
    Flm = F(lm);
    H = fft2(Flm)./(fft2(lm)+1e-7);
    Hconj = conj(H);
    num = Hconj.*(fft2(y-Flm));
    denom = (Hconj.*H+a);
    lm = lm + real(ifft2(num./denom));
    
    e = img_norm(y - F(lm));
    E = [E; e];
    
    if show_denoised == 1
        lmd = denoise(lm);
        
        curr_psnr = psnr(lmd, xref);
        psnrs = [psnrs; curr_psnr];
        
        curr_ssim = ssim(lmd, xref);
        ssims = [ssims; curr_ssim];
        
        curr_mse = immse(lmd, xref);
        mses = [mses; curr_mse];
        
        curr_brisque = brisque(lmd);
        brisques = [brisques; curr_brisque];
        
        curr_niqe = niqe(lmd);
        niqes = [niqes; curr_niqe];
        
        curr_piqe = piqe(lmd);
        piqes = [piqes; curr_piqe];
    else
        curr_psnr = psnr(lm, xref);
        psnrs = [psnrs; curr_psnr];
        
        curr_ssim = ssim(lm, xref);
        ssims = [ssims; curr_ssim];
        
        curr_mse = immse(lm, xref);
        mses = [mses; curr_mse];
        
        curr_brisque = brisque(lm);
        brisques = [brisques; curr_brisque];
        
        curr_niqe = niqe(lm);
        niqes = [niqes; curr_niqe];
        
        curr_piqe = piqe(lm);
        piqes = [piqes; curr_piqe];
    end
    
end

end
