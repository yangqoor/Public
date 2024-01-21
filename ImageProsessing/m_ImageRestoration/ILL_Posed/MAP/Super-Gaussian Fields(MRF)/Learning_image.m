function prob=Learning_image(prob)

        
   % L=length(prob.prior_ivar);
    L=2;
    sig_noise=prob.sig_noise;
    N3=size(prob.filts,3);
       
    [N1,N2,N4]=size(prob.y);
    N=N1*N2;
    
    M1=N1+prob.k_sz1-1;
    M2=N2+prob.k_sz2-1;

    sM1=M1-size(prob.filts,1)+1;
    sM2=M2-size(prob.filts,2)+1;
           
    hf_sz1u=ceil(size(prob.filts,1)/2-0.5);
    hf_sz2u=ceil(size(prob.filts,2)/2-0.5);
    hf_sz1d=floor(size(prob.filts,1)/2-0.5);
    hf_sz2d=floor(size(prob.filts,2)/2-0.5);
    
    y=prob.y;
    k=prob.k;
    
%%    
    init_iv=prob.p_precision;
    
%%    
         
    da1=1/sig_noise^2*conv2fft(ones(N1,N2),abs(k).^2,'full');
    
    use_prev_x=(~prob.init_x_every_itr)&(~isempty(prob.x))&(L>1);
    
    for j0=1:N4
      if (use_prev_x)
        x=prob.x(:,:,j0);
        xcov=prob.xcov{j0};
      end
      %solve for x using conj gradient

      for itr=1:5  
        if (itr==1)&(~use_prev_x)     
            
            for n3 = 1:N3
                w(:,:,n3) = init_iv*ones(sM1,sM2);
                prob.qfilts(:,:,n3) = prob.filts(:,:,n3);
            end         
            
        else
            
            clear ex2
            orthVect=zeros(1,9);
            orthVect=orthVect';

            for j=1:N3
              
             for t=1:3    
              filtx(:,:,j)=conv2(x,flp(prob.qfilts(:,:,j)),'valid');
              filtxcov(:,:,j)=conv2(xcov,flp(prob.qfilts(:,:,j)).^2,'valid');
             
              ex2(:,:,j)= filtx(:,:,j).^2+filtxcov(:,:,j);

              %updating presion
              w(:,:,j) = 1./ex2(:,:,j);
         
              % updating fliters              
              [prob.qfilts(:,:,j),u]= Rotation3(x,xcov,w(:,:,j),prob,orthVect,j);  
             end
              orthVect=[orthVect u];            
              clear Tex2
            end
            
           

            %%
        end
       
           [x]=conjgrad_deconv_i(y(:,:,j0),prob.k,sig_noise^2,prob.iterN,prob.qfilts,w);        
        
        da2=zeros(M1,M2);
        
        for j=1:N3
           da2=da2+1/N3*conv2(w(:,:,j),flp(prob.qfilts(:,:,j)).^2,'full');
        end
        
       da2 = da2 + 1/N3*1e-8;
        
        xcov=zeros(M1,M2);
        xcov(hf_sz1u+1:end-hf_sz1d,hf_sz2u+1:end-hf_sz2d)=...
            1./(da1(hf_sz1u+1:end-hf_sz1d,hf_sz2u+1:end-hf_sz2d)+da2(hf_sz1u+1:end-hf_sz1d,hf_sz2u+1:end-hf_sz2d));
       
      end               
      prob.x(:,:,j0)=x; prob.xcov{j0}=xcov;    
    end
    
return
     
    
    