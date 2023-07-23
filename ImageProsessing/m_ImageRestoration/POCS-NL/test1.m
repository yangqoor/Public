psf=fspecial('gaussian',[11,11],5);
psf1=padarray(psf,[256,256]-size(psf),'post');
P1=fft2(psf1);

psf_line=psf1';
psf_line=transpose(psf_line(:));
P2=fft(psf_line);
P3=reshape(P2,size(P1));

delta=abs(P3-P1);

