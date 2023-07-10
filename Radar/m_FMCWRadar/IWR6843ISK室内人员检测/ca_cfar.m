
function [cfar1D_Arr,threshold] = ca_cfar(NTrain,NGuard,PFA,inputArr)
    inputArr =abs(inputArr);
    cfar1D_Arr = zeros(size(inputArr));
    threshold = zeros(size(inputArr));

    a =PFA;
    %求平均值
    for i = NTrain+NGuard+1:length(inputArr)-NTrain-NGuard
        avg = min(mean([inputArr((i-NTrain-NGuard):(i-NGuard-1)) inputArr((i+NGuard+1):(i+NTrain+NGuard))]));
        threshold(1,i) = a.*avg;
        %根据threshold比较
        if(inputArr(i) < threshold(i))
            cfar1D_Arr(i) = 0;
        else
            cfar1D_Arr(i) = 1;
        end
    end
    
end