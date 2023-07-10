% Samuel Rivera
% date: may 12, 2009
% file: saveTrueEyeCoordinates.m
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, Di You, and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
% 

function [ trainThis testThis imageMatrix coordinateMatrix X Y nameList eyeCoords maskFile maskFileFolder imageFolder] ...
            = saveTrueEyeCoordinatesLC( commonDataFolder, database, ...
            imageSize, maxRead ,maskFileFolder, showLoadingImages,...
            reloadImagesEveryTime, percentTrain, index, nFoldCV , ...
            imageFolder, markingFolder130, base, leftEyeCoords, rightEyeCoords, ...
            oriNumCoords, overwriteMask, markingsVariableName, skipNormalization, ...
            namePrefix, dataDirectory, imageSuffix, skipCopyMasks, LCpercent)
        
%set maxRead to -1 for everything
%database = 'ASL', 'AR', 'EKM' or 'LFW'

warning off all


maskFile = [maskFileFolder 'maskFile' int2str(index) '.mat'];

%create necessary directories
if ~exist( maskFileFolder, 'dir' )
    mkdir( maskFileFolder );
end
if ~exist( [ dataDirectory 'localMasks/'], 'dir' )
    mkdir( [ dataDirectory 'localMasks/'] );
end

%standard training and testing within one database
if ischar( database )
    
    [ N imageMatrix coordinateMatrix X Y nameList eyeCoords imageFolder] = storeCommonData( database, imageSize, maxRead, ...
                    commonDataFolder, showLoadingImages, reloadImagesEveryTime, ...
                    imageFolder, markingFolder130, base, oriNumCoords, ...
                    markingsVariableName, skipNormalization, ...
                    leftEyeCoords, rightEyeCoords, namePrefix, imageSuffix ); 
                 
    if maxRead > 1
        N = min( N, maxRead );
    end

    load( [ commonDataFolder database '_Origi.mat' ] ) %, 'imageMatrix',coordinateMatrix
    load( [ commonDataFolder database '_Vectorized.mat' ] ) %, 'X', 'Y'  ,'-v7.3');
    
    %train/test partition part 
    if ~exist( maskFile, 'file' )
        generateMask( percentTrain, N, maskFile);
        generateCVMask( maskFileFolder, maskFile, index, nFoldCV )
    end
    
    if exist( maskFile, 'file') && ~strcmp(maskFileFolder, [ dataDirectory 'localMasks/']) 
        if ~skipCopyMasks
            copyfile( [maskFileFolder '*maskFile*' ] , [ dataDirectory 'localMasks/']);
            maskFileFolder = [ dataDirectory  'localMasks/' ];
            maskFile = [maskFileFolder 'maskFile' int2str(index) '.mat'];
        end
    end

    if overwriteMask || ~exist( maskFile, 'file' )
        generateMask( percentTrain, N, maskFile);
        generateCVMask( maskFileFolder, maskFile, index, nFoldCV )
    end
    load( maskFile, 'trainThis', 'testThis' );
    
    % LEarning curve stuff
    trainThis = trainThis(1: round(LCpercent*length(trainThis)));
    save( maskFile, 'trainThis', 'testThis' );
    generateCVMask( maskFileFolder, maskFile, index, nFoldCV )
    
    
    
%-------------------------------------------------------------------
%if combining different databases
else
    k1 = 0;
    testPos = 0;
    
    fullImageMatrix = [];
    fullCoordinateMatrix = [];
    fullX = [];
    fullY = [];
    fullEyeCoords = [];
    fullFaceImage = [];
    nameListTotal = []; 
    
    for i2 = 1:numel( database )
      

        N(i2) = storeCommonData( database{i2}, imageSize, maxRead(i2), ...
            commonDataFolder,  showLoadingImages, reloadImagesEveryTime, ...
            imageFolder{i2}, markingFolder130{i2}, base, oriNumCoords, ...
            markingsVariableName, skipNormalization, ...
            leftEyeCoords, rightEyeCoords, namePrefix{i2}, imageSuffix);

        if ~isempty( imageFolder{i2} ) && isempty( markingFolder130{i2} )
            k1 = k1+1;
            testPos(k1) = i2;
        end
        
        if maxRead > 1
            N(i2) = min( N(i2), maxRead(i2) );
        end
        
        load( [ commonDataFolder database{i2} '_Origi.mat' ] );
        load( [ commonDataFolder database{i2} '_Vectorized.mat' ] );
       
        if ~isempty( oriScale )
            oriScaleFull = oriScale;
        end
            
        %cat matrices  
        nameListTotal = [ nameListTotal; nameList];
        fullEyeCoords = [fullEyeCoords eyeCoords]; 
    	fullImageMatrix = cat( 3, fullImageMatrix, imageMatrix);
        fullCoordinateMatrix = [fullCoordinateMatrix, coordinateMatrix];
        fullX = [fullX X];
        fullY = [fullY Y];
       
    end
    
    
    %rename matrices
    oriScale = oriScaleFull;
    nameList = nameListTotal;
    eyeCoords = fullEyeCoords;
    X = fullX;
    Y = fullY;
    coordinateMatrix = fullCoordinateMatrix;
    imageMatrix = fullImageMatrix;
    
    save( [ commonDataFolder 'combinedDatabases_Origi.mat'], 'imageMatrix', ...
                             'coordinateMatrix', 'nameList', 'eyeCoords', 'oriScale' ,'-v7.3'); 
    save( [ commonDataFolder 'combinedDatabases_Vectorized.mat' ], 'X', 'Y', ...
                                '-v7.3'); 

    %train/test partition part

    
    if exist( maskFile, 'file') && ~strcmp(maskFileFolder, [ dataDirectory 'localMasks/'])
        if ~skipCopyMasks
            copyfile( [maskFileFolder '*maskFile*' ] , [ dataDirectory 'localMasks/']);
            maskFileFolder = [ dataDirectory  'localMasks/' ];
            maskFile = [maskFileFolder 'maskFile' int2str(index) '.mat'];
        end
    end

    testThis = [];
    if k1 >0
        for i1 = 1:k1
            testThisTemp = sum( N(1:testPos(i1)-1))+1:sum( N(1:testPos(i1)-1))+N(testPos);  
            testThisTemp = testThisTemp(:);
            testThis = [testThis; testThisTemp ];
        end
        
        trainThis = 1:sum(N);
        trainThis = trainThis(:);
        trainThis( testThis) = [];
        save( maskFile, 'trainThis', 'testThis');
        generateCVMask( maskFileFolder, maskFile, index, nFoldCV )
        
    else
        %no custom database used, so just make some random partitions
        display( 'No custom databases');
        if overwriteMask || ~exist( maskFile, 'file' )
            generateMask( percentTrain, sum(N), maskFile )
            generateCVMask( maskFileFolder, maskFile, index, nFoldCV )
        else
           warning( 'Warning: Using pre-stored train/test splits. Dimensions may not match.');
        end

        load( maskFile, 'trainThis', 'testThis' );
    end

end

 warning on all
