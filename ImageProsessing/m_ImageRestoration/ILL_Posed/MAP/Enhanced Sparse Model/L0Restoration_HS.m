function S = L0Restoration_HS(Im, kernel,lambda_data, lambda_grad,theta)
% Please cite the paper if the code is useful.
% @inproceedings{DBLP:conf/eccv/ChenFLLZ20,
%   author    = {Liang Chen and
%                Faming Fang and
%                Shen Lei and
%                Fang Li and
%                Guixu Zhang},
%   title     = {Enhanced Sparse Model for Blind Deblurring},
%   booktitle = {{ECCV}},
%   year      = {2020}
% }

if ~exist('kappa','var')
    kappa = 2.0;
end
%% pad image
H = size(Im,1);    W = size(Im,2);
Im = wrap_boundary_liu(Im, opt_fft_size([H W]+size(kernel)-1));
%%
S = Im;
betamax = 1e5;
fx = [1, -1];
fy = [1; -1];
[N,M,D] = size(Im);
sizeI2D = [N,M];
otfFx = psf2otf(fx,sizeI2D);
otfFy = psf2otf(fy,sizeI2D);
%%
KER = psf2otf(kernel,sizeI2D);
Den_KER = abs(KER).^2;
%%
Denormin2 = abs(otfFx).^2 + abs(otfFy ).^2;
if D>1
    Denormin2 = repmat(Denormin2,[1,1,D]);
    KER = repmat(KER,[1,1,D]);
    Den_KER = repmat(Den_KER,[1,1,D]);
end
Normin1 = conj(KER).*fft2(S);
%% 
beta1 = 2*lambda_grad;
tau1 = 2*lambda_data;
B_h = [diff(Im,1,2), Im(:,1,:) - Im(:,end,:)];
B_v = [diff(Im,1,1); Im(1,:,:) - Im(end,:,:)];
KG_h = otfFx.*KER;
KG_v = otfFy.*KER;
KG = abs(KG_h).^2 + abs(KG_v).^2;
while beta1 < betamax
    Denormin   = Den_KER + beta1*Denormin2 + tau1*KG;
    S_h = [diff(S,1,2), S(:,1,:) - S(:,end,:)];
    S_v = [diff(S,1,1); S(1,:,:) - S(end,:,:)]; 
    %%estimate q
    q_h = B_h - fftconv(S_h,kernel);
    q_h = sign(q_h).*max(abs(q_h)-lambda_data*theta/(2*tau1),0);
    q_v = B_v - fftconv(S_v,kernel);
    q_v = sign(q_v).*max(abs(q_v)-lambda_data*theta/(2*tau1),0);
    t_h = q_h.^2<lambda_data/tau1;
    t_v = q_v.^2<lambda_data/tau1;
    q_h(t_h) = 0; q_v(t_v) = 0;
    %%%estimate g
    g_h = S_h; g_v = S_v;
    g_h = sign(g_h).*max(abs(g_h)-lambda_grad*theta/(2*beta1),0);
    g_v = sign(g_v).*max(abs(g_v)-lambda_grad*theta/(2*beta1),0);
    t_h = g_h.^2<lambda_grad/beta1;
    t_v = g_v.^2<lambda_grad/beta1;
    g_h(t_h)=0; g_v(t_v)=0;
    %%%%estimate I
    Normin2 = [g_h(:,end,:) - g_h(:, 1,:), -diff(g_h,1,2)];
    Normin2 = Normin2 + [g_v(end,:,:) - g_v(1, :,:); -diff(g_v,1,1)];
    Normin3 = conj(KG_h).*fft2(B_h - q_h);
    Normin3 = Normin3 + conj(KG_v).*fft2(B_v - q_v);
    FS = (Normin1 + beta1*fft2(Normin2) + tau1*Normin3)./Denormin;
    S = real(ifft2(FS));
    beta1 = beta1*kappa;
    tau1 = tau1*kappa;
end
S = S(1:H, 1:W, :);
end
