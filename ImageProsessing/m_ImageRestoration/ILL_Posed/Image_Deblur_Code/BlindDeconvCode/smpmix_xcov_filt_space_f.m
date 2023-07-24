function [xcov,x0]=smpmix_xcov_filt_space_f(k,sig_noise,w,sN,y,prior_ivar,prior_pi)
    
    [k_sz1,k_sz2]=size(k);
    hk_sz1=round(k_sz1/2-0.5);
    hk_sz2=round(k_sz2/2-0.5);
    
    [M1,M2]=size(w);
    M=M1*M2;
    L=length(prior_pi);

    for j=1:sN
      x(:,:,j)=conjgrad_deconv_g_smp_wy(y,randn(M1,M2,2),k,sig_noise^2,15,w);
    end
    for itr=1:10
        itr;
        for j=1:sN
            ex2=abs(x(:,:,j)).^2; ex2=ex2(:);
            logpi=-0.5*ex2*prior_ivar...
                  +ones(M,1)*(log(prior_pi)+0.5*log(prior_ivar));
            cpi=normexp(logpi);
            cpi=cumsum(cpi,2);
            r=rand(M,1);
            w=(r<cpi(:,1))*prior_ivar(1);
            for i=2:L
              w=w+(r<cpi(:,i)).*((r>=cpi(:,i-1))).*prior_ivar(i);
            end
            w=reshape(w,M1,M2);
            x(:,:,j)=conjgrad_deconv_g_smp_wy(y,randn(M1,M2,2),k,sig_noise^2,10,w);
        end
    end

    tii=find(~max(max(isnan(x),[],1),[],2));
    sN=length(tii);
    x=x(:,:,tii);
    x=reshape(x,M,size(x,3));
    x0=mean(x,2);
    
    estlen=M*(2*k_sz1+1)*(2*k_sz2+1);
    iiL=zeros(1,estlen);
    jjL=zeros(1,estlen);
    valL=zeros(1,estlen);
    tjjL=zeros(1,k_sz1*k_sz2*4);
   
    len=0;
    for i1=1:M1
        for i2=1:M2
            tlen=0;  
            for j1=max(1,i1-k_sz1):min(i1+k_sz1,M1)
              for j2=max(1,i2-k_sz2):min(i2+k_sz2,M2)
                  tlen=tlen+1;
                  tjjL(tlen)=j1+(j2-1)*M1;
                  
              end
            end
            tjjL=tjjL(1:tlen);
            ii=(i1+(i2-1)*M1);
            iiL(len+1:len+tlen)=ii*ones(1,tlen);
            jjL(len+1:len+tlen)=tjjL;
            valL(len+1:len+tlen)=x(ii,:)*(x(tjjL,:)')/sN-x0(ii)*x0(tjjL)';
            len=len+tlen;

        end
               
    end
      
    iiL=iiL(1:len);
    jjL=jjL(1:len);
    valL=valL(1:len);
    xcov=sparse(iiL,jjL,valL,M,M);
   
    
    x0=reshape(x0,M1,M2);