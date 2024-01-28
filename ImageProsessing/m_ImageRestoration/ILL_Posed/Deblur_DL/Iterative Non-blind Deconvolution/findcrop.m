function [ bestcrop ] = findcrop(target,img,yoffset,xoffset,search_size)
% find the target crop in img
% starting offset given, search +/- search size from there
% return bestcrop in img that is argmin MSE(imgcrop,target)
minMSE=Inf;
bestcrop=[];

[hh ww]=size(target);

for yy=yoffset-search_size:yoffset+search_size
    for xx=xoffset-search_size:xoffset+search_size

        imgcrop=img(yy:yy+hh-1,xx:xx+ww-1);
        currMSE=mean2((imgcrop-target).^2);
        if currMSE<minMSE
            minMSE=currMSE;
            bestcrop=imgcrop;
        end
    end
    
end


end

