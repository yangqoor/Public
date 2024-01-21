function prob=update_noise(prob)
    
     k_sz1=prob.k_sz1;
     k_sz2=prob.k_sz2;

     x=prob.x;
     xcov=prob.xcov{1};
     y=prob.y;
     kx = conv2fft(x,flp(prob.k),'valid');
     kxcov=conv2fft(xcov,flp(prob.k).^2,'valid');

     
     prob.sig_noise = sum((y(:)-kx(:)).^2+kxcov(:))/(size(y,1)*size(y,2));
     prob.sig_noise = sqrt(prob.sig_noise+1e-4);


end