function prob=update_k2(prob)
    
     k_sz1=prob.k_sz1;
     k_sz2=prob.k_sz2;
     

     x=prob.x;
     xcov=prob.xcov;
     y=prob.y;
       
    % derivative filters
    dx = [-1 1; 0 0];
    dy = [-1 0; 1 0];
    %%
    H = size(y,1);    W = size(y,2);
    blur_B_w = wrap_boundary_liu(y, opt_fft_size([H W]+[k_sz1,k_sz2]-1));
    blur_B_tmp = blur_B_w(1:H,1:W,:);
    
    for i=1:8
       
        By(:,:,i) = conv2(blur_B_tmp, flp(prob.qfilts(:,:,i)), 'valid');

        latent_x(:,:,i) = conv2(x, flp(prob.qfilts(:,:,i)), 'valid');
        
    end
    k = estimate_psf2( By, latent_x, 20, [k_sz1,k_sz2]);
     
    fprintf('pruning isolated noise in kernel...\n');
      CC = bwconncomp(k,8);
      for ii=1:CC.NumObjects
          currsum=sum(k(CC.PixelIdxList{ii}))
          if currsum<0.08
              k(CC.PixelIdxList{ii}) = 0;
          end
      end
    k(k<0) = 0;
    k=k/sum(k(:)); 
    k = reshape(k,k_sz1,k_sz2);
    prob.k=flp(k);
      figure(1); 
  prob.x(prob.x<0) = 0;
  prob.x(prob.x>1) = 1;
  subplot(1,3,1); imshow(y,[]); title('Blurred image');
  subplot(1,3,2); imshow(prob.x,[]);title('Interim latent image');
  subplot(1,3,3); imshow((k),[]);title('Estimated kernel');
  drawnow;
     %recompute free energy
     %%
%      for j=1:size(x,3)
%         prob.freeeng_qlogp_ycx(j)=1/(2*sig_noise^2)*(k'*AL{j}*k-2*k'*bL{j}+cL{j} ); 
%      end
% 
% 
%      prob.freeeng=sum(prob.freeeng_qlogp_ycx)+sum(prob.freeeng_qlogp_x)...
%                  +sum(prob.freeeng_qpilogqpi)+sum(prob.freeeng_qxlogqx);
    %%