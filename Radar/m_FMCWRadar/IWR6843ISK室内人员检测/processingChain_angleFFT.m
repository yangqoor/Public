function [angle] = processingChain_angleFFT(objDprIndex,objRagIndex,Sig_fft2D)

    global S_MUSIC1;
    angleFFTNum = 256;
    NObject = length(objDprIndex);  %检测的物体数目,点迹
  
    %初始化一个二维数组存放FFT结果
    angleFFTOut = single(zeros(NObject,angleFFTNum));
    for i=1:NObject
        
        %%
        frameData(1,:) = Sig_fft2D(objRagIndex(i),objDprIndex(i),:);  
        % 有个问题，这里到底是几个点的FFT
        
        frameFFTData = fftshift(fft(frameData, angleFFTNum));      %进行NChan点的angler-FFT
                                                                   %fftshift移动零频点到频谱中间  不是很懂
                                                                   %有+Π 和 -Π
%          figure(1);                                                          
%          plot(abs(frameFFTData));
%          pause();
         
        angleFFTOut(i,:) = frameFFTData(1,:);   %把FFT的结果放入angleFFTOut
        maxIndex= find(abs(angleFFTOut(i,:))==max(abs(angleFFTOut(i,:))));
%         angle1 (i)= asin((maxIndex - angleFFTNum/2 - 1)*2/angleFFTNum) * 180/pi;
        
       %% MUSIC DOA估计
        angle (i) =doa_music( frameData(1,:)');
%       angle_music_max =  max(angle_music);

    end  
end