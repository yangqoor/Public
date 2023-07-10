%Samuel Rivera
% Date: Sep 7, 2010
% Notes: There are some mistakes in some marking, I need to go through and
%   doublecheck some sequences

markingFolder = '/Users/stunna/Data/DatabaseStores/ASL77/formattedMarkings/';
imageFolder = '/Users/stunna/Data/DatabaseStores/ASL77/formattedImages/';
namePrefix = '4_29_C_';
suffix = 'jpg';
% line 24 to change coordinates name

list = dir( [ markingFolder namePrefix '*.mat' ] );


N = length(list);

% scrsz = get(0,'ScreenSize');
% figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
for i1=1:N
    clf(gcf);
    
    

    imName = [ imageFolder list(i1).name(1:end-3) suffix  ];
        
    load( [ markingFolder list(i1).name ] );
   
    
    %You need to know what the variable is for marking coordinates
    % faceCoordinates = coordinates2D;  
    
    imshow( imName );
    customFacePlots( faceCoordinates, 0 )
%     set(gcf, 'Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
    
    % title( list(i1).name );    
    list(i1).name
    
%     [B, IX ] = sort(A,...)
%     filename = [ '/Users/stunna/Data/DemoContext/ASLSFMMissing/ASL_' int2str(i1) '.eps'];
%     print2eps(filename, 1)
            
    
    pause(.2);
    
    
end