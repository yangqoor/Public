%  tik_circ_extend.m
%
%  Compute the unconstrained least squares solution in the BTTB case
%  via an approximation of S by a BCCB matrix.
%
%  f_reconstruct = (S*S+alpha I)^-1 S*d.
%
%  DO THE FOLLOWING FIRST!!
%
%  >> load StarData_toep_psf073_128.mat
%  >> load AOpsfs.mat
%  >> psf = psf_interp(psf_interp(psf073));
%  >> psf_hat = fft2(fftshift(psf));
%  >> dc = psf_hat(1,1);
%  >> S = (1/dc) * psf_hat;

  f_true = Data.object;
  d = Data.noisy_data;
  [Nx,Ny] = size(d);
  Nx2 = 2*Nx;
  Ny2 = 2*Ny;
  % Extend d by zeros
  d_extend = zeros(Nx2,Ny2);
  d_extend(1:Nx,1:Ny) = d;

  alpha = input('Regularization parameter alpha = '); 
  %% NOTE: optimal alpha = 8e-4 (4e-4 for projection) 
  f_alpha = ... 
   real(ifft2((conj(S)./(conj(S).*S + alpha*ones(size(S)))).*fft2(d_extend)));
  f_alpha = f_alpha(1:Nx,1:Ny);
  f_alpha_proj = max(f_alpha,0);

  fprintf('relative error least squares           = %5.5e\n',norm(f_alpha(:)-f_true(:))/norm(f_true(:)));
  fprintf('relative error projected least squares = %5.5e\n',norm(f_alpha_proj(:)-f_true(:))/norm(f_true(:)));


  % Plots

  xx = [97:128]; 
  yy = [1:32];

  figure(1)
    mesh(xx,yy,f_true(xx,yy))

  figure(2)
    mesh(xx,yy,f_alpha(xx,yy))

  figure(3)
    mesh(xx,yy,max(f_alpha(xx,yy),0))
  
  figure(4)
     subplot(221)
       imagesc(f_true)
       colorbar
       title('f_true')
     subplot(222)
       imagesc(d)
       colorbar
       title('d')
     subplot(223)
       imagesc(f_alpha)
       colorbar
       title('f_alhpa')
     subplot(224)
       imagesc(max(f_alpha,0))
       colorbar
       title('max(f_true,0)')
