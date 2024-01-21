function prob=Learning_kernel(prob,latent_x, latent_y,Scaleitr)
    
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
    Bx = conv2(blur_B_tmp, dx, 'valid');
    By = conv2(blur_B_tmp, dy, 'valid');
    

    k = flp(estimate_psf(Bx, By, latent_x, latent_y, 20, [k_sz1,k_sz2]));
     
    
    if Scaleitr<0
        disp('do not pruning isolated noise at the finest Scale')
       CC = bwconncomp(k,8);
      for ii=1:CC.NumObjects
          currsum=sum(k(CC.PixelIdxList{ii}));
           if currsum<0.01; 
              k(CC.PixelIdxList{ii}) = 0;
          end
      end
    else
    fprintf('pruning isolated noise in kernel...\n');
      CC = bwconncomp(k,8);
      for ii=1:CC.NumObjects
          currsum=sum(k(CC.PixelIdxList{ii}));
           if currsum<0.08; 
              k(CC.PixelIdxList{ii}) = 0;
          end
      end
    end
    k=k/sum(k(:)); 
    k = reshape(k,k_sz1,k_sz2);
    prob.k=(k);
    
  figure(1); 
  prob.x(prob.x<0) = 0;
  prob.x(prob.x>1) = 1;
  subplot(1,3,1); imshow(y,[]); title('Blurred image');
  subplot(1,3,2); imshow(prob.x,[]);title('Interim latent image');
  subplot(1,3,3); imshow(flp(k),[]);title('Estimated kernel');
  drawnow;