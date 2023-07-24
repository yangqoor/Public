function prob=update_x_conjgrad_diagfe_img_space(prob)

        
    L=length(prob.prior_ivar);
   
    sig_noise=prob.sig_noise;
    N3=size(prob.filts,3);
       
    [N1,N2,N4]=size(prob.y);
    N=N1*N2;
    
    M1=N1+prob.k_sz1-1;
    M2=N2+prob.k_sz2-1;
    M=M1*M2;
    sM1=M1-size(prob.filts,1)+1;
    sM2=M2-size(prob.filts,2)+1;
    sM=sM1*sM2;
        
    k_sz1=prob.k_sz1;
    k_sz2=prob.k_sz2;
    hk_sz1=floor(k_sz1/2-0.5);
    hk_sz2=floor(k_sz2/2-0.5);
    
    hf_sz1u=ceil(size(prob.filts,1)/2-0.5);
    hf_sz2u=ceil(size(prob.filts,2)/2-0.5);
    hf_sz1d=floor(size(prob.filts,1)/2-0.5);
    hf_sz2d=floor(size(prob.filts,2)/2-0.5);
    
    y=prob.y;
    k=prob.k;
    init_iv=sum(prob.prior_ivar.*prob.prior_pi);
    itrN=2*(L>1)+1; 
      
    
    da1=1/sig_noise^2*conv2(ones(N1,N2),abs(k).^2);
    
    use_prev_x=(~prob.init_x_every_itr)&(~isempty(prob.x))&(L>1);
    for j0=1:N4
      if (use_prev_x)
        x=prob.x(:,:,j0);
        xcov=prob.xcov{j0};
      end
      %solve for x using conj gradient
      for itr=1:3
        if (itr==1)&(~use_prev_x)
            w=init_iv*ones(sM1,sM2,N3);
            cpi=ones(sM*N3,1)*prob.prior_pi;
        else
            clear ex2
            for j=1:N3
              filtx(:,:,j)=conv2(x,flp(prob.filts(:,:,j)),'valid');
              filtxcov(:,:,j)=conv2(xcov,flp(prob.filts(:,:,j)).^2,'valid');
              ex2(:,:,j)= filtx(:,:,j).^2+filtxcov(:,:,j);
            end
            ex2=ex2(:);

            logpi=-0.5*ex2*prob.prior_ivar...
                  +ones(sM*N3,1)*(log(prob.prior_pi)+0.5*log(prob.prior_ivar));
            cpi=normexp(logpi);
            w=cpi*(prob.prior_ivar)';
            w=reshape(w,sM1,sM2,N3);
        end
        
        [x]=conjgrad_deconv_i(y(:,:,j0),prob.k,sig_noise^2,60,prob.filts,w);
       
        
        da2=zeros(M1,M2);
        
        for j=1:N3
           da2=da2+1/N3*conv2(w(:,:,j),flp(prob.filts(:,:,j)).^2);
           
           %sum(sum(prob.filts(:,:,j).^2))*...
           %        zero_pad2(w(:,:,j),hf_sz1d,hf_sz1u,hf_sz2d,hf_sz2u);
        end
        xcov=zeros(M1,M2);
        xcov(hf_sz1u+1:end-hf_sz1d,hf_sz2u+1:end-hf_sz2d)=...
            1./(da1(hf_sz1u+1:end-hf_sz1d,hf_sz2u+1:end-hf_sz2d)+da2(hf_sz1u+1:end-hf_sz1d,hf_sz2u+1:end-hf_sz2d));
        %keyboard
      end
    
  
      for j=1:N3
        filtx(:,:,j)=conv2(x,prob.filts(:,:,j),'valid');  
      end

       
      prob.x(:,:,j0)=x; prob.xcov{j0}=xcov;
      
        
      sumA1xcov=sum(sum(da1.*xcov));
      sumA2xcov=sum(sum(da2.*xcov));
      xA1x=1/sig_noise^2*sum(sum(abs(conv2(x,flp(prob.k),'valid')).^2));
      xA2x=sum(sum(abs(da2.*x.^2)));
     
      xb=1/sig_noise^2*sum(sum(x.*conv2(y(:,:,j0),prob.k)));
      ynorm=1/sig_noise^2*sum(sum(abs(y(:,:,j0)).^2));
      
      prob.freeeng_qlogp_ycx(j0)=0.5*(sumA1xcov+xA1x-2*xb+ynorm);
      prob.freeeng_qlogp_x(j0)=0.5*(sumA2xcov+xA2x)...
                             +sum(cpi*(-0.5*log(prob.prior_ivar)...
                                           -log(prob.prior_pi))');
      prob.freeeng_qpilogqpi(j0)=sum(sum(cpi.*log(max(cpi,0.1^15))));
      prob.freeeng_qxlogqx(j0)=-0.5*sum(sum(log(abs(xcov(hf_sz1u+1:hf_sz1d,hf_sz2u+1:hf_sz2d)))))-(1+log(2*pi))*M/2;
      
      
      %prob.freeeng_qlogp_x(j0)=0.5*(sumA2xcov+xA2x)-0.5*r1*sum(log(cig(:)))...
      %                     -r1*sum(scpi*log(prob.prior_pi)');
      %sum(log(cig(:))) is a rude approximation to logdet(A2)..that we
      %don't want to compute expliciitly
   
    end
    
    prob.freeeng=sum(prob.freeeng_qlogp_ycx)+sum(prob.freeeng_qlogp_x)...
                 +sum(prob.freeeng_qpilogqpi)+sum(prob.freeeng_qxlogqx);
    
    
return
     
    
    