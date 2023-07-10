function printt (filename)

% PRINTT  prints current picture to file with tiff preview so 
%         it can be used by Powerpoint.
%
%         printt (filename)
%
%         prints to filename.eps (if filename already has .eps at 
%         end, prints to filename.)

N = length (filename);
if strcmp (filename (N-2:N), 'eps')
  filename = filename (1:N-3);
end;

filenameEPS = [filename '.eps'];
filenameJPG = [filename '.jpg'];

print (gcf, '-depsc', '-tiff', filenameEPS);
print (gcf, '-djpeg', filenameJPG);

