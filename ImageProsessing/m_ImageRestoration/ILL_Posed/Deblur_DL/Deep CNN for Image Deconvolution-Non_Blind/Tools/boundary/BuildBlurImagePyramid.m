function [imgpyr, szkerpyr, nlevel, scalefactor] = BuildBlurImagePyramid(FBImg, kH, kW, scalefactor, nlevel)

if nargin < 4
    scalefactor = 0.618;
end

if nargin < 5
    nlevel = ceil(1+(log(3.0)-log(max(kW,kH)) )./ log(scalefactor));
%     nlevel = ceil( -log( max(kW,kH))./( log(scalefactor) ) );
%     nlevel = nlevel - 1;
end


imgpyr = cell( nlevel , 1 );
for ilevel=1:nlevel 
   timg = imresize( FBImg , scalefactor.^(ilevel-1) , 'bilinear');
   timg(timg<0) = 0;
   timg(timg>1) = 1;
   imgpyr{ilevel} = timg;        
end

%% 
szkerpyr = cell( nlevel , 1 );
for ilevel=1:nlevel 
   tkH = ceil(kH*scalefactor.^(ilevel-1));
   tkW = ceil(kW*scalefactor.^(ilevel-1));     
   tkH = max(3,tkH);
   tkW = max(3,tkW);   
   if(mod(tkH,2)==0)
       tkH=tkH+1;
   end
   if(mod(tkW,2)==0)
       tkW=tkW+1;
   end   
   szkerpyr{ilevel} = [tkH,tkW];        
end