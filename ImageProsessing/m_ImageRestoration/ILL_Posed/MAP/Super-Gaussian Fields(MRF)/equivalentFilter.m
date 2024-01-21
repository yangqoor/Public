function [K2]=equivalentFilter(ws,siz)
% find a single filter whose power spectrum is the same
% as the average of ws

isize=128;

 im1=zeros(isize);
      im1(round(isize/2),round(isize/2))=1;
        
        imTotal=0;
        
        for i=1:size(ws,2)
            K=reshape(ws(:,i),siz);
            imNew=conv2(im1,K,'same');
            imNew=conv2(imNew,flipud(fliplr(K)),'same');
            imTotal=imTotal+imNew;
        end
        
        % and now find K such that conv(K,K)=imTotal;
        Khat=fft2(imTotal);
        K2=(ifft2(sqrt(abs(Khat))));
       K2=fftshift(K2); % move to center
     
        cc=round(size(K2)/2);
    K2=K2(cc(1)-floor(siz(1)/2):cc(1)+floor(siz(1)/2), ...
        cc(2)-floor(siz(2)/2):cc(2)+floor(siz(2)/2));
        