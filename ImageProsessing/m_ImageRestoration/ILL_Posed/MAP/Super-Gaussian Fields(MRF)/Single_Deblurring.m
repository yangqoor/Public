function [prob,kList]=Single_Deblurring(prob,threshold,Scaleitr)
    

    for itr=1:5  
        %update image 
        prob=Learning_image(prob) ; 
        sprintf('itr=%02d for learning image',itr)
        
        %update k distribution 
        [latent_x, latent_y, threshold]= threshold_pxpy_v1(prob.x,max(size(prob.k)),threshold); 
        prob=Learning_kernel(prob,latent_x, latent_y,Scaleitr);
     
        %update noise
        prob=update_noise(prob);
       
        if (nargout>1)
           kList(:,:,itr)=prob.k;
        end
       
    end
end