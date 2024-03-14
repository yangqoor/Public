%% Bilater filtering on color image
%Based on the implementation
%       C. Tomasi and R. Manduchi. Bilateral Filtering for 
%       Gray and Color Images. In Proceedings of the IEEE 
%       International Conference on Computer Vision, 1998. 
%% Sandeep Manandhar, manandhar.sandeep@gmail.com
%December 10, 2015
%Universite de Bourgogne
%Advanced Image Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A = bilateralColor(Im, windowSize, dist_std, range_std)
%Im = input image(color)
%windowSize = size of the local windowSize
%distance_std = standard deviation for distance for central pixel
%range_std = stadnard deviation for intensity range
%A = output image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%convert to LAB space
if exist('applycform','file')
   Im = applycform(Im,makecform('srgb2lab'));
else
   Im = colorspace('Lab<-RGB',Im);
end


noisyIm = Im;

[X,Y] = meshgrid(-windowSize:windowSize, - windowSize:windowSize);
%%Distance gaussian
GaussDistance = exp(-(X.^2 + Y.^2)/(2*dist_std^2));

[r c n] = size(noisyIm);
A = zeros(size(Im));
h = waitbar(0, 'Please be patient, Processing...');
set(h, 'Name', 'Bilateral Filtering in Color space');
for i=1:r
    for j=1:c
        
         try    %%try catch to save me from boundary checks

            patch = noisyIm(i-windowSize:i+windowSize, ...
                           j-windowSize:j+windowSize,:);
                       
            dL = patch(:,:,1) - noisyIm(i,j,1);
            da = patch(:,:,2) - noisyIm(i,j,2);
            db = patch(:,:,3) - noisyIm(i,j,3);
            
            %%Range gaussian
            GaussRange = exp(-(dL.^2 + da.^2 + db.^2)/(2*range_std^2));

            response = GaussRange.*GaussDistance;
    
            A(i,j,1) = sum(sum(response.*patch(:,:,1)))/sum(response(:)); 
            A(i,j,2) = sum(sum(response.*patch(:,:,2)))/sum(response(:));
            A(i,j,3) = sum(sum(response.*patch(:,:,3)))/sum(response(:));

         catch
              A(i,j,:) = noisyIm(i,j,:);
        end  
        
       
    end
    waitbar(i/r);
end
close(h);
if exist('applycform','file')
   A = applycform(A,makecform('lab2srgb'));
else  
   A = colorspace('RGB<-Lab',A);
end
