function k = FrankWolfe_Lp(u, k, g, iter, lambda, p)

[~,~,CC]=size(u);
TV_energy = zeros(CC,1);
for cc=1:CC
    TV_energy(cc) = getTVEnergy(u(:,:,cc));
end

step = 1e-3;
k_old = k;
old_cost = 1e9;
for ii=1:iter
    grad_k = zeros(size(k));
    s = zeros(size(k));
    err = conv2dFFTW_mex(u, k,'valid') - g;
    
    cur_cost = 0.5*sum(err(:).^2) + lambda*sum(TV_energy,CC)*norm(k(:),p);

    grad_k_tmp = k.^(p-1)/(norm(k(:),p)^(p-1));
    for cc =1:CC
        grad_k = grad_k + conv2dFFTW_mex(rot90(u(:,:,cc), 2), err(:,:,cc), 'valid') + lambda.*grad_k_tmp*TV_energy(cc);
    end
    [~, POS] = min(grad_k(:));
    s(POS)=1;
    gamma = 0;
    while cur_cost <= old_cost
        k_old = (1-gamma)*k+gamma*s;
        old_cost = cur_cost;
        gamma = gamma + step;
        k_new = (1-gamma)*k+gamma*s;
        err = convn(u, k_new,'valid') - g;
        cur_cost = 0.5*sum(err(:).^2) + lambda*sum(TV_energy,CC)*norm(k_new(:),p);
    end
    if gamma == 0
        break;
    end
    k = k_old;
end

