function  [Sig_fft2D]=RangeDopplerProcessing(SigReshape,Nfft1,Nfft2,NTx,NRx,win1,win2)
    
    SigReshape=SigReshape.*win1;
    startIndx=1;
    Sig_fft1D=fft(SigReshape(startIndx:end,:),Nfft1,1);    %每列FFT，1D FFT
    
    
%     
%     figure
%     plot(abs(Sig_fft1D(:,1)))



    for i=1:NTx*NRx
        temp=Sig_fft1D(1:Nfft1,(i-1)*Nfft2+1 : i*Nfft2);
%         temp=Sig_fft1D(1:Nfft1/2,i:NTx*NRx:end);%抽出某一个天线数据所有chirp的数据      
        temp=temp.*win2;       
        Sig_fft2D(:,:,i)=fftshift(fft(temp,Nfft2,2),2);    %每页一个天线数据
          
    end   

end