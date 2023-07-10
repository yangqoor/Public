% Samuel Rivera
% May 31, 2010

function [allE allRMSE allPerc  allESFM allRMSESFM allPercSFM allEmu allRMSEmu allPercmu ...
         allE3D allRMSE3D allEPerc3D allE3Dmu allRMSE3Dmu allEPerc3Dmu] = ...
                    summarizeErrors( trueXY, detectXY, trueZ, detectZ, nonMissingMask, ...
                                     sfmXY, meanEstimateXY, meanEstimateZ  )
 
quietMode = 1;

trueX = real( trueXY);
trueY = imag( trueXY);
estX = real(detectXY);
estY = imag(detectXY);
estXSFM = real(sfmXY);
estYSFM = imag(sfmXY);

meanEstimateXY = repmat( meanEstimateXY,1,size(trueX,2));
estZmu = repmat( meanEstimateZ, 1, size(trueX,2));
estXmu = real(meanEstimateXY);
estYmu = imag(meanEstimateXY);

% 2D Euclidean pixel error calculation detections to true
[ allE] = aveError( [trueX(:) trueY(:)] , [estX(:) estY(:)]);
allE(~nonMissingMask(:) ) = [];

% 2D RMS Error  detections to true 
nonMissingMask2 = [ nonMissingMask; nonMissingMask];
true = [ trueX; trueY];
allRMSE = calcRMSError( true, [ estX; estY], nonMissingMask2);

% 2D percent error, detection to true
allPerc = calcPercentError( true, [ estX; estY], nonMissingMask2);

%2D Euclidean Error given by estimating mean every time
[ allEmu] = aveError( [trueX(:) trueY(:)] , [estXmu(:) estYmu(:)]);
allEmu(~nonMissingMask(:) ) = [];

% 2D RMS Error mean to true 
allRMSEmu = calcRMSError( true, [ estXmu; estYmu], nonMissingMask2);

% 2D percent Error, mean to true
allPercmu = calcPercentError( true, [ estXmu; estYmu], nonMissingMask2);

if isempty( sfmXY ) % Only check SFM if actually filled in
    allESFM = [];
    allRMSESFM = [];
    allPercSFM = [];
else
    % 2D Euclidean pixel error SFM  to true
    [ allESFM] = aveError( [trueX(:) trueY(:)] , [estXSFM(:) estYSFM(:)]);
    allESFM(~nonMissingMask(:) ) = [];

    % 2D RMS Error SFM to true 
    allRMSESFM = calcRMSError( true, [ estXSFM; estYSFM], nonMissingMask2);

    % 2D percent Error SFM to true 
    allPercSFM = calcPercentError( true, [ estXSFM; estYSFM], nonMissingMask2);
end


%---------------------------------------------------------------------
% 3D error calculations

if isempty( detectZ )
    allE3D = [];
    allRMSE3D = [];
    allE3Dmu = [];
    allRMSE3Dmu = [];
    allEPerc3D = [];
    allEPerc3Dmu = [];
    
else
    %for 3D Euclidean pixel error calculation
    [ allE3D] = aveError( [trueX(:) trueY(:) trueZ(:)] , [estX(:) estY(:) detectZ(:)]);
    allE3D(~nonMissingMask(:) ) = [];
    
    %for 3D RMS Error  detections to true 
    nonMissingMask2 = [ nonMissingMask; nonMissingMask; nonMissingMask];
    true = [ trueX; trueY; trueZ];
    detect = [ estX; estY; detectZ];
    allRMSE3D = calcRMSError( true, detect, nonMissingMask2);
    
    % 3D Percent Error, detections to true
    allEPerc3D = calcPercentError( true, detect, nonMissingMask2);
    
    %for 3D Euclidean pixel error  mean to true
    [ allE3Dmu] = aveError( [trueX(:) trueY(:) trueZ(:)] , [estXmu(:) estYmu(:) estZmu(:)]);
    allE3Dmu(~nonMissingMask(:) ) = [];

    %for 3D RMS Error  mean to true 
    detect = [ estXmu; estYmu; estZmu];
    allRMSE3Dmu = calcRMSError( true, detect, nonMissingMask2);
    
    % 3D percent error, mean to true
    allEPerc3Dmu = calcPercentError( true, detect, nonMissingMask2);
    
end

if ~quietMode
    %---------------------------------------------------------------------
    display( [ '---------------------------------------------------------']);
    display( [ 'Detecting ' int2str(length(allE)) ' landmarks over ' int2str(size(trueX,2)) ' images.' ]);
    display( [ 'Average landmark Euclidean error = ' num2str(mean(allE)) ] );
    display( [ 'Variance = ' num2str(var(allE)) ] );
    display( [ '---------------------------------------------------------']);
    display( [ 'Average RMS error = ' num2str(mean(allRMSE)) ] );
    display( [ 'Variance of RMS error = ' num2str(var(allRMSE)) ] ); 
    display( [ '---------------------------------------------------------']);
    display( [ 'Average percent error = ' num2str(mean(allPerc)) ] );
    display( [ 'Variance of percent error = ' num2str(var(allPerc)) ] ); 
    display( [ '---------------------------------------------------------']);
    display( [ '---------------------------------------------------------']);
    display( [ 'Average landmark Euclidean error (taking mean as estimate) = ' num2str(mean(allEmu)) ] );
    display( [ 'Variance (taking mean as estimate) = ' num2str(var(allEmu)) ] ); 
    display( [ '---------------------------------------------------------']);
    display( [ 'Average RMS error (taking mean as estimate) = ' num2str(mean(allRMSEmu)) ] );
    display( [ 'Variance of RMS error (taking mean as estimate) = ' num2str(var(allRMSEmu)) ] ); 
    display( [ '---------------------------------------------------------']);
    display( [ 'Average percent error (taking mean as estimate) = ' num2str(mean(allPercmu)) ] );
    display( [ 'Variance of percent error (taking mean as estimate) = ' num2str(var(allPercmu)) ] ); 
    display( [ '---------------------------------------------------------']);
    display( [ '---------------------------------------------------------']);
    display( [ 'Average landmark Euclidean error for SFM = ' num2str(mean(allESFM)) ] );
    display( [ 'Variance = ' num2str(var(allESFM)) ] );
    display( [ '---------------------------------------------------------']);
    display( [ 'Average RMS error for SFM = ' num2str(mean(allRMSESFM)) ] );
    display( [ 'Variance of RMS error = ' num2str(var(allRMSESFM)) ] ); 
    display( [ '---------------------------------------------------------']);
    display( [ 'Average percent error for SFM = ' num2str(mean(allPercSFM)) ] );
    display( [ 'Variance of percent error = ' num2str(var(allPercSFM)) ] );
end

% mean(allRMSE3D)
% mean(allRMSE3Dmu)
% 
% mean(allEPerc3D)
% mean(allEPerc3Dmu)


% pause;

