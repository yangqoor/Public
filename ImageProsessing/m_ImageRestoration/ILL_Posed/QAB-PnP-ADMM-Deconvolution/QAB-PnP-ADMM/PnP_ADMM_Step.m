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


function [x,v,u, Dv_vtil ] = PnP_ADMM_Step(x_k,v_k,u_k,I,y,psi,psi_col,m,n,lambda,kernel,significant_E)


% Restoration process
x = Restoration_Step1(x_k,v_k,u_k,y,m,n,lambda,kernel);  % use gradient descent method


% denoising process by using QAB denoiser
    vtilde = x+u_k;
    vtilde=reshape(vtilde,m,n);

y_col = reshape(vtilde,m*n,1);
% orthogonal matching pursuit
% alp = OMP (significant_E/significant_E,y_col,psi_col);
alp = linsolve(psi_col,y_col);
[v]      =  QAB_denoiser(I,m,n,psi,alp,significant_E);

Dv_vtil = norm(v(:) - vtilde(:));
%fprintf('Dv_vtil =  %.3f \n lambda = %.3f\n', Dv_vtil, lambda);

v = reshape(v,m*n,1);

 
% Update Lagrangian multiplier
 u = u_k + x - v;

end



function [x] = Restoration_Step1(x_k,v_k,u_k,y,m,n,lambda,kernel)  
    maxFunEvals = 90;
    
    options = [];
    options.display = 'none';
    options.maxFunEvals = maxFunEvals;
    options.Method = 'lbfgs';
    %addpath(genpath('.\'))
    path('./minFunc',path);
    path('./minFunc/compiled',path);    
    
    kernelt=flip(flip(kernel),2);
    
    param.H=@(x) reshape(imfilter(reshape(x,[m n]),kernel,'circular'),m*n,1);
    param.Ht=@(x) reshape(imfilter(reshape(x,[m n]),kernelt,'circular'),m*n,1);

    x0=x_k;
    param.lambda=lambda;
    param.Y=y;
    param.V=v_k;
    param.U=u_k;
    
    f = @(x)Step1Func(x,param);
    x = minFunc(f,x0,options);
end




function z = shrinkage(a, kappa)
    z = max(0, a-kappa) - max(0, -a-kappa);
end

