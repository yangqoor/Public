function x_est = nbd_single(y, mfmap)
% y: input blurred image
% mfmap: input motion flow map

mu = mfmap(:,:,1);
mv = mfmap(:,:,2);

[mag, ori]= motion2magori(-mv, mu);

params.alpha = 1/2;
params.mu = 0;
params.maxIter_out = 1;
params.maxIter_in = 5;
params.useGPU = 0;

kernelInit.mlhmag = mag;
kernelInit.mlhori = ori;

[x_est] = fast_deconv_nonUniform_gmmprior(y, y, [], params, kernelInit);

end