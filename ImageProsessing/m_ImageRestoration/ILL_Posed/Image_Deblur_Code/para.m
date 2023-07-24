function [kurt lambda_grad_min saturation] = para(yg)
%%
%%   Parameters: 
%%   Input:
%     @yg: Input blurred image.
%%   Output:
%     @kurt: Kurtosis of input blurred image.
%     @bigkurt: The flag of big kurtosis.
%     @saturation: The flag of saturation.
%%
    kurt = (kurtosis(yg(:)));
    saturation = 0;
    [m,n] = size(yg);
    pixsum = sum(sum(yg));
    pixaverage = pixsum/m/n;
    t = yg>0.75;
    pixlightsum = sum(sum(t));
    lambda_grad_min = 2e-4;
    if(pixlightsum>0.02*pixsum && kurt>4 && pixaverage<0.3)
        saturation = 1;
%         kurt = kurt*2;
        kurt = min(kurt,4);
        lambda_grad_min = 4e-4;
    end
    if ( ( kurt > 4 ) && (saturation == 0) )
        kurt = min(kurt,4);
        lambda_grad_min = 4e-4;
    end
end