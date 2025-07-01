function [S, E, psnrs, ssims, mses, brisques, niqes, piqes] = mRL_metrics(F, y, xref, options)
% Derivative free variant of Lucy-Richardson
% Keep track of metrics

options.null = 0;
maxiter = getoptions(options, 'maxiter', 500);
show_denoised = getoptions(options, 'show_denoised', 0);

S = y;

E = [];
e = img_norm(y - F(S));
E = [E; e];

if show_denoised == 1
    Sd = denoise(S);
    
    psnrs = [];
    curr_psnr = psnr(Sd, xref);
    psnrs = [psnrs; curr_psnr];
    
    ssims = [];
    curr_ssim = ssim(Sd, xref);
    ssims = [ssims; curr_ssim];
    
    mses = [];
    curr_mse = immse(Sd, xref);
    mses = [mses; curr_mse];
    
    brisques = [];
    curr_brisque = brisque(Sd);
    brisques = [brisques; curr_brisque];
    
    niqes = [];
    curr_niqe = niqe(Sd);
    niqes = [niqes; curr_niqe];
    
    piqes = [];
    curr_piqe = piqe(Sd);
    piqes = [piqes; curr_piqe];
else
    psnrs = [];
    curr_psnr = psnr(S, xref);
    psnrs = [psnrs; curr_psnr];
    
    ssims = [];
    curr_ssim = ssim(S, xref);
    ssims = [ssims; curr_ssim];
    
    mses = [];
    curr_mse = immse(S, xref);
    mses = [mses; curr_mse];
    
    brisques = [];
    curr_brisque = brisque(S);
    brisques = [brisques; curr_brisque];
    
    niqes = [];
    curr_niqe = niqe(S);
    niqes = [niqes; curr_niqe];
    
    piqes = [];
    curr_piqe = piqe(S);
    piqes = [piqes; curr_piqe];
end

for i=1:maxiter
    r1 = F(S)./(abs(y)+eps);
    r1 = r1(end:-1:1,end:-1:1,:);
    r2 = F(r1);
    r2 = r2(end:-1:1,end:-1:1,:);
    S = S./(abs(r2)+eps);
    
    r1 = y./(abs(F(S))+eps);
    r1 = r1(end:-1:1,end:-1:1,:);
    r2 = F(r1);
    r2 = r2(end:-1:1,end:-1:1,:);
    S = S.*r2;
    
    e = img_norm(y - F(S));
    E = [E; e];
    
    
    if show_denoised == 1
        Sd = denoise(S);
        
        curr_psnr = psnr(Sd, xref);
        psnrs = [psnrs; curr_psnr];
        
        curr_ssim = ssim(Sd, xref);
        ssims = [ssims; curr_ssim];
        
        curr_mse = immse(Sd, xref);
        mses = [mses; curr_mse];
        
        curr_brisque = brisque(Sd);
        brisques = [brisques; curr_brisque];
        
        curr_niqe = niqe(Sd);
        niqes = [niqes; curr_niqe];
        
        curr_piqe = piqe(Sd);
        piqes = [piqes; curr_piqe];
    else
        curr_psnr = psnr(S, xref);
        psnrs = [psnrs; curr_psnr];
        
        curr_ssim = ssim(S, xref);
        ssims = [ssims; curr_ssim];
        
        curr_mse = immse(S, xref);
        mses = [mses; curr_mse];
        
        curr_brisque = brisque(S);
        brisques = [brisques; curr_brisque];
        
        curr_niqe = niqe(S);
        niqes = [niqes; curr_niqe];
        
        curr_piqe = piqe(S);
        piqes = [piqes; curr_piqe];
    end
    
end

end
