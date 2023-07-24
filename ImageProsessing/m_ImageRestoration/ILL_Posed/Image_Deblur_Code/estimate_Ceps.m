function [PSF m n]= estimate_Ceps(S)
    dx = [-1 0 1; -2 0 2;-1 0 1];
    dy = dx';
    Bx = conv2(S, dx, 'valid');
    By = conv2(S, dy, 'valid');

    fft2y = fftshift(abs(fft2(By)));
    fft2x = fftshift(abs(fft2(Bx)));
    logfft2y = abs(log(1+fft2y));
    logfft2x = abs(log(1+fft2x));
    logfft2y = logfft2y.*logfft2y;
    logfft2x = logfft2x.*logfft2x;
    Cepsy = ifftshift(ifft2(((logfft2y))));
    Cepsx = ifftshift(ifft2(((logfft2x))));
    Ceps = (abs(Cepsx+Cepsy)).^0.5;
%     fft2a = fftshift(abs(fft2(S)));
%     logfft2 = abs(log(1+fft2a));
%     logfft2 = logfft2.*logfft2;
%     Ceps = ifftshift(ifft2(((logfft2))));
%     Ceps = (abs(Ceps+Ceps)).^0.5;

    C_max = max(Ceps(:));
    Ceps = Ceps/C_max;
    C_find = find(Ceps>0.03);
    Cepstrum = zeros(size(Ceps));
    [m,n] = size(Ceps);
    Cepstrum(C_find) = 1;

    idxStrong = find(Ceps>0.12);
    rstrong = rem(idxStrong-1, m)+1;
    cstrong = floor((idxStrong-1)/m)+1;
    Cepstrum = bwselect(Cepstrum, cstrong, rstrong, 8);
    Cepstrum = (Cepstrum.*Ceps).^0.5;

    index = find(Cepstrum>0);
    r = rem(index-1, m)+1;
    c = floor((index-1)/m)+1;
    r_min = min(r);r_max = max(r);
    c_min = min(c);c_max = max(c);
    r_min = int32(max(3*m/8,r_min));
    r_max = int32(min(5*m/8,r_max));
    c_min = int32(max(3*n/8,c_min));
    c_max = int32(min(5*n/8,c_max));

    m = r_max - r_min;
    n = c_max - c_min;
    if(m/n>3.8||n/m>3.8)
        if(m>n)
            c_max = c_max + n;
            c_min = c_min - n;
        else
            r_max = r_max + m;
            r_min = r_min - m;
        end
    end

    PSF = Cepstrum(r_min:r_max,c_min:c_max);
    [m n] = size(PSF);
    C_find = find(PSF<0.08);
    PSF(C_find) = 0;
end