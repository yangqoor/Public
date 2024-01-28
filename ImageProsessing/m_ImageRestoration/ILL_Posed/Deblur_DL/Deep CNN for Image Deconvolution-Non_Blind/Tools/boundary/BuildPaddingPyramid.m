function [imgpyr, padimgpyr, kerpyr, nlevel, scalefactor] = BuildPaddingPyramid(FBImg, kernel, scalefactor, nlevel)

[kH, kW] = size(kernel);
if ~exist('scalefactor','var')
    scalefactor = 0.618;
end
if ~exist('nlevel','var');
    nlevel = ceil(1+(log(3.0)-log(max(kW,kH)) )./ log(scalefactor));
end

imgpyr = cell( nlevel , 1 );
for ilevel=1:nlevel 
   timg = imresize( FBImg , scalefactor.^(ilevel-1) , 'bilinear');
   timg(timg<0) = 0;
   timg(timg>1) = 1;
   imgpyr{ilevel} = timg;        
end

affectfactor = 1;
padimgpyr = cell( nlevel, 1 );
%ypad = kH*affectfactor*2;
%xpad = kW*affectfactor*2;
ypad = kH*affectfactor*1;
xpad = kW*affectfactor*1;

padimg = zeros(size(FBImg,1)+ypad, size(FBImg,2)+xpad, size(FBImg,3));
for ilevel=1:nlevel 
   tpimg = imresize( padimg , scalefactor.^(ilevel-1) , 'bilinear');
   [ph,pw,d] = size(tpimg);
   [bh,bw,d] = size(imgpyr{ilevel});
   padimgpyr{ilevel} = [ph-bh, pw-bw, ph, pw];        
end


%% 

kerpyr = cell( nlevel , 1 );
for ilevel=1:nlevel 
%    tkH = ceil(kH*scalefactor.^(ilevel-1));
%    tkW = ceil(kW*scalefactor.^(ilevel-1));     
%    tkH = max(3,tkH);
%    tkW = max(3,tkW);   
%    if(mod(tkH,2)==0)
%        tkH=tkH+1;
%    end
%    if(mod(tkW,2)==0)
%        tkW=tkW+1;
%    end   
%    tker = imresize( kernel, [tkH, tkW], 'bilinear');
   tker = imresize( kernel, scalefactor.^(ilevel-1), 'bilinear');
   tker(tker<0) = 0;
   tker(tker>1) = 1;
   tker = tker/(sum(tker(:)));   
   kerpyr{ilevel} = tker;        
end