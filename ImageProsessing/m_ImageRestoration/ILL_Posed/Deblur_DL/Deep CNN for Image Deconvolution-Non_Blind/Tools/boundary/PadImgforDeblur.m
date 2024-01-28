function [padimg, ypadpre, ypadpost,xpadpre, xpadpost] = PadImgforDeblur(FBImg, PSF, method)

    [imH, imW] = size(FBImg);
    [kH, kW] = size(PSF);
    ypadpre = floor(imH/2);
    ypadpost = imH-ypadpre;
    xpadpre = floor(imW/2);
    xpadpost = imW-xpadpre;
%     
%     ypadpre = imH;
%     ypadpost = imH;
%     xpadpre = imW;
%     xpadpost = imW;

    switch lower(method)
        case {'replicate','circular', 'symmetric'}
           padimg = padarray(FBImg, [ypadpre,xpadpre], method,'pre');
           padimg = padarray(padimg, [ypadpost,xpadpost], method,'post');
        case {'replicate2','circular2', 'symmetric2' }           
           ypadpre = kH;
           ypadpost = kH;
           xpadpre = kW;
           xpadpost = kW;            
           method = method(1:end-1);
           padimg = padarray(FBImg, [ypadpre,xpadpre], method,'pre');
           padimg = padarray(padimg, [ypadpost,xpadpost], method,'post');
        case 'zero'
           padimg = padarray(FBImg, [ypadpre,xpadpre], 0, 'pre');
           padimg = padarray(padimg, [ypadpost,xpadpost], 0, 'post');
        case 'antisymmetric'
           padimg = mypadarray(FBImg, [ypadpre,xpadpre], 'antisymmetric','pre');
           padimg = mypadarray(padimg, [ypadpost,xpadpost], 'antisymmetric','post'); 
        case 'antisymmetric2'
           ypadpre = kH;
           ypadpost = kH;
           xpadpre = kW;
           xpadpost = kW;    
           padimg = mypadarray(FBImg, [ypadpre,xpadpre], 'antisymmetric','pre');
           padimg = mypadarray(padimg, [ypadpost,xpadpost], 'antisymmetric','post'); 
        case 'ramp'
           [padimg,padSize] = myPrdPadding1( FBImg , PSF );
           ypadpre = padSize; ypadpost = padSize;
           xpadpre = padSize; xpadpost = padSize;
        case 'ramp2'
           [padimg,padSize] = myPrdPadding1( FBImg , PSF );
           ypadpre = floor(padSize/2);
           ypadpost = padSize-ypadpre;           
           xpadpre = floor(padSize/2);
           xpadpost = padSize-xpadpre;           
           padimg = padimg(1+ypadpost:end-ypadpre,1+xpadpost:end-xpadpre,:);
        case 'ramp3'
           [padimg, ypadpre, ypadpost,xpadpre, xpadpost] = LaplacianPadding(FBImg, PSF, 0);
        case 'edgetaper'
           padimg = edgetaper(FBImg,PSF);
           ypadpre = 0; ypadpost = 0;
           xpadpre = 0; xpadpost = 0;           
        case 'edgetaper2'
           padimg = padarray(FBImg, [ypadpre,xpadpre], 'replicate','pre');
           padimg = padarray(padimg, [ypadpost,xpadpost], 'replicate','post');
           padimg = edgetaper(padimg,PSF);
        case 'edgetaper3'
           padimg = edgetaper(FBImg,PSF); 
           [padimg,padSize] = myPrdPadding1( padimg , PSF );
           ypadpre = floor(padSize/2);
           ypadpost = padSize-ypadpre;           
           xpadpre = floor(padSize/2);
           xpadpost = padSize-xpadpre;           
           padimg = padimg(1+ypadpost:end-ypadpre,1+xpadpost:end-xpadpre,:);
        otherwise
           disp('Unknown method.'); 
    end

end