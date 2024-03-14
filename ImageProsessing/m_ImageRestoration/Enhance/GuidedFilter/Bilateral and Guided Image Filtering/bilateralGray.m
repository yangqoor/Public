%% Bilater filtering on grayscale image
%Based on the implementation
%       C. Tomasi and R. Manduchi. Bilateral Filtering for 
%       Gray and Color Images. In Proceedings of the IEEE 
%       International Conference on Computer Vision, 1998. 
%% Sandeep Manandhar, manandhar.sandeep@gmail.com
%December 10, 2015
%Universite de Bourgogne
%Advanced Image Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function A = bilateralGray(Im, windowSize, dist_std, range_std)
%Im = input image(color)
%windowSize = size of the local windowSize
%distance_std = standard deviation for distance for central pixel
%range_std = standard deviation for intensity range
%A = output image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



noisyIm = Im;

[X,Y] = meshgrid(-windowSize:windowSize, - windowSize:windowSize);
GaussDistance = exp(-(X.^2 + Y.^2)/(2*dist_std^2));


[r c] = size(noisyIm);
A = zeros(r,c);
h = waitbar(0, 'Please be patient, Processing...');
set(h, 'Name', 'Bilateral Filtering in Grayscale');
for i=1:r
    for j=1:c
        
         try  %%try catch for boundary checks
            patch = noisyIm(i-windowSize:i+windowSize, ...
                           j-windowSize:j+windowSize);
            GaussRange = exp(-(patch - noisyIm(i,j)).^2/(2*range_std^2));
            response = GaussRange.*GaussDistance;
            A(i,j) = sum(response(:).*patch(:))/sum(response(:));
      
        catch
            A(i,j) = noisyIm(i,j);
        end 
       
    end
    waitbar(i/r);
end
close(h);
%%
% % subplot(1,2,1); 
% figure; imshow(noisyIm, []); title('Noisy image')
% % subplot(1,2,2); 
% figure; imshow(A, []); title('After Bilateral filtering')