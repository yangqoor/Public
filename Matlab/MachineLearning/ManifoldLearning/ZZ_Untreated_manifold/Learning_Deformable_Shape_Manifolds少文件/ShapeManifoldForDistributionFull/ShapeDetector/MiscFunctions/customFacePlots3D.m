% Samuel Rivera
%
% customHandPlots

function customFacePlots3D( faceCoordinates, small )

if size(faceCoordinates,1) ~= 3
    faceCoordinates = faceCoordinates';
end

hold on

if size( faceCoordinates,2) == 77

       
   estLeye = faceCoordinates(:,1:9);
   plot3( estLeye(1,[2:end, 2]), estLeye(2,[2:end, 2]),estLeye(3,[2:end, 2]),...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estReye = faceCoordinates(:,10:18);
   plot3( estReye(1,[2:end, 2]), estReye(2,[2:end, 2]),estReye(3,[2:end, 2]),...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estLbrow = faceCoordinates(:,19:26);
   plot3( estLbrow(1,[1:end 1]), estLbrow(2,[1:end 1]), estLbrow(3,[1:end 1]), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estRbrow = faceCoordinates(:,27:34);
   plot3( estRbrow(1,[1:end 1]), estRbrow(2,[1:end 1]), estRbrow(3,[1:end 1]), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estN = faceCoordinates(:,35:49);

   plot3( estN(1,1:4), estN(2,1:4), estN(3,1:4), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);
   plot3( estN(1,5:end), estN(2,5:end), estN(3,5:end), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estM = faceCoordinates(:,50:63);
   plot3( estM(1,[ 1:end-6 1 ]), estM(2,[1:end-6 1 ] ), estM(3,[1:end-6 1 ] ), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);
    plot3( estM(1,[1 9:11 5 (end-2):end 1]), estM(2,[1 9:11 5 ...
                            (end-2):end 1 ]),estM(3,[1 9:11 5 ...
                            (end-2):end 1 ]), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estC = faceCoordinates(:,64:77);
   plot3( estC(1,[1:end 1]), estC(2,[1:end 1]), estC(3,[1:end 1]), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   %following code deals with output range.  
    if ~isempty( small )
       minX = min( faceCoordinates(1,:) );
       maxX = max( faceCoordinates(1,:) );
       minY = min( faceCoordinates(2,:) );
       maxY = max( faceCoordinates(2,:) );

        if small == 1
            axis( [ minX-10 maxX+10 minY-17 maxY+10] );
        elseif small == 2
            axis( [ minX-5 maxX+5 minY-8 maxY+5] );
        elseif small ==3
            axis( [ minX-2 maxX+2 minY-4 maxY+2] )
        else
            axis( [ minX-20 maxX+20 minY-35 maxY+20] );
        end

        if small == 1
            rect = [5, 5, 800, 800];
            set(gcf,'Position', rect )
        elseif small == 2
            rect = [5, 5, 1200, 1200];
            set(gcf,'Position', rect ) 
        elseif small == 3
            rect = [5, 5, 2200, 2200];
            set(gcf,'Position', rect ) 
        end
    end
    
elseif size( faceCoordinates,2) == 130

    error( '3D plot of this not defined, do it' );
   estLeye = faceCoordinates(:,1:13);
   plot( estLeye(1,[2:end, 2]), estLeye(2,[2:end, 2]),...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estReye = faceCoordinates(:,14:26);
   plot( estReye(1,[2:end, 2]), estReye(2,[2:end, 2]),...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estLbrow = faceCoordinates(:,27:38);
   plot( estLbrow(1,[1:end 1]), estLbrow(2,[1:end 1]), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estRbrow = faceCoordinates(:,39:50);
   plot( estRbrow(1,[1:end 1]), estRbrow(2,[1:end 1]), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estN = faceCoordinates(:,51:83);
   plot( estN(1,1), estN(2,1), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);
   plot( estN(1,2), estN(2,2), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);
   plot( estN(1,3:end-4), estN(2,3:end-4), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);
   plot( estN(1,end-3:end), estN(2,end-3:end), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estM = faceCoordinates(:,84:109);
   plot( estM(1,[ 1:end-6 1 ]), estM(2,[1:end-6 1 ] ), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);
    plot( estM(1,[1 21:23 11 (end-2):end 1]), estM(2,[1 21:23 11 ...
                            (end-2):end 1 ]), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   estC = faceCoordinates(:,110:130);
   plot( estC(1,:), estC(2,:), ...
               '-mo','LineWidth',2,...
               'MarkerEdgeColor','k',...
               'MarkerFaceColor','w',...
               'MarkerSize',3);

   %following code deals with output range.  
    if ~isempty( small )
       minX = min( faceCoordinates(1,:) );
       maxX = max( faceCoordinates(1,:) );
       minY = min( faceCoordinates(2,:) );
       maxY = max( faceCoordinates(2,:) );

        if small == 1
            axis( [ minX-10 maxX+10 minY-17 maxY+10] );
        elseif small == 2
            axis( [ minX-5 maxX+5 minY-8 maxY+5] );
        elseif small ==3
            axis( [ minX-2 maxX+2 minY-4 maxY+2] )
        else
            axis( [ minX-20 maxX+20 minY-35 maxY+20] );
        end

        if small == 1
            rect = [5, 5, 800, 800];
            set(gcf,'Position', rect )
        elseif small == 2
            rect = [5, 5, 1200, 1200];
            set(gcf,'Position', rect ) 
        elseif small == 3
            rect = [5, 5, 2200, 2200];
            set(gcf,'Position', rect ) 
        end
    end    
    
else
    display( 'wrong number face landmarks');
end