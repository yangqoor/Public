function [prob,kList,freeeng]=deconv1(prob,sig_noise_v)
    
     
    maxItr=length(sig_noise_v);
   
    for itr=1:maxItr
       %we modify the noise variance in each iteration we start
       %from a higher noise variance because EM algorithms usually
       %converge faster at high noise. The high noise iterations
       %mostly resolve the low frequencies of the kernel, and then 
       %we reduce the noise parameter and high freqs get in.
       prob.sig_noise=sig_noise_v(itr);
  
       %update x distribution 
       
       if (strcmp(prob.update_x,'conjgrad')&strcmp(prob.covtype,'diag')&(prob.filt_space==1))
         prob=update_x_conjgrad_diagfe_filt_space(prob) ; 
       end
       if (strcmp(prob.update_x,'conjgrad')&strcmp(prob.covtype,'smp')&(prob.filt_space==1))
         prob=update_x_conjgrad_smp_filt_space(prob) ; 
       end
       if (strcmp(prob.update_x,'conjgrad')&strcmp(prob.covtype,'diag')&(prob.filt_space==0))
         prob=update_x_conjgrad_diagfe_img_space(prob) ; 
       end
       if (strcmp(prob.update_x,'freqdeconv')&(prob.filt_space==1))
         prob=update_x_freqdeconv_filt_space(prob);
       end
       if (strcmp(prob.update_x,'freqdeconv')&(prob.filt_space==0))
         prob=update_x_freqdeconv_img_space(prob);
       end
       
       %print free energy
       sprintf('itr=%02d, free eng after x update: %f',itr,  prob.freeeng)
       if (nargout>2)
           freeeng(1,itr)=prob.freeeng;
       end
       
       %update k distribution 
       prob=update_k(prob);
       
       %print free energy
       sprintf('itr=%02d, free eng after k update: %f',itr,  prob.freeeng)
       if (nargout>2)
           freeeng(2,itr)=prob.freeeng;
       end
       
       if (nargout>1)
           kList(:,:,itr)=prob.k;
       end
       
    end
    
    
