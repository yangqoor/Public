%  EM.m
%
%  Find approximate solution to Sf = conv(s,f) = d using EM iteration. 
%  EM seeks to minimize the Poisson negative log likelihood function
%    J(f) = sum_i {[Sf]_i - (d_i + sigma^2)*log([Sf]_i + sigma^2)}.

  global TOTAL_FFTS 
  TOTAL_FFTS = 0;
  fft_vec = [];

  max_iter = input(' Max. no. EM iterations = ');
  stdev = Data.gaussian_stdev;
  b = Data.Poiss_bkgrnd;
  if Data.type == 'toep'
    Tmult = 'bttb_mult_fft';
    t_hat = Data.BTTB_kernel_fft;
  else  % type = 'circ'
    Tmult = 'bccb_mult_fft';
    t_hat = Data.BCCB_kernel_fft;
  end

  c = b + stdev^2;
  dps = Data.noisy_data + stdev^2;
  f_em = ones(size(dps));
  f_true = Data.object;
  norm_f = norm(f_true(:));
  em_error = norm(f_em(:)-f_true(:))/norm_f;
  S1 = feval(Tmult,ones(size(f_em)),conj(t_hat));
  pgnorm_vec = [];
  
  for k=0:max_iter-1,
    Sfpc = feval(Tmult,f_em,t_hat) + c;
    temp = feval(Tmult,dps./Sfpc,conj(t_hat));
    f_em = f_em./S1.*temp;
    ek = norm(f_em(:)-f_true(:))/norm_f;
    em_error = [em_error;ek];
    
    %  Save the projected gradient.

    gradJ = S1 - temp;
    Active = (f_em == 0);
    pgradJ = ((1-Active)+(gradJ<0).*Active).*gradJ;
    pgnorm = norm(pgradJ(:));
    pgnorm_vec = [pgnorm_vec;pgnorm];  
    fft_vec = [fft_vec;TOTAL_FFTS];
    
    %  Display EM reconstruction
    
    if mod(k,23) == 0
      fprintf('   Iteration=%i  relative error=%6.4e  |pgradJ|=%6.4e Total FFTs=%i\n',k,ek,pgnorm,TOTAL_FFTS);   
      figure(1)
        subplot(221)
          imagesc(f_true)
	  title('True Object')
        subplot(222)
          imagesc(f_em)
	  title('EM Reconstruction')
        subplot(223)
          semilogy(em_error)
          xlabel('EM Iteration')
	  title('EM Relative Solution Error')
        subplot(224)
          semilogy(fft_vec,pgnorm_vec)
          xlabel('EM Iteration')
          title('Projected Gradient Norm')
      colormap(1-gray)
      drawnow
    end
  end;
  
  [mval,mindex] = min(em_error);
  fprintf(' Min relative soln error of %5.2f percent occurred at EM iteration %d\n', mval*100,mindex);


