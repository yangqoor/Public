function prob=update_x_conjgrad_diagfe_filt_space(prob)
    
    sig_noise=prob.sig_noise;
    [N1,N2,N3]=size(prob.filty);
    N=N1*N2;
    %While filty is N1xN2, we solve for a M1xM2 x, to include all
    %variables required for expressing the convolution at the
    %boundaries 
    M1=N1+prob.k_sz1-1;
    M2=N2+prob.k_sz2-1;
    M=M1*M2;
    L=length(prob.prior_ivar);
    mask=zero_pad(ones(N1,N2),(prob.k_sz1-1)/2,(prob.k_sz2-1)/2);
    da1=1/sig_noise^2*conv2(mask,abs(prob.k).^2,'same');
   
    filty=prob.filty;    
    init_iv=sum(prob.prior_ivar.*prob.prior_pi);
    
    
    %itrN is the number of mixture component estimation iterations.
    %if L==1 we have a Gaussian prior and hence there is no need
    %for mixture component estimation, we just solve for x in a
    %single iteration
    itrN=2*(L>1)+1; 
            
    use_prev_x=(~prob.init_x_every_itr)&(~isempty(prob.filtx))&(L>1);
    for j=1:N3
              
      if use_prev_x
         x=prob.filtx(:,:,j);
         xcov=prob.filtxcov{j};
      end
      for itr=1:itrN  
        
         if (itr==1)&(~use_prev_x)
            w=init_iv*ones(M1,M2);
            cpi=ones(M,1)*(prob.prior_pi);
         else
            %compute expected derivative magnitude using mean and covariance 
            ex2=abs(x(:)).^2+xcov(:);
            %compute the distribution on hidden variables q(h_i==j)
            logpi=-0.5*ex2*prob.prior_ivar...
                  +ones(M,1)*(log(prob.prior_pi)+0.5*log(prob.prior_ivar));
            cpi=normexp(logpi);
            %compute derivative regularization weights
            w=cpi*(prob.prior_ivar)';
            w=reshape(w,M1,M2);
         end
         %Use the conjugate gradient algorithm to solve a weighted
         %deconvolution problem, that is, find x such that
         %convolved with k, we get filty up to noise, plus we minimize
         %the squared magnitude of each entry of x (remember, we
         %solve in the gradient domain, so the entries of x here
         %are the derivatives of the actual latent image). The
         %penalty on each entry is weighted by the non uniform
         %weights w computed above. 
         [x]=conjgrad_deconv_g(filty(:,:,j),prob.k,sig_noise^2,15,w);
         
         
         %We estimate a diagonal covariance which is just the inverse
         %diagonal of the weighted deconvolution system we have
         %just solved.
         da2=w;
         xcov=1./(da1+da2);
                   
      end
      
      %below we compute the free energy. This has no effect on the
      %actual result but can be useful for debugging and monitoring.
      sumA1xcov=sum(sum(da1.*xcov));
      sumA2xcov=sum(sum(da2.*xcov));
      xA1x=1/sig_noise^2*sum(sum(abs(conv2(x,flp(prob.k),'valid')).^2));
      xA2x=sum(sum(abs(da2.*x.^2)));
     
      xb=1/sig_noise^2*sum(sum(conj(x).*conv2(filty(:,:,j),(prob.k))));
      ynorm=1/sig_noise^2*sum(sum(abs(filty(:,:,j)).^2));
      prob.filtx(:,:,j)=x;
            
      prob.filtxcov{j}=xcov;
      prob.freeeng_qlogp_ycx(j)=0.5*(sumA1xcov+xA1x-2*xb+ynorm);
      prob.freeeng_qlogp_x(j)=0.5*(sumA2xcov+xA2x)...
                             +sum(cpi*(-0.5*log(prob.prior_ivar)...
                                           -log(prob.prior_pi))');
      prob.freeeng_qpilogqpi(j)=sum(sum(cpi.*log(max(cpi,0.1^15))));
      prob.freeeng_qxlogqx(j)=-0.5*sum(sum(log(abs(xcov))))-(1+log(2*pi))*M/2;
      
    end
     
    
    prob.freeeng=sum(prob.freeeng_qlogp_ycx)+sum(prob.freeeng_qlogp_x)...
                 +sum(prob.freeeng_qpilogqpi)+sum(prob.freeeng_qxlogqx);
    
    
    