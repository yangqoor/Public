function  [Sig_fft2D]=RangeDopplerProcessing(SigReshape,Nfft1,Nfft2,NTx,NRx,win1,win2)
    
    SigReshape=SigReshape.*win1;
    startIndx=1;
    Sig_fft1D=fft(SigReshape(startIndx:end,:),Nfft1,1);    %每列FFT，1D FFT
    
    
%     
%     figure
%     plot(abs(Sig_fft1D(:,1)))

    
%% 静态杂波滤除
    fft1d_jingtai = zeros(96,96,12);
    for n=1:8
        avg = sum(fft1d(:,:,n))/96;

        for chirp=1:128
            fft1d_jingtai(chirp,:,n) = fft1d(chirp,:,n)-avg;
        end
    end
    figure;
    mesh(X,Y,abs(fft1d_jingtai(:,:,1)));
    

end