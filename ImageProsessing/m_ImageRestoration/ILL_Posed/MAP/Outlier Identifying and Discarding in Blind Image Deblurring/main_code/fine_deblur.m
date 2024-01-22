function [k, lambda_grad, S] = fine_deblur(blur_B, k, lambda_grad, threshold, opts)
for iter = 1:opts.xk_iter
    %%
    k_prev = k;
    [S,wi] = image_estimate(blur_B, k, lambda_grad,0);
    [k,wk] = psf_fine(blur_B, S, 5, k, threshold,0);
    err = k_prev - k;
    if norm(err(:),2)<1e-3;
        break;
    end
  %%
  fprintf('pruning isolated noise in kernel...\n');
  CC = bwconncomp(k,8);
  for ii=1:CC.NumObjects
      currsum=sum(k(CC.PixelIdxList{ii}));
      if currsum<.1 
          k(CC.PixelIdxList{ii}) = 0;
      end
  end
  k(k<0) = 0;
  k=k/sum(k(:));
  if mod(iter,5) == 0
      fprintf('%d iterations...\n', iter);
      k = adjust_psf_center(k);
      k(k(:)<0) = 0;
      sumk = sum(k(:));
      k = k./sumk;
      if opts.k_thresh>0
        k(k(:) < max(k(:))/opts.k_thresh) = 0;
      else
        k(k(:) < 0) = 0;
      end
        k = k / sum(k(:));
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%
  figure(1); 
  S(S<0) = 0;
  S(S>1) = 1;
  subplot(2,3,1); imshow(blur_B,[]); title('Blurred image');
  subplot(2,3,2); imshow(S,[]);title('Interim latent image');
  subplot(2,3,3); imshow(k,[]);title('Estimated kernel');
  subplot(2,3,4); imshow(wi,[]);title('Weight for image');
  subplot(2,3,5); imshow(wk,[]);title('Weight for kernel');
  drawnow;
end;
k(k<0) = 0;  
k = k ./ sum(k(:));
