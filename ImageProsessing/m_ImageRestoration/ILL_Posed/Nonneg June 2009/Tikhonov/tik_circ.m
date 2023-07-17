%  tik_circ.m
%
%  Compute the unconstrained least squares solution in the BCCB case.
%  f_reconstruct = (S*S+alpha I)^-1 S*d.
%  First load the Data (StarData_circ_psf073_128.mat).

  alpha = input('Regularization parameter alpha = '); 
  %% NOTE: optimal alpha = 9e-4 StarData_circ_psf073_128.mat  
  S = Data.BCCB_kernel_fft;
  d = Data.noisy_data;
  f_reconstruct = ... 
         real(ifft2((conj(S)./(conj(S).*S + alpha*ones(size(S)))).*fft2(d)));

  fprintf('relative error = %5.5e\n',norm(f_reconstruct(:)-Data.object(:))/norm(Data.object(:)));

  % Plots

  xx = [97:128]; 
  yy = [1:32];

  figure(1)
    mesh(xx,yy,Data.object(xx,yy))

  figure(2)
    mesh(xx,yy,f_reconstruct(xx,yy))

  figure(3)
    mesh(xx,yy,max(f_reconstruct(xx,yy),0))
  
  figure(4)
     subplot(221)
       imagesc(f_reconstruct)
       colorbar
     subplot(222)
       imagesc(d)
       colorbar
     subplot(224)
       imagesc(Data.object)
       colorbar
