function PSF = Error_Ceps(Bx,By,m1,n1)

    fft2y = fftshift(abs(fft2(By)));
    fft2x = fftshift(abs(fft2(Bx)));

    logfft2y = abs(log(1+fft2y));
    logfft2x = abs(log(1+fft2x));
    
    Cepsy = ifftshift(ifft2(logfft2y));
    Cepsx = ifftshift(ifft2(logfft2x));
    
	Ceps = conj(Cepsx).* Cepsx + conj(Cepsy).* Cepsy;
	[m,n] = size(Ceps);
	PSF = (Ceps(floor(m/2-m1/2):floor(m/2+m1/2),floor(n/2-n1/2):floor(n/2+n1/2))).^0.5;
end