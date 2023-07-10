% function quickplot( images, coords )
% images = 'FabianData';
% coords = ' ';
% 
% list = dir( [ coords '/*.*' ] );
% list2 = dir( [ images '/*.*' ] );
% 
% N = length( list );
% 
% for k1 = 1:N
%     
%     X = load( [ coords list{k1}.name ] );
%     A = imread( [ images list2{k1}.name ] );
%         
%     beautifulFacePlots( X, A, [] )
%     pause( .3 );
%     
% end


for i1 = 1:size( coordinateMatrix,2)
    
    imagesc( imageMatrix(:,:,i1)), colormap gray
    hold on
    
    customFacePlots( [real( coordinateMatrix(:,i1)), imag( coordinateMatrix(:,i1))], [] )
%     plot( real( coordinateMatrix(:,i1)), imag( coordinateMatrix(:,i1)), 'g.');
    
    pause(.3);
    
end