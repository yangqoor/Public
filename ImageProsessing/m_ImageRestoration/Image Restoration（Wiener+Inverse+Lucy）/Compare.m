function [absdiff, snr, psnr, imfid, mse] = compare(originalimg, restoredimg)

md = originalimg - restoredimg;
mdsize = size(md);
summation = 0;
for i = 1:mdsize(1);
    for j = 1:mdsize(2);
        summation = summation + abs(md(i,j));
    end
end

absdiff = summation/(mdsize(1)*mdsize(2));
%}


%Signal to Noise Ratio (SNR)
%{
md = (originalimg - restoredimg).^2;
mdsize = size(md);
summation = 0;
sumsq=0;
for  i = 1:mdsize(1);
    for j = 1:mdsize(2);
        summation = summation + abs(md(i,j));
        sumsq = sumsq + (originalimg(i,j)^2);
    end
end

snr = sumsq/summation;
snr = 10 * log10(snr);
%}


%Peak Signal to Noise Ratio (PSNR)
%{
md = (originalimg - restoredimg).^2;
mdsize = size(md);
summation = 0;
sumsq=0;
for  i = 1:mdsize(1);
    for j = 1:mdsize(2);
        summation = summation + abs(md(i,j));
    end
end

psnr = size(originalimg, 1) * size(originalimg, 2) * max(max(originalimg.^2))/summation;
psnr = 10 * log10(psnr);
%}


%Image Fidelity

md = (originalimg - restoredimg).^2;
mdsize = size(md);
summation = 0;
sumsq = 0;
for  i = 1:mdsize(1);
    for j = 1:mdsize(2);
        summation = summation + abs(md(i,j));
        sumsq = sumsq + (originalimg(i,j)^2);
    end
end

imfid = (1-summation)/sumsq;
%}


%Mean Square Error
%{
diff = originalimg - restoredimg;
diff1 = diff.^2;
mse = mean(mean(diff1));
%}