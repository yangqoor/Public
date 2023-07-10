function [angle] = processingChain_angleFFTE(objDprIndex,objRagIndex,Sig_fft2D,lambda,d)

    angleFFTNum = 180;
    NObject = length(objDprIndex);  %检测的物体数目
    %初始化一个二维数组存放FFT结果
    
    angleFFTOut = single(zeros(NObject,angleFFTNum));
    
    for i=1:NObject
        frameData(1,:) = Sig_fft2D(objRagIndex(i),objDprIndex(i),:);   
      
        if(abs(frameData(1))>abs(frameData(2)))
            fai =  atan( imag(frameData(1))/real(frameData(1)))- atan( imag(frameData(2))/real(frameData(2)));
        else
            fai =  atan( imag(frameData(2))/real(frameData(2)))- atan( imag(frameData(1))/real(frameData(1))) ;
        end
        
        angle(i)  =asin((fai*lambda)/(2*3.14*d));
    end
    

end