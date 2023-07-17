%  EM.m
%
%  Find approximate solution to Sf = conv(s,f) = d using EM iteration. 
%  EM seeks to minimize the Poisson negative log likelihood function
%    J(f) = sum_i {[Sf]_i - (d_i + sigma^2)*log([Sf]_i + sigma^2)}.

  max_iter = 100; %%%input(' Max. no. EM iterations = ');
  sigsq = 25; %%%input(' sigma^2 = ');

  dps = max(dat,0) + sigsq;  
  f_em = dps + sqrt(eps);
  norm_f = norm(f_true(:));
  em_error = norm(f_em(:)-f_true(:))/norm_f;
  K1 = mat_prod(conj(S{1}),ones(size(f_em)));
  
  for k=0:max_iter-1,
    Kfps = mat_prod(S{1},f_em) + sigsq;
    f_em = f_em./K1.*mat_prod( conj(S{1}),dps./Kfps);
    ek = norm(f_em(:)-f_true(:))/norm_f;
    em_error = [em_error;ek];
    
    %  Display EM reconstruction
    
    if mod(k,max_iter/20) == 0
      fprintf('   Iteration %i, relative error %6.4e\n',k,ek);
      figure(1)
        subplot(221)
          imagesc(f_true(1:nfx,1:nfy)), colorbar
	  title('True Object')
        subplot(222)
          imagesc(f_em(1:nfx,1:nfy)), colorbar
	  title('EM Reconstruction')
        subplot(223)
          semilogy(em_error)
          xlabel('EM Iteration')
	  title('EM Relative Solution Error')
      colormap(1-gray)
      drawnow
    end
  end;
  
  [mval,mindex] = min(em_error);
  fprintf(' Min relative soln error of %5.2f percent occurred at EM iteration %d\n', mval*100,mindex);


