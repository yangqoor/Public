% Sample code of the papers:
% 
% Sayantan Dutta, Adrian Basarab, Bertrand Georgeot, and Denis Kouamé,
% "Plug-and-Play Quantum Adaptive Denoiser for Deconvolving Poisson Noisy Images,"
% arXiv preprint arXiv:2107.00407 (2021).
%
% Sayantan Dutta, Adrian Basarab, Bertrand Georgeot, and Denis Kouamé,
% "Poisson image deconvolution by a plug-and-play quantum denoising scheme,"
% in 2021 29th European Signal Processing Conference (EUSIPCO), 2021.
%
% Sayantan Dutta, Adrian Basarab, Bertrand Georgeot, and Denis Kouamé,
% "Quantum mechanics-based signal and image representation: Application
% to denoising," IEEE Open Journal of Signal Processing, vol. 2, pp. 190–206, 2021.
% 
% One should cite all these papers for using the code.
%---------------------------------------------------------------------------------------------------
% MATLAB code prepard by Sayantan Dutta
% E-mail: sayantan.dutta@irit.fr and sayantan.dutta110@gmail.com
% 
% This script shows an example of our image deconvolution algorithm 
% using Quantum adaptative basis (QAB) as a plug-and-play denoiser
% in the ADMM framework
%---------------------------------------------------------------------------------------------------


function [ x,v, history, ext , conv ] = QAB_PnP_deblur(I, y,lambda,gama,kernel,h_cut,sigma,fraction)


QUIET    = 0;
ABSTOL   = 1e-4;
RELTOL   = 1e-2;
PSNR_max = 0;
rho = 1;
MAX_ITER = 50;
ext.MAX_ITER = MAX_ITER;

[m,n]=size(y);  % size of the imput image

% start computing time
t_start = tic;

% Calculation of the eigenvectors and eigenvalues for QAB
[psi,psi_col,E] = eigenvec(I,h_cut,sigma); 

% Find number of significant eigenvectors
significant_E = 0;
for i = 1:(m*n)
    if (E(i) <= fraction * (max(y(:)) - min(y(:))))
        significant_E = significant_E + 1;
    end
end 
fprintf('\n significant EV = %3.0f \n', significant_E);
ext.significant_E = significant_E;


% Start the ADMM process -----------------------------------------------------------------

% initialize the ADMM
    y=y(:);                 % vectorized the input
    x=0.5*ones(size(y));    % initial choice of the hidden image
    v=x;                    % initial choice of the constrain 
    u=x;                    % initial choice of the Lagrangian multiplier
    
% main ADMM-loop

if ~QUIET
    fprintf('Plug-and-Play ADMM --- Deblurring \n');
%     fprintf('%3s\t%6s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n', 'iter', ...
%       'r norm', 'eps pri', 's norm', 'eps dual','RMSE','PSNR','SSIM');
    fprintf('%3s\t%6s\t%10s\t%10s\t%10s\t%10s\n', 'iter', ...
       'lambda', 'D(v-vtil)','RMSE','PSNR','SSIM');
end

    for k=1:MAX_ITER  
        x_old = x;
        v_old = v;
        u_old = u;
        
        % Do ADMM
        [x,v,u, Dv_vtil] = PnP_ADMM_Step(x,v,u,I,y,psi,psi_col,m,n,lambda,kernel,significant_E);        


    % reshape the data
    v1=reshape(v,m,n);

% store doundedness of the denoiser
    conv.Dv_vtil(k) = Dv_vtil;
    conv.lambda(k) = lambda;

% calculate RMSE, PSNR, SSIM for each iterations
    history.rmse(k)  = sqrt(sum(sum((I - v1).^2))/(m*n));
    history.PSNR(k) = psnr(I,v1);
    history.ssim(k) = ssim_index(v1, I, [0.01 0.03], fspecial('gaussian', 3, 1.5), max(I(:)));
    
    history.r_norm(k)  = norm(x - v);
    history.s_norm(k)  = norm(-rho*(v - v_old));

    history.eps_pri(k) = sqrt(n)*ABSTOL + RELTOL*max(norm(x), norm(-v));
    history.eps_dual(k)= sqrt(n)*ABSTOL + RELTOL*norm(rho*u);

    % show the data for each iterations
    if ~QUIET
%         fprintf('%3d\t%10.4f\t%10.4f\t%10.4f\t%10.4f\t%10.4f\t%10.4f\t%10.4f\n', k, ...
%             history.r_norm(k), history.eps_pri(k), history.s_norm(k), ...
%             history.eps_dual(k),history.rmse(k), history.PSNR(k), history.ssim(k));
        fprintf('%3d\t%10.4f\t%10.4f\t%10.4f\t%10.4f\t%10.4f\n',...
            k, conv.lambda(k), conv.Dv_vtil(k), ...
            history.rmse(k), history.PSNR(k), history.ssim(k));
    end

    % update the penalty parameter by a factor gamma
    lambda = lambda*gama;
    end
    
     if ~QUIET
     ext.computation_time = toc(t_start);  % stope the time
     end
 
%    x=reshape((x+v)/2,m,n);
     v=reshape(v,m,n);
     x=reshape(x,m,n);

end






function [psi,psi_col,E] = eigenvec(I,h_cut,sigma)

% use Gaussian blurring
[n,n2] = size(I); % assume n = n2
nn = n^2;
pds = h_cut;    % value of palnck's constant
sg = sigma;     % gaussian Variance of the blur before calculation

[x,x1] = meshgrid((-n/2):(n/2 - 1));
z = 1 / (sqrt(2 * pi * sg))^2 * exp(-(x .^2 + x1 .^2) / (2 * sg)); 
% Convolution product
gaussF = fft2(ifftshift(z));
yF = fft2(I);
y_n = real(ifft2(gaussF .* yF));  % smooth image to counter the localization effect

%Calculation of the eigenvectors then projection in the base
[psi,psi_col,E] = f_ondes2D(y_n,pds);

end
