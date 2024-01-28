function outIm = DL_deblur(blurImg, kernel, net, lambda)

    h = size(blurImg,1); w = size(blurImg,2);

    
 
    grad1 = gpuArray([0,0,0;0,1,-1;0,0,0]);
    grad2 = gpuArray([0,0,0;0,1,0;0,-1,0]);
 
    

    gradF = single(cat(3, psf2otf(grad1,[h,w]), psf2otf(grad2,[h,w])));
    
    
    kernelF = single(psf2otf(kernel, [h,w]));
    
    deconvDemon1 = kernelF.*conj(kernelF);
    deconvDemon2 = gradF(:,:,1).*conj(gradF(:,:,1)) + gradF(:,:,2).*conj(gradF(:,:,2));   
    
    
    blurImgF = fft2(blurImg);

    deconvImgF = deconv(blurImgF, gpuArray(zeros(h,w,2,'single')), kernelF, gradF, deconvDemon1, deconvDemon2, lambda(1)); % deconv1
    
    deconvImgGrad1_1 = deconvImgF .* gradF(:,:,1);
    deconvImgGrad1_1 = real(ifft2(deconvImgGrad1_1)); 
    deconvImgGrad2_1 = deconvImgF .* gradF(:,:,2);
    deconvImgGrad2_1 = real(ifft2(deconvImgGrad2_1));   

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% conv1
     
    deconvImgGrad2_1 = deconvImgGrad2_1';
  
    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(1,1).w, net(1,1).b, 'pad', [2,2,2,2], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(1,1).w, net(1,1).b, 'pad', [2,2,2,2], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(1,2).w, net(1,2).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(1,2).w, net(1,2).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(1,3).w, net(1,3).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(1,3).w, net(1,3).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(1,4).w, net(1,4).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(1,4).w, net(1,4).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(1,5).w, net(1,5).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(1,5).w, net(1,5).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(1,6).w, net(1,6).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(1,6).w, net(1,6).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    
    deconvImgGrad2_1 = deconvImgGrad2_1';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   
    deconvImgF = deconv(blurImgF, cat(3,deconvImgGrad1_1,deconvImgGrad2_1), kernelF, gradF, deconvDemon1, deconvDemon2, lambda(2)); % deconv2
    
    deconvImgGrad1_1 = deconvImgF .* gradF(:,:,1);
    deconvImgGrad1_1 = real(ifft2(deconvImgGrad1_1)); 
    deconvImgGrad2_1 = deconvImgF .* gradF(:,:,2);
    deconvImgGrad2_1 = real(ifft2(deconvImgGrad2_1));

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% conv2
     
    deconvImgGrad2_1 = deconvImgGrad2_1';
  
    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(2,1).w, net(2,1).b, 'pad', [2,2,2,2], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(2,1).w, net(2,1).b, 'pad', [2,2,2,2], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(2,2).w, net(2,2).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(2,2).w, net(2,2).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(2,3).w, net(2,3).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(2,3).w, net(2,3).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(2,4).w, net(2,4).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(2,4).w, net(2,4).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(2,5).w, net(2,5).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(2,5).w, net(2,5).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(2,6).w, net(2,6).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(2,6).w, net(2,6).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    
    deconvImgGrad2_1 = deconvImgGrad2_1';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   
    deconvImgF = deconv(blurImgF, cat(3,deconvImgGrad1_1,deconvImgGrad2_1), kernelF, gradF, deconvDemon1, deconvDemon2, lambda(3)); % deconv4
    
    deconvImgGrad1_1 = deconvImgF .* gradF(:,:,1);
    deconvImgGrad1_1 = real(ifft2(deconvImgGrad1_1)); 
    deconvImgGrad2_1 = deconvImgF .* gradF(:,:,2);
    deconvImgGrad2_1 = real(ifft2(deconvImgGrad2_1));

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% conv3
     
    deconvImgGrad2_1 = deconvImgGrad2_1';
  
    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(3,1).w, net(3,1).b, 'pad', [2,2,2,2], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(3,1).w, net(3,1).b, 'pad', [2,2,2,2], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(3,2).w, net(3,2).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(3,2).w, net(3,2).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(3,3).w, net(3,3).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(3,3).w, net(3,3).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(3,4).w, net(3,4).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(3,4).w, net(3,4).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(3,5).w, net(3,5).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad1_1 = vl_nnrelu(deconvImgGrad1_1, [], 'leak', 0.0);
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(3,5).w, net(3,5).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnrelu(deconvImgGrad2_1, [], 'leak', 0.0);

    deconvImgGrad1_1 = vl_nnconv(deconvImgGrad1_1, net(3,6).w, net(3,6).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    deconvImgGrad2_1 = vl_nnconv(deconvImgGrad2_1, net(3,6).w, net(3,6).b, 'pad', [1,1,1,1], 'stride', [1,1], 'cuDNN');
    
    deconvImgGrad2_1 = deconvImgGrad2_1';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   
    deconvImgF = deconv(blurImgF, cat(3,deconvImgGrad1_1,deconvImgGrad2_1), kernelF, gradF, deconvDemon1, deconvDemon2, lambda(4)); % deconv4
    
    outIm = real(ifft2(deconvImgF));
    
end

function deconvImgF = deconv(blurImgF, guideGrad, kernelF, gradF, deconvDemon1, deconvDemon2, lambda)
    reg = gpuArray(single(0.0001));
    
    deconvImgF = lambda*(blurImgF.*conj(kernelF)) +...
          fft2(guideGrad(:,:,1)).*conj(gradF(:,:,1)) +...
          fft2(guideGrad(:,:,2)).*conj(gradF(:,:,2));
    deconvImgF = deconvImgF ./ ( lambda*deconvDemon1 +...
          deconvDemon2 +...
          reg);  
end
