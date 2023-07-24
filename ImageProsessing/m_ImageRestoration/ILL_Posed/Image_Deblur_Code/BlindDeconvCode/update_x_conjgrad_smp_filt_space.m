function prob=update_x_conjgrad_smp_filt_space(prob)
    

    sig_noise=prob.sig_noise;
    [N1,N2,N3]=size(prob.filty);
    N=N1*N2;
    M1=N1+prob.k_sz1-1;
    M2=N2+prob.k_sz2-1;
    M=M1*M2;
    L=length(prob.prior_ivar);
    mask=zero_pad(ones(N1,N2),(prob.k_sz1-1)/2,(prob.k_sz2-1)/2);
    
    K=getConvMat(M2,M1,prob.k,[],0);
    A1=1/sig_noise^2*K'*K;
    
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
         dxcov=reshape(full(diag(xcov)),M1,M2);
      end
      for itr=1:itrN  
        
         if (itr==1)&(~use_prev_x)
            w=init_iv*ones(M1,M2);
            cpi=ones(M,1)*(prob.prior_pi);
         else
            ex2=abs(x(:)).^2+dxcov(:);
            logpi=-0.5*ex2*prob.prior_ivar...
                  +ones(M,1)*(log(prob.prior_pi)+0.5*log(prob.prior_ivar));
            cpi=normexp(logpi);
            w=cpi*(prob.prior_ivar)';
            w=reshape(w,M1,M2);
         end
                         
         da2=w;
          
         [xcov,x]=smpmix_xcov_filt_space_f(prob.k,sig_noise,w,prob.smps_num,filty(:,:,j),prob.prior_ivar,prob.prior_pi);
         
         dxcov=reshape(full(diag(xcov)),M1,M2);
         %toc           
      end

      logdetL=0;
      sumA1xcov=sum(sum(A1.*xcov));
      %sumA1xcov=sum(sum(da1.*xcov));
      sumA2xcov=sum(sum(da2.*dxcov));
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
      
      %inaccurate but fast
      prob.freeeng_qxlogqx(j)=-0.5*sum(sum(log(max(abs(dxcov),0.1^10))))-(1+log(2*pi))*M/2;
      %%accurate but slow..
      %prob.freeeng_qxlogqx(j)=-0.5*logdet(xcov)-(1+log(2*pi))*M/2;

      %keyboard
    end
     
    
    prob.freeeng=sum(prob.freeeng_qlogp_ycx)+sum(prob.freeeng_qlogp_x)...
                 +sum(prob.freeeng_qpilogqpi)+sum(prob.freeeng_qxlogqx);
    
    
return    
