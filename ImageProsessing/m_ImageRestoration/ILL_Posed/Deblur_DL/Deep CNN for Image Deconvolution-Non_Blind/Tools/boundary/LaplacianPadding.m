function [padimg, ypadpre, ypadpost,xpadpre, xpadpost] = LaplacianPadding(FBImg, PSF, mode)

    affectfactor = 1;
    [kH,kW] = size(PSF);
    [M,N,D] = size(FBImg);
    
    if mode == 0
        ypad = kH*affectfactor*2;
        xpad = kW*affectfactor*2;
    elseif mode ==1
        [ypad, xpad] = ComputePaddingSize(PSF,affectfactor);
    else
        N1 = ceil(log(M)/log(2));
        N2 = ceil(log(N)/log(2));
        ypad = 2^N1-M;
        xpad = 2^N2-N;        
        [ypad1, xpad1] = ComputePaddingSize(PSF,affectfactor);
        ypad =max(ypad,ypad1);
        xpad =max(xpad,xpad1);
    end  
    
    
    padimg = zeros(M+2*ypad,N+2*xpad,D);
    for ch = 1:D
        padimg(:,:,ch) = DoLaplacianPadding(FBImg(:,:,ch), kH, kW, ypad, xpad);
    end
    
    ypadpre = floor(ypad/2);
    ypadpost = ypad-ypadpre;           
    xpadpre = floor(xpad/2);
    xpadpost = xpad-xpadpre;            
    padimg = padimg(1+ypadpost:end-ypadpre,1+xpadpost:end-xpadpre,:);  
end


function [ypad, xpad] = ComputePaddingSize(PSF,affectfactor)
    thresh = 0;
    [r,c] = find(PSF>thresh);
    ypad = max((max(r(:))-min(r(:))),1)*affectfactor*2;
    xpad = max((max(c(:))-min(c(:))),1)*affectfactor*2;
end