
% 
% imageMatrix = testImages;
% coordinateMatrix = testMarkings;
function verifyMarkings( imageMatrix, coordinateMatrix )
for i1 = 1:size(coordinateMatrix,2)
    clf(gcf);
    imagesc( imageMatrix(:,:,i1)); colormap gray;
    hold on; axis equal;
    plot( real( coordinateMatrix(:,i1)), imag( coordinateMatrix(:,i1)), 'g*');
    pause(.1);
end

    