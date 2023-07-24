function prob=update_x_freqdeconv_img_space(prob)
    
    L=length(prob.prior_ivar);
    
    
    sig_noise=prob.sig_noise;
    N3=size(prob.filts,3);
    k=prob.k;
    y=prob.y;
    y=edgetaper(y,k);%This should reduce some of the
                     %cyclic deconvolution artifacts
    [N1,N2,N4]=size(y);
    N=N1*N2;
    
    k_sz1=prob.k_sz1;
    k_sz2=prob.k_sz2;
    hk_sz1=floor(k_sz1/2-0.5);
    hk_sz2=floor(k_sz2/2-0.5);

    ig=0;
    for j=1:N3
      tg=fft2(prob.filts(:,:,j),N1,N2);
      tg(1,1)=max(tg(1,1),0.001);
      ig=ig+abs(tg).^2;
    end
    ig=ig*prob.prior_ivar/N3;

      
    k=zero_pad2(prob.k,ceil((N1-prob.k_sz1)/2),floor((N1-prob.k_sz1)/2),...
               ceil((N2-prob.k_sz2)/2), floor((N2-prob.k_sz2)/2) );
    K=fft2(ifftshift(k));
   
    xfreqcov=1./(1/sig_noise^2*abs(K).^2+ig);
    
    for j0=1:N4
    
      y0=y(:,:,j0);
      Y=fft2(y0)/(N)^0.5;
      X=1/sig_noise^2*xfreqcov.*(K).*Y;
      x=real(ifft2(X)*(N)^0.5);

      bdr=max(k_sz1,k_sz2)*2; 
      prob.border_sz=bdr;
        
      prob.x(:,:,j0)=x; prob.xcov{j0}=xfreqcov;
      M1=N1-2*bdr;
      M2=N1-2*bdr;
      M=M1*M2;
      
      if (~prob.cycconv)   
         sx=x(bdr+1:end-bdr,bdr+1:end-bdr);
         sy=y0(bdr+1+hk_sz1:end-bdr-hk_sz1,bdr+1+hk_sz2:end-bdr-hk_sz2);
         r1=(M1-k_sz1+1)*(M2-k_sz2+1)/N;
         for j=1:N3
           filtx(:,:,j)=conv2(x,prob.filts(:,:,j),'same');
         end
         sfiltx=filtx(bdr+1+hk_sz1:end-bdr-hk_sz1,bdr+1+hk_sz2:end-bdr-hk_sz2,:);
      else
         sx=x; sy=y;
         r1=1; r2=1;
         for j=1:N3
           filtx(:,:,j)=cycconv(x,prob.filts(:,:,j));
         end
         sfiltx=filtx; 
      end
      
      
      da1=r1*1/sig_noise^2*(abs(K).^2);
      da2=r1*ig;
      
      sumA1xcov=sum(sum(da1.*xfreqcov));
      sumA2xcov=sum(sum(da2.*xfreqcov));
      
      xb=1/sig_noise^2*sum(sum((sx).*convfun(sy,prob.k,prob.cycconv,'full')));
     

      ynorm=1/sig_noise^2*sum(sum(abs(sy).^2));
      
      xA1x=1/sig_noise^2*sum(sum(abs(convfun(sx,flp(prob.k),prob.cycconv,'valid')).^2));
      xA2x=prob.prior_ivar*sum(abs(sfiltx(:)).^2)/N3;


      prob.freeeng_qlogp_ycx(j0)=0.5*(sumA1xcov+xA1x-2*xb+ynorm);
      prob.freeeng_qlogp_x(j0)=0.5*(sumA2xcov+xA2x)...
                              -0.5*r1*sum(log(ig(:)));
    
      prob.freeeng_qpilogqpi(j0)=r1*N*prob.prior_pi...
                                  .*log(max(prob.prior_pi,0.1^15));
      prob.freeeng_qxlogqx(j0)=r1*(-0.5*sum(sum(log(abs(xfreqcov))))-(1+log(2*pi))*N/2);
   
    end
    
      
    prob.freeeng=sum(prob.freeeng_qlogp_ycx)+sum(prob.freeeng_qlogp_x)...
                 +sum(prob.freeeng_qpilogqpi)+sum(prob.freeeng_qxlogqx);
    
    