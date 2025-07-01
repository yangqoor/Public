function [kw, E, psnrs, ssims, mses, brisques, niqes, piqes] = aL_metrics(F, y, xref, options)
% approximate non-linear Landweber
% Keep track of metrics

options.null = 0;
%lam = getoptions(options, 'lam', 1.0);
maxiter = getoptions(options, 'maxiter', 100);
p = getoptions(options, 'p', 0.0);
show_denoised = getoptions(options, 'show_denoised', 0);

kw = y;

E = [];
e = img_norm(y - F(kw));
E = [E; e];

if show_denoised == 1
    kwd = denoise(kw);
    
    psnrs = [];
    curr_psnr = psnr(kwd, xref);
    psnrs = [psnrs; curr_psnr];
    
    ssims = [];
    curr_ssim = ssim(kwd, xref);
    ssims = [ssims; curr_ssim];
    
    mses = [];
    curr_mse = immse(kwd, xref);
    mses = [mses; curr_mse];
    
    brisques = [];
    curr_brisque = brisque(kwd);
    brisques = [brisques; curr_brisque];
    
    niqes = [];
    curr_niqe = niqe(kwd);
    niqes = [niqes; curr_niqe];
    
    piqes = [];
    curr_piqe = piqe(kwd);
    piqes = [piqes; curr_piqe];
else
    psnrs = [];
    curr_psnr = psnr(kw, xref);
    psnrs = [psnrs; curr_psnr];
    
    ssims = [];
    curr_ssim = ssim(kw, xref);
    ssims = [ssims; curr_ssim];
    
    mses = [];
    curr_mse = immse(kw, xref);
    mses = [mses; curr_mse];
    
    brisques = [];
    curr_brisque = brisque(kw);
    brisques = [brisques; curr_brisque];
    
    niqes = [];
    curr_niqe = niqe(kw);
    niqes = [niqes; curr_niqe];
    
    piqes = [];
    curr_piqe = piqe(kw);
    piqes = [piqes; curr_piqe];
end

for n=1:maxiter
    hp = y-F(kw);
    hp = hp(end:-1:1,end:-1:1,:);
    d = (F(kw+hp)-F(kw-hp))/2;
    d = d(end:-1:1,end:-1:1,:);
    
    % step-size
    lam = 1.0/(n)^(p);
    
    kw = kw + lam*d;
    
    e = img_norm(y - F(kw));
    E = [E; e];
    
    
    if show_denoised == 1
        kwd = denoise(kw);
        
        curr_psnr = psnr(kwd, xref);
        psnrs = [psnrs; curr_psnr];
        
        curr_ssim = ssim(kwd, xref);
        ssims = [ssims; curr_ssim];
        
        curr_mse = immse(kwd, xref);
        mses = [mses; curr_mse];
        
        curr_brisque = brisque(kwd);
        brisques = [brisques; curr_brisque];
        
        curr_niqe = niqe(kwd);
        niqes = [niqes; curr_niqe];
        
        curr_piqe = piqe(kwd);
        piqes = [piqes; curr_piqe];
    else
        curr_psnr = psnr(kw, xref);
        psnrs = [psnrs; curr_psnr];
        
        curr_ssim = ssim(kw, xref);
        ssims = [ssims; curr_ssim];
        
        curr_mse = immse(kw, xref);
        mses = [mses; curr_mse];
        
        curr_brisque = brisque(kw);
        brisques = [brisques; curr_brisque];
        
        curr_niqe = niqe(kw);
        niqes = [niqes; curr_niqe];
        
        curr_piqe = piqe(kw);
        piqes = [piqes; curr_piqe];
    end
    
end

end
