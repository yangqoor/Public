function k = FrankWolfe(u, k, g, iter, lambda)

[~,~,CC]=size(u);
TV_energy = zeros(CC,1);
for cc=1:CC
    TV_energy(cc) = getTVEnergy(u(:,:,cc));
end


for ii=1:iter
    s = zeros(size(k));
    err = convn(u, k,'valid') - g;
    grad_k = conv2dFFTW_mex(rot90(u, 2), err, 'valid') + lambda*TV_energy.*k/(norm(k(:),2));
    [~, POS] = min(grad_k(:));
    s(POS)=1;
    gamma = 1/(50+ii);
    k = (1-gamma)*k+gamma*s;
end


