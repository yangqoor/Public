function [B, BLin,scaleFac, sliceSize] = loadImData_web(imNo)

%% image parameters
if(imNo == 7)
    sliceSize = 29;
        
elseif(imNo == 1)
    sliceSize = 15;
elseif(imNo == 2)

    sliceSize = 23;
elseif(imNo == 4)
  
    sliceSize = 17;
elseif(imNo == 6)

    sliceSize = 25;
elseif(imNo == 8)

    sliceSize = 23;
     

elseif(imNo == 9)
 
    sliceSize = 19; 
    
elseif(imNo == 10)
    sliceSize = 15;
    
elseif(imNo == 11)
    sliceSize = 23;
elseif(imNo == 12)
    sliceSize = 13; 
elseif(imNo == 16)
    sliceSize = 17;
   
elseif(imNo == 17)
    sliceSize = 19;
elseif(imNo == 18)
    sliceSize = 21;
    
elseif(imNo == 19)   
    sliceSize = 21;

elseif(imNo == 20)
    sliceSize = 21;
elseif(imNo == 21)
    sliceSize = 23;

elseif(imNo == 13)
    sliceSize = 25;
elseif(imNo == 14)
    sliceSize = 25;
elseif(imNo == 3)

    sliceSize = 21;
elseif(imNo == 15)

    sliceSize = 21;
elseif(imNo == 5)
    sliceSize = 17;
    
elseif(imNo == 22)
    sliceSize = 21;
elseif(imNo == 23)

    sliceSize = 25;
elseif(imNo == 24)

    sliceSize = 21;
elseif(imNo == 25)

    
    sliceSize = 17;
 
elseif(imNo == 26)
    
    sliceSize = 15; 
elseif(imNo == 27)
     
    sliceSize = 23; 
    
elseif(imNo == 28)
    
    sliceSize = 17;
    
elseif(imNo == 29)
   
    sliceSize = 15;       
   
elseif(imNo == 30)    
    sliceSize = 15; 

elseif(imNo == 31)

    sliceSize = 17;  
    
elseif(imNo == 32)
    
    sliceSize = 23; 
elseif(imNo == 33) 
     
    sliceSize = 23; 
elseif(imNo == 34) 
     
    sliceSize = 23; 
end

%% Loading routine 

pathIm = './testData_web/';

fileName = sprintf('%s%s%s%s', pathIm, num2str(imNo), '.tiff');

B = im2double(imread(fileName)); 

%% White balancing
imNorm = sqrt(mean(B.^2, 3));

[histImNormN, hC] = hist(imNorm(:), size(imNorm,1)*size(imNorm,2)/1000);
cumHistImNormN = cumsum(histImNormN);
cumHistImNormN = cumHistImNormN/cumHistImNormN(end);

pcFindC = 0;
flagL = 0; 
while(flagL == 0)
    pcFindC = pcFindC + 1;
    if(cumHistImNormN(pcFindC) > 0.98)%82)
        flagL = 1;
        pix = hC(pcFindC);
    end
end  

diff = abs(imNorm - pix);
[ii,jj] = find(diff == min(diff(:)));
scaleFac = B(ii(1), jj(1), :);

BLin = B./repmat(scaleFac, [size(B, 1), size(B, 2)]);

