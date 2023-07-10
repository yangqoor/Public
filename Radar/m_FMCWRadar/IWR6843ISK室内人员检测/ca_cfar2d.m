function [cfar1D_Arr,threshold,outSNR] = ca_cfar2d(NTrain,NGuard,PFA,inputArr)
    cfar1D_Arr = zeros(size(inputArr));
    outSNR = zeros(size(inputArr));
    threshold = zeros(size(inputArr));

    totalNTrain = 2*(NTrain);
    a =PFA;
    %求平均值
    
    for i = NTrain+NGuard+1:length(inputArr)-NTrain-NGuard
        
        avg = mean([inputArr((i-NTrain-NGuard):(i-NGuard-1))   inputArr((i+NGuard+1):(i+NTrain+NGuard))]);
        threshold(1,i) = a.*avg;
        
      
        %根据threshold比较
        if(inputArr(i) < threshold(i))
            cfar1D_Arr(i) = 0;
            outSNR(i)=0;
        else
            cfar1D_Arr(i) = inputArr(i);
         
            outSNR(i) = inputArr(i)/avg;      
        end
 
    end
    
end