function [ cameraImageN ] = NormalizeCameraImage( cameraImage, viewportMatrix )
% Normalize camera image for local variables
    square_size = 15;
%     cameraImageVp = cameraImage(viewportMatrix(2, 1):viewportMatrix(2, 2), ...
%         viewportMatrix(1, 1):viewportMatrix(1, 2));
%     min_cameraImamgeVp = ordfilt2(cameraImageVp, 1, ones(square_size, square_size));
%     max_cameraImageVp = ordfilt2(cameraImageVp, square_size^2, ...
%         ones(square_size, square_size));
%     cameraImageNVp = (cameraImageVp - min_cameraImamgeVp) ...
%         ./ (max_cameraImageVp - min_cameraImamgeVp);
    
    min_cameraImage = ordfilt2(cameraImage, 1, ones(square_size, square_size));
    max_cameraImage = ordfilt2(cameraImage, square_size^2, ones(square_size, square_size));
    cameraImageN = (cameraImage - min_cameraImage) ...
        ./ (max_cameraImage - min_cameraImage);
    
%     cameraImageN = - ones(size(cameraImage));
%     cameraImageN(viewportMatrix(2, 1):viewportMatrix(2, 2), ...
%         viewportMatrix(1, 1):viewportMatrix(1, 2)) = cameraImageNVp;
end
