% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function beautifulFacePlots( faceCoordinates, I, small, trueCoordinates )
% Notes: will look to see if its the 130 point system,  or the 77 point
% system.  If not, it will jsut give you a simple plot

    %it wants it in [ x x x; y y y];
    if size( faceCoordinates ,1) ~= 2
        faceCoordinates = faceCoordinates';
    end
    if size( trueCoordinates ,1) ~= 2
        trueCoordinates = trueCoordinates';
    end

%--------------------------------------------------------------------
  
    %the 77 point face system
    if size( faceCoordinates, 2) == 77
       
        clf(gcf);
        subplot(121)
        imagesc( I), colormap(gray);
        axis equal off 
        customFacePlots( faceCoordinates, small )
        title( 'Detected')
        
        subplot(122)
        imagesc( I), colormap(gray);
        axis equal off 
        customFacePlots( trueCoordinates, small )
        title( 'Ground Truth')
        
    %the 130 points face system    
    elseif size( faceCoordinates, 2) == 130
       
        clf(gcf);
        subplot(121)
        imagesc( I), colormap(gray);
        axis equal off 
        customFacePlots( faceCoordinates, small )
        title( 'Detected')
        
        subplot(122)
        imagesc( I), colormap(gray);
        axis equal off 
        customFacePlots( trueCoordinates, small )
        title( 'Ground Truth');
        
    elseif size( faceCoordinates, 2) == 20 %Hand Marking stuff

        clf(gcf);
        subplot(121)
        imagesc( I), colormap(gray);
        axis equal off 
        customHandPlots( [ faceCoordinates ]);
        title( 'Detected');
        
        subplot(122)
        imagesc( I), colormap(gray);
        axis equal off 
        customHandPlots( [ trueCoordinates ]);
        title( 'Ground Truth');
        
%         subplot(132)
%         xlabel( 'detected' ) 
%         imagesc( X(:,:,testThis(i1))), colormap(gray);
%         hold on
%         customHandPlots( detectedFaceCoordinates(:,i1*2-1:i1*2) );
% 
%         subplot(133)
%         xlabel( 'true' ) 
%         imagesc( X(:,:,testThis(i1))), colormap(gray);
%         hold on
%         for i2 = 1:size(Y,1)
%             text( real(Y(i2,testThis(i1))), imag( Y(i2,testThis(i1))), int2str(i2), 'color', 'green', 'fontsize' , 12);
%         end
        % MOV(i1) = getframe(gcf);
        % saveas( 1, ['prelim' int2str(i1) '.png']);
        
        
    else  % basic plot    
         
        clf(gcf);
        subplot(121)
        imagesc( I), colormap(gray);
        axis equal off 
        hold on
        plot( faceCoordinates(1,:), faceCoordinates(2,:), 'b.' );
        title('Detections')
        
        subplot(122)
        imagesc( I), colormap(gray);
        axis equal off 
        hold on
        plot( trueCoordinates(1,:), trueCoordinates(2,:), 'b.' );
        title('Ground Truth')
        
    end
    
    