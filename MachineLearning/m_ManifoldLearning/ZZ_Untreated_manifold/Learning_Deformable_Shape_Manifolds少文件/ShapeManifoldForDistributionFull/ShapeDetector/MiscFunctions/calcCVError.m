function [ YtrueMinusEstTotal shapeModeParams] = calcCVError(  maskFileFolder, ...
                        nFold, X, Y, W0, M,...
                        a, tol, maxIters, kernel, regressionMode, ...
                        imgFeatureMode, index, shapeCoords, calcM, ...
                        dataDirectory, shapeVersion, ...
                        mode3D, zCoords)

% Initialize variables,   clear old shape paramters 
tempPCAName = [ dataDirectory 'tempShapePCAParamFile.mat'];
shapeCoords = shapeCoords(:);  
% if isempty( fiducialOffset )
%     fiducialOffset = [ 0; 0];
% end
for j = 1:nFold
    maskFile{j} = [maskFileFolder 'CVmaskFile' int2str(index) '.' int2str(j) '.mat'];
end
  
% -----------------------------------------
% Now do detections to calc error distribution
% Crop image regions

% to make surejust 2D error distribution 
tempMode3D = 0;  
if mode3D
    shapeVersion = 4;
end

% Initialize some things
showIt = 0; 
doItFast = 1;
lambda = x(1);
sigma = x(2);
epsSvr = 1;
numCoords =  length( shapeCoords);
if regressionMode == 4 % SVR( || regressionMode == 6  %(SVR or GPR) )
     epsSvr = x( 7 );
end

cropSize = findCropSizeUltimate( shapeCoords(:) , Y, x(3:4) );    
[ X2 Y2 ] = cropFiducial( X,  Y, shapeCoords(:), cropSize, 0, [], ...
    showIt, x(5:6) );
if ~isempty( zCoords)
    zCoords = zCoords(shapeCoords ,:);
end

Y2Cropped = Y2;
Y2 = [real( Y2); imag(Y2)] ; %;  zCoords] ; (% don't pad 3D coordinates) 
[ nX Yw  yMu V D Vimg V1 D1 yMu1 xMu Dimg ] = normalizeDataUltimate( tempPCAName, ...
    X2 , Y2,  ...
    1:size(Y2,2), doItFast, imgFeatureMode, [], ...
    calcM, shapeVersion, tempMode3D); 

%make a struct for these paramters, so that I can use these always in
%the future
shapeModeParams.yMu = yMu;
shapeModeParams.V =V;
shapeModeParams.D  = D;
shapeModeParams.V1 = V1;
shapeModeParams.D1 =D1;
shapeModeParams.yMu1 =yMu1;
shapeModeParams.Vimg = Vimg;
shapeModeParams.xMu = xMu;
shapeModeParams.Dimg = Dimg;

% calculate error k fold
%     Yest = cell(nFold,1);
YtrueMinusEstTotal = [];
for k = 1:nFold        
    load( maskFile{k} ); %load up train/test partitions

    [tempError W tempk YtrueMinusEst Yest ]=  runRegressionUltimate( nX(:,trainThis),  nX(:,testThis), ...
        Yw(:,trainThis),  Yw(:,testThis), W0,M, a, tol, maxIters, ...
        kernel, [lambda; sigma; epsSvr], regressionMode, 0, []);

    % This is shapes as all X over all Y
    [ Yhat  ] = unparameterizeShape( Yest, yMu, V, D, shapeVersion, V1, D1, yMu1, tempMode3D );
    tempError = [ real(Y2Cropped(:, testThis)); imag(Y2Cropped(:, testThis))] ...
                 - Yhat;

    % This gives absolute error in terms of all X over all Y
    YtrueMinusEstTotal = [YtrueMinusEstTotal tempError]; 

    % detections = reshape( Yhat(1:numCoords*2,:), numCoords, [] ); 
    % trueCoords =  YtoSideReal( Y2Cropped(:, testThis));
end