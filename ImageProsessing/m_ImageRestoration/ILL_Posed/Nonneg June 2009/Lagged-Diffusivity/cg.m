  function [x,residnormvec,stepnormvec,cgiter] = ...
      cg(k_hat_sq,L,alpha,r,max_cg_iter,cg_steptol,cg_residtol)
  
%
%
%  Solve linear system (K'*K + alpha*L)x = r using conjugate gradient
%  iteration. 

  cg_out_flag = 0;
  nsq = max(size(r));
  n = sqrt(nsq);
  x = zeros(nsq,1);
  resid = r(:);
  residnormvec = norm(resid);
  stepnormvec = [];
  cgiter = 0;
  stop_flag = 0;

    %  CG iteration.

  while stop_flag == 0
    cgiter = cgiter + 1;

    dh = resid;

    %  Compute conjugate direction p.
 
    rd = resid'*dh;
    if cgiter == 1,
       ph = dh; 
     else
       betak = rd / rdlast;
       ph = dh + betak * ph;
    end

    %  Form product (K'*K + alpha*L)*ph.

    KstarKp = convolve_2d(reshape(ph,n,n),k_hat_sq,n,n);
    Ahph = KstarKp(:) + alpha * L*ph;

    %  Update Delta_f and residual.
    
    alphak = rd / (ph'*Ahph);
    x = x + alphak*ph;
    resid = resid - alphak*Ahph;
    rdlast = rd;
      
    residnorm = norm(resid(:));
    stepnorm = abs(alphak)*norm(ph)/norm(x);
    residnormvec = [residnormvec; residnorm];
    stepnormvec = [stepnormvec; stepnorm];

      %  Check stopping criteria.
    
    if cgiter >= max_cg_iter
      stop_flag = 1;
    elseif stepnorm < cg_steptol
      stop_flag = 2;
    elseif residnorm / residnormvec(1) < cg_residtol
      stop_flag = 3;
    end

      %  Display CG convergence information.
      
    if cg_out_flag == 1
      fprintf('   CG iter%3.0f, ||resid||=%6.4e, ||step||=%6.4e \n', ... 
         cgiter, residnormvec(cgiter), stepnormvec(cgiter))
      figure(1)
        subplot(221)
          semilogy(residnormvec/residnormvec(1),'o')
          title('CG Residual Norm')
        subplot(222)
          semilogy(stepnormvec,'o')
          title('CG Step Norm')
    end

  end %end for CG
    
