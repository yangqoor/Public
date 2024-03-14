%% Guided Image filtering on grayscale image
%Based on the implementation
%        Kaiming He, Jian Sun and Xiaoou Tang,
%		 Guided Image Filtering
%        IEEE TRANSACTIONS ON PATTERN ANALYSIS 
%        AND MACHINE INTELLIGENCE, VOL. 35, NO. X, XXXXXXX 2013 
%% Sandeep Manandhar, manandhar.sandeep@gmail.com
%December 14, 2015
%Universite de Bourgogne
%Advanced Image Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filteredImage = guidedfilter(Im, GuideIm, windowSize, dist_std, range_std)
%%%
%Im = input image(grayscale)
%GuidedIm = guided image(grayscale)
%windowSize = size of the local windowSize
%distance_std = standard deviation for distance for central pixel
%range_std = stadnard deviation for intensity range
%filteredImage = output image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[r, c] = size(Im);

N = windowSize*windowSize;

h1 = waitbar(0, 'Preaparing necessary statistics ...');
 set(h1, 'Name', 'Guided Filter');
 waitbar(1/8)
mp=conv2(Im, ones(windowSize)/windowSize^2,'same');
waitbar(2/8)
mI=conv2(GuideIm, ones(windowSize)/windowSize^2, 'same');
waitbar(3/8)
%vI=(stdfilt(GuideIm,  ones(windowSize))/windowSize^2).^2;
vI = conv2(GuideIm.^2, ones(windowSize)/windowSize^2, 'same') - mI.^2;
waitbar(4/8)
prod = Im.*GuideIm;
mprod = conv2(prod, ones(windowSize)/windowSize^2, 'same');
waitbar(5/8)
ak = (mprod - mI.*mp)./(vI + 0.01);  %%Extract edges here
bk = mp - ak.*mI;   %%discard edges and keep slowly changing details
waitbar(7/8)

mak = conv2(ak, ones(windowSize)/windowSize^2, 'same'); %%average edges
mbk = conv2(bk, ones(windowSize)/windowSize^2, 'same'); %%average smooth region
waitbar(8/8)
filteredImage = mak.*GuideIm + mbk;  %%some linear combination of guide image for output
close(h1)


