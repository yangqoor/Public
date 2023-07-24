function prob=update_k(prob)
    
     sig_noise=prob.sig_noise;
     k_sz1=prob.k_sz1;
     k_sz2=prob.k_sz2;
     
     if (prob.filt_space==1)
       x=prob.filtx;
       xcov=prob.filtxcov;
       y=prob.filty;
     else
       x=prob.x;
       xcov=prob.xcov;
       y=prob.y;
     end
     
     A=zeros(prob.k_sz,prob.k_sz); 
     b=zeros(prob.k_sz,1);
     c=0; 
     %Loop over each of the filters/imgs and build the constraint
     %System (the matrix A_k and vector b_k)
     for j=1:size(x,3)
        %We have a different function for building the constraint
        %matrix depending on the type of covariance used.
         
        if strcmp(prob.covtype,'full')|strcmp(prob.covtype,'blockdiag')|strcmp(prob.covtype,'smp')
           [tA,tb,tc]=getCorAb(x(:,:,j),y(:,:,j), ...
                               xcov{j},k_sz1,k_sz2);
        end
        if strcmp(prob.covtype,'diag')
           [tA,tb,tc]=getCorAbDiagCov(x(:,:,j),y(:,:,j), ...
                                      xcov{j},k_sz1,k_sz2);
        end 
        if strcmp(prob.covtype,'freqdiag')
           if (prob.cycconv)
              [tA,tb,tc]=getCorAbFreqDiagCovCyc(x(:,:,j),y(:,:,j), ...
                                                xcov{j},k_sz1,k_sz2);
           else
              [tA,tb,tc]=getCorAbFreqDiagCov(x(:,:,j),y(:,:,j), ...
                                             xcov{j},k_sz1,k_sz2);
           end
        end
        A=A+tA; b=b+tb; c=c+tc;     
        AL{j}=tA; bL{j}=tb; cL{j}=tc;
     end
     %solve for k
     if (isfield(prob,'unconst_k')&(prob.unconst_k==1))
        %solve without positivity constraints 
        %(faster, only "\")
        prob.k=solve_for_sps_kernel_unconst(A,b,k_sz1,k_sz2,prob.k_prior_ivar);
     else
        %solve with positivity constraints 
        %(slower- quadratic programing problem involved)
        prob.k=solve_for_sps_kernel(A,b,k_sz1,k_sz2,prob.k_prior_ivar);
     end  
    
     k=prob.k(:);
     
     
     %recompute free energy
     for j=1:size(x,3)
        prob.freeeng_qlogp_ycx(j)=1/(2*sig_noise^2)*(k'*AL{j}*k-2*k'*bL{j}+cL{j} ); 
     end

     
     prob.freeeng=sum(prob.freeeng_qlogp_ycx)+sum(prob.freeeng_qlogp_x)...
                 +sum(prob.freeeng_qpilogqpi)+sum(prob.freeeng_qxlogqx);