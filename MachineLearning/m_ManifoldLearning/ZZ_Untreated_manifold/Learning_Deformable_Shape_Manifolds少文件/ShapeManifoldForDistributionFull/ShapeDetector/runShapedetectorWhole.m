
% runShapedetectorWhole: Detects the 2D/3D coordinates of a deformable shape
%
% Deformable Shape Regressor, v1.0
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, Di You, and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
% 
%     This file is part of the Deformable Shape Regressor (DSR).
% 
% Syntax:
% 
% runShapedetectorWhole( trialNumber, imageSize, eyeDist,imgFeatureMode, regressionMode, ...
%                     reloadImagesEveryTime, database, maxRead, percentTrain, ...
%                     overwriteMask, maskFileFolder, markedDatabaseDirectory,...
%                     doItFast, nFoldCV, maxSimplexIterations, ...
%                     robustErrPercent, distScale, ...
%                     showLoadingImages, debugEyeDetector, debugRotation, showAAM, debugCropWholeForAAM, ...
%                     debugFaceShapeDetector, showUnwarping, showSFM, ...
%                     wholeVersion, runTestingAAM, unwarpCoordinates, ...
%                     cleanCVandDistribEveryTime, needItClean, ...
%                     saveIndividualCoordinates, detectedCoordFolder, imageFolder, markingFolder130, ...
%                     leftEyeCoords, rightEyeCoords, shapeCoords, oriNumCoords, ...
%                     skipScaleNormalization, calcM, W0, a, tol, markingsVariableName, ...
%                     VJDetectionsFolder, oriImageFolder, namePrefix, filterUnknownMarkings, ...
%                     fiducialCoordinates, fidMaxHW, dataDirectory, optAlgorithm, ...
%                     imageSuffix, skipWindowOpt, shapeVersion, skipCopyMasks, mode3D, ...
%                     centerMode, superbInitAAM, skipDiTuning, centerPerturbationAmount)  
%
% 
% Scroll down for Examples.
% 
% 
% Parameter Explanations:
%         trialNumber: set this to an integer, helps keep results organized
%         imageSize: set to an integer, say 50 for a 50x50 image before normalization 
%         eyeDist: set to an integer, the amount of pixels between
%              normalization points (eyes)
%         imgFeatureMode: 1 for unit pixels, 2 for C1, 3 for LBP, 
%                           4 for BWT (berkely wavelet transform ),  5 unit pca
%                           6 Laplacian Eigenmaps, 7 pixel, 8 for PCA,
%                           9 center shifted unit pixel, 10 Haar features
% 
% 
%         regressionMode: 1 for LS, 2 for ridge, 3 for lasso, 4 for SVR, 
%                           5 for KRR, 6 for GPR (currently a bug for the
%                           eye detector, must fix)
%
%         reloadImagesEveryTime: boolea, set to 0, unless you want to load the
%              markings and coordinates from individual files every single
%              time (slow)
%
%         database:  'AR' or 'ASL' or 'LFW' for single databses, or
%               { 'AR', 'ASL', 'LFW', 'custom'} for training with the first
%               3 and testing with a custom database.  Order does not matter
%         maxRead: -1 for all images, else a positive integer. If more than
%              one databse, like [ -1, -1, -1, -1], and should correspond to
%              order of 'database'
%         percentTrain: some real value such that 0 < value <= 1.  Note that
%               if you are using a 'custom' database, it will just test on
%               all the images in 'custom'
%
%         overwriteMask: boolean, set to 1 for overwrite training and testing
%              partitions, or 0 for use the old ones
%         maskFileFolder: directory to store training/testing partitions (mask files),
%               in case you are running several algorithms for comparison.
%         markedDatabaseDirectory: directory where the marked databses are,
%               probably 'DatabaseStores/'
% 
%         doItFast: boolea, set to 1 to load pre-stored PCA parameters (recommended) 
%         nFoldCV: a positive number N, specifying N-fold cross validation
%              for training
%         maxSimplexIterations: positive integer ( 10000 a good number)                    
% 
%         robustErrPercent: 0 < value <= 1, when estimating Normal error
%              distributions, you can estimate using only a certain
%              percentage of the smaller errors if you expect outliers (1
%              or .99 are good values)
%         distScale: positive value, will scale the principal axes if the 
%               estimated error distributions to make it tighter ( < 1) or 
%               wider ( > 1). Good value is 1 for no scaling.
% 
%         showLoadingImages: boolean, 1 for show
%         debugEyeDetector: boolean, 1 for show
%         debugRotation: boolean, 1 for show
%         showAAM: boolean,  1 for show    
%         debugCropWholeForAAM: boolean, 1 for show
%         debugFaceShapeDetector: boolean, 1 for show
%         showUnwarping: boolean, 1 for show
%         showSFM: boolean, 1 for show
% 
%         wholeVersion: integer, 1 for shape detection with regression
%                                2 for subshapes method    
%                                3 for AAM with RIK
%                                4 Adaboost regression with Haar features
% 
%         runTestingAAM: boolean, 1 if you want to run the AAM testing
%              phase.  Otherwise it will just train the model
%         
%         unwarpCoordinates: boolean, 1 for unwarp                   
%         cleanCVandDistribEveryTime: boolean, 1 if you want to re-train the 
%               system every time.  Usually set to 0 for speed
% 
%         needItClean: 5 for remove CV and PCA parameters
%                      4 for clean shape parameterization
%                      7 for clean experimental results
%                      1 for basic cleanup of temp files
% 
%         saveIndividualCoordinates: boolean, you can either save results
%              in a large matrix, or as individual .mat files with original
%              image name
%         detectedCoordFolder: if saveIndividualCoordinates ==1, specify a 
%               directory to put those results
%         
%         imageFolder: if using 'custom' database, specify a directory for
%              the images
%         markingFolder130: if using 'custom' database, specify a directory for
%              the markings, [] if they are not known
% 
%         leftEyeCoords: specifies left object point for normalization.  
%                 either a single index, or vector of coordiantes to
%                 average, such as 1 or 2:13
%         rightEyeCoords: specifies right image point for normalization.  
%                 either a single index, or vector of coordiantes to
%                 average, such as 14 or 15:26
%         shapeCoords: vector of shape coordinates you want, such as 1:130.
%                 Use this feature to eliminate unstable points if you
%                 wish.
%         oriNumCoords: total number of shape coordinates before selecting
%                 particular ones for the shape
%
%         skipScaleNormalization: bool = 0 if you want to normalize (inter eye)
%         
%         calcM : boolean, 1 if missing values in output matrix
%         W0: initialization for linear/ridge regression
%         a: step size for gradient descent
%         tol: termination criterion for gradient descent
%         markingsVariableName: leave [] unless using some funky new
%                   database
% 
%         VJDetectionsFolder: directory where u stored the VJ detections
%         oriImageFolder: self explanatory
%         
%         namePrefix: to be put at beginning of filename, such as for
%         picking certain subjects in an experiment
% 
%         filterUnknownMarkings: boolean for eliminate entries without full
%         set of the most marked landmarks
% 
%         fiducialCoordinates : cell with each entry a vector of subshape
%               indices
%         fidMaxHW: matrix, 2x numFiducials,  [x1 x2 x3; y1 y2 y3], as
%                percentage of max subshape size
% 
%         dataDirectory: directory where you want all the experimental
%               All its contents are calculated during experiments and 
%               can be re-generated (Except train test partitions which
%               will be random )
%         
%         optAlgorithm:          1 for simplex (direct search )
%                                2 for R algorithm 
%                                3 for simulated annealing
%                                4 for genetic algorithm
%                                5 for particle swarm
%                                Set as [] for default: 5
% 
%         imageSuffix: 'jpg', 'bmp', etx. Set as [] for default 'jpg'
% 
%         skipWindowOpt: use default size and zero shift for windows 
% 
%         shapeVersion: 1 for standard whitening, 2 for whitening plus shift 
%                       centroid, 3 for combined deformation translation,
%                       4 for combined deformation-translation with scaling
% 
%         skipCopyMasks: boolean, 1 for don't copy masks to localMasks
% 
%         mode3D: boolean, 1 for 3D, 0 for 2D
% 
%         centerMode: boolean, 1 for assume shapes centered
% 
%         superbInitAAM: boolean, 1 for initialize AAM with my shape
%               detector which gives a superb initialization ;) 
% 
%         skipDiTuning: boolean, 1 for skip Di KRR fine tuning
% 
%         centerPerturbationAmount: scalar for nrand to purturb the
%                centered shape position
% --------------------------------------------------------------------
% EXAMPLE 1, basic use within a standard marked database:
% 
%     runShapedetectorWhole( index, imSize, 10,imgFeature, regressionMode, ...
%                 0, 'HAND', -1, .9, ...
%                 overWriteMask, 'TrainTestSplits/', '../DatabaseStores/',...
%                 1, 5, maxIters, ...
%                 [], [], ...
%                 showLoadingImages, 0, 0, 0, 0, ...
%                 debugFaceShapeDetector, 1, showSFM,  ...
%                 wholeVersion, 1, unwarpCoordinates, ...
%                 cleanCVandDistribEveryTime, 1, ...
%                 0, [], [], [], ...
%                 [], [], [ 1:20], 20, ...   %[ 1 3:20] for coordinates
%                 skipScaleNormalization, calcM, [], [], [], 'coordinates', ...
%                 [], [], namePrefix, filterUnknownMarkings, ...
%                 fiducialCoordinates, fidMaxHW, [], [], ...
%                 [], skipWindowOpt, shapeVersion, 1, mode3D, ...
%                 centerMode, [], 0, 0 );
% -----------------------------------------------------------------------
% 
% EXAMPLE 2, detecting shape of a custom image set:
% 
% %'Positivo' is any name you specify for a custom database
%
% runShapedetectorWhole( 1,  imSize, eyeDist, featureMode, regressionMode, ...
%                     reloadImages, {'Positivo', 'FabNew'}, [ 20 100 ], [], ...
%                     0, 'trainTestSplits/', '../DatabaseStores/',...
%                     1, numCV, maxIters, ... 
%                     1, 1, ...
%                     showLoading, 0, 0, 0, 0, ...
%                     0, showUnwarping, 0,...
%                     wholeVersion, 1, unwarpCoordinates, ...
%                     0, needItClean, ...
%                     1, 'newPosDetections/', { '../DatabaseStores/NewPositiveNormalized/AllformattedImages/',[]}, {[],[]}, ...
%                     2:9, 11:18, 1:74, 77, ...
%                     skipScaleNormalization, 0, [], [], [], [], ...
%                     VJPos, oriImageFolderPos , {'F3_11_A_', 'F3_11_A_'}, 0, ...
%                     [], [], [], [], ...
%                     [], 0, shapeVersion, 1, 0, ...
%                     0, 1, 0, 0);
% 
% -------------------------------------------------------------------
  
                
function runShapedetectorWhole( trialNumber, imageSize, eyeDist,imgFeatureMode, regressionMode, ...
                    reloadImagesEveryTime, database, maxRead, percentTrain, ...
                    overwriteMask, maskFileFolder, markedDatabaseDirectory,...
                    doItFast, nFoldCV, maxSimplexIterations, ...
                    robustErrPercent, distScale, ...
                    showLoadingImages, debugEyeDetector, debugRotation, showAAM, debugCropWholeForAAM, ...
                    debugFaceShapeDetector, showUnwarping, showSFM, ...
                    wholeVersion, runTestingAAM, unwarpCoordinates, ...
                    cleanCVandDistribEveryTime, needItClean, ...
                    saveIndividualCoordinates, detectedCoordFolder, imageFolder, markingFolder130, ...
                    leftEyeCoords, rightEyeCoords, shapeCoords, oriNumCoords, ...
                    skipScaleNormalization, calcM, W0, a, tol, markingsVariableName, ...
                    VJDetectionsFolder, oriImageFolder, namePrefix, filterUnknownMarkings, ...
                    fiducialCoordinates, fidMaxHW, dataDirectory, optAlgorithm, ...
                    imageSuffix, skipWindowOpt, shapeVersion, skipCopyMasks, mode3D, ...
                    centerMode, superbInitAAM, skipDiTuning, centerPerturbationAmount)               
 
%for randomness  
% ( For older matlab, find equivalent randseed type function or comment these 3 lines)
t = gettime();
timeStream=RandStream('mt19937ar','Seed', t);
RandStream.setDefaultStream(timeStream)

%%
if isempty( dataDirectory )
    dataDirectory = 'OutputData/';
end
if isempty( optAlgorithm )
    optAlgorithm = 5;  %default is particle swarm (5)
end
if isempty( imageSuffix )
    imageSuffix = 'jpg';
end
if isempty( mode3D )
    mode3D = 0; %default to 2D shape
end
if isempty( superbInitAAM )
    superbInitAAM = 1;
end

imageSize = round(imageSize);
windowOptAlgorithm = 5;  %to make sure tuning window size using swarm
kernel = 1;  %0 for linear
             %1 for normalized rbf             
expFactor = 0;

%In case eye coordinates not specified
if isempty( leftEyeCoords )
    if oriNumCoords == 130
        leftEyeCoords = 2:13;
        rightEyeCoords =  15:26;
    elseif oriNumCoords == 77
        leftEyeCoords = 2:9;
        rightEyeCoords = 11:18;
    end
end    
    
% Some default max sizes
wholeMaxHW = [1.1; 1.1]; %[ 2.5; 2.5];
eyeMaxHW =  [5; 2];

% default window sizes
maxFidSizeInitialCrop = [2.2; 2.2];
wholeDefaultCropPerc = [ 1.5;1.5];
subDefaultCropPerc = [1.8 1.8 1.8 1.8 2 1.7 1.2;
                      1.8 1.8 1.8 1.8 2 1.7 1.2];

eyeDefaultCropPerc =[4;2];
                  
% subshape things
if isempty( fiducialCoordinates ) && wholeVersion == 2
    if oriNumCoords == 77
        fiducialCoordinates{1} = 1:9;
        fiducialCoordinates{2} = 10:18;
        fiducialCoordinates{3} = 19:26;
        fiducialCoordinates{4} = 27:34;
        fiducialCoordinates{5} = 35:49;
        fiducialCoordinates{6} = 50:63;
        fiducialCoordinates{7} = 64:77;
    %     fiducialCoordinates{8} = 74:76;
    %     fiducialCoordinates{9} = 65:69;
    %     fiducialCoordinates{10} = 70:73;

        %maximum percent of shape size, [h;w] for
        %   left eye, right eye, left brown, right brow, nose, mouth, outline
        fidMaxHW = [ 3.1 3.1  3.1  3.1  2.2   2.2  1.2 ; %1.1 1.1 1.1 ;
                     2.1 2.1  2.1  2.2  2.2   2.2  1.2 ]; %1.1 1.1 1.1 ];
    elseif oriNumCoords == 130
        fiducialCoordinates{1} = 1:13;
        fiducialCoordinates{2} = 14:26;
        fiducialCoordinates{3} = 27:38;
        fiducialCoordinates{4} = 39:50;
        fiducialCoordinates{5} = 51:83;
        fiducialCoordinates{6} = 84:109;
        fiducialCoordinates{7} = 110:130;

        %maximum percent of shape size, [h;w] for
        %   left eye, right eye, left brown, right brow, nose, mouth, outline
        fidMaxHW = [ 4.1 4.1  4.1  4.1  3   3  2 ; %1.1 1.1 1.1 ;
                     3.1 3.1  3.1  3.2  3   3  2 ]; %1.1 1.1 1.1 ];
    else
        error( 'SR: You must specify subshape coordinates in ''fiducialCoordinates'' variable.' );
    end
end


%% create directories, initialization stuff
% i = trialNumber;
M = [];
calcM = 0;
W0 = [];
a = [];
tol = [];

modelFile =   [  dataDirectory  'Model' int2str(trialNumber)  '_ImSize' ...
                    int2str(imageSize(1)) '_Feat' ...
                    int2str(imgFeatureMode) '_Regress' ...
                    int2str(regressionMode) '.mat' ];

commonDataFolder = [ dataDirectory 'CommonData/' ];
if ~exist( commonDataFolder, 'dir')
    mkdir( commonDataFolder)
end
resultsdirectory = [dataDirectory 'ResultSummary/'];
if ~exist( resultsdirectory, 'dir' )
    mkdir( resultsdirectory );
end
if saveIndividualCoordinates
    if ~exist( detectedCoordFolder,'dir')
        mkdir(detectedCoordFolder);
    end
end
if ~exist(  [ dataDirectory 'CVResults/' ], 'dir')
    mkdir(  [ dataDirectory 'CVResults/' ])
end

%% Load Images and Markings

tic %main shape detector timer

display('Saving images ...')  % Load and store images, create mask files
[ trainThis testThis imageMatrix coordinateMatrix X Y nameList eyeCoords maskFile maskFileFolder imageFolder] = ...
    saveTrueEyeCoordinates( commonDataFolder, database, ...
    imageSize, maxRead , maskFileFolder, showLoadingImages, ...
    reloadImagesEveryTime, percentTrain, trialNumber, nFoldCV, ...
    imageFolder, markingFolder130, markedDatabaseDirectory, ...
    leftEyeCoords, rightEyeCoords, oriNumCoords, overwriteMask, ...
    markingsVariableName, skipScaleNormalization, namePrefix, ...
    dataDirectory, imageSuffix, skipCopyMasks);

%For Lite mode
clear X Y % X is redundant, same values as imageMatrix, just vectorized
          % Y also redundant, it is [real(coordinateMatrix);
          %                         imag(coordianteMatrix) ]
          
%% Missing Data

nonMissingMask = isfinite( coordinateMatrix); %for calculating error
Wsfm = [];  % Just in case
if filterUnknownMarkings == 1   %1 for use subset with full data
    percentForKeepLandmark = .70;
    shapeCoords = findFrequentlyMarkedLandmarks( coordinateMatrix, percentForKeepLandmark );
    indexMatrix = findShapesWithKnownLandmarks( coordinateMatrix, shapeCoords );
    [trainThis testThis ] = adjustTrainTestPartitions( indexMatrix , trainThis, testThis );
    save( maskFile, 'trainThis', 'testThis');
    generateCVMask( maskFileFolder, maskFile, trialNumber, nFoldCV )
    
elseif filterUnknownMarkings == 2 %2 for NRSFM
    filledCoordinates = [ dataDirectory 'filledCoordinates' namePrefix '.mat'   ];
    if ~exist( filledCoordinates, 'file' )
        [ FilledW zCoords Wsfm] = pgNRSFM( YtoW(coordinateMatrix),  showSFM );
        coordinateMatrix = WtoY( FilledW );
        save( filledCoordinates, 'coordinateMatrix', 'FilledW', 'Wsfm', 'zCoords');
    else
        load( filledCoordinates, 'coordinateMatrix', 'FilledW', 'Wsfm', 'zCoords');
    end
elseif filterUnknownMarkings == 3 % 3 for Rigid SFM
    filledCoordinates = [ dataDirectory 'filledCoordinates' namePrefix '.mat'   ];
    if ~exist( filledCoordinates, 'file' )
        [ FilledW zCoords Wsfm ] = pgRigidNew( YtoW(coordinateMatrix),  showSFM );
        coordinateMatrix = WtoY( FilledW );
        save( filledCoordinates, 'coordinateMatrix', 'FilledW', 'Wsfm', 'zCoords');
    else
        load( filledCoordinates, 'coordinateMatrix', 'FilledW', 'Wsfm', 'zCoords');
    end
elseif filterUnknownMarkings == 4 % 4 for Rigid SFM, Coarse to fine
    filledCoordinates = [ dataDirectory 'filledCoordinates' namePrefix '.mat'   ];
    if ~exist( filledCoordinates, 'file' )
        [ FilledW zCoords Wsfm ] = pgRigidSFMCoarseToFine( YtoW(coordinateMatrix),  showSFM );
        coordinateMatrix = WtoY( FilledW );
        save( filledCoordinates, 'coordinateMatrix', 'FilledW', 'Wsfm', 'zCoords');
    else
        load( filledCoordinates, 'coordinateMatrix', 'FilledW', 'Wsfm', 'zCoords');
    end
end

%% Book-keeping for 3D detection

if mode3D && ~exist( 'zCoords', 'var')
    error( 'SR: 3D shape not constructed.  Specify an option for filterUnknownMarkings' );
end
if ~mode3D  %clear zCoords if you are just doing 2D detection
    zCoords = [];
end     

%% Centered Mode (Perfectly centered objects)
if centerMode
    cropSize = findCropSizeUltimate( 1:oriNumCoords , coordinateMatrix, [1.1 1.1] );
    cropSize = [ max( 1, cropSize(1) ) ;
                max( 1, cropSize(2) ) ];
            
    [ imageMatrix coordinateMatrix  ] = cropFiducialCenterPerturb(  imageMatrix, coordinateMatrix, ...
                1:oriNumCoords, cropSize, 0, [], 0,  1:oriNumCoords, centerPerturbationAmount ); 
end

% for lite mode
% clean up, but keep images if unwarping
% clear coordinateMatrix
if ~unwarpCoordinates
    clear imageMatrix
end

%% Algorithm/Feature Switch check stuff..  
if wholeVersion == 1 %   While shape detection
        superbInitAAM = 0;        

% this will make you fine tune lambda/sigma using PSO
fineTunePso = 0;
elseif wholeVersion == 4 %   Adaboost regression with Haar features (Shape Regression Machine)
        wholeVersion = 1; %Whole shape detection
		imgFeatureMode = 10; %Haar features
		regressionMode = 7; %Adaboost
        skipDiTuning = 1;
        skipWindowOpt =1;
        superbInitAAM = 0;
        fineTunePso =0;

elseif wholeVersion == 3 %AAM-RIK
		imgFeatureMode = 1; %Pixels
		regressionMode = 5; % doesn't actually use this, but just in case
        skipDiTuning = 1;
        skipWindowOpt =1;
        skipScaleNormalization = 1;
        fineTunePso =0;
end


if imgFeatureMode == 2 % if C1 features
        skipWindowOpt =1; 
        fineTunePso =1;
end

if regressionMode == 4 
    fineTunePso =1;
end

%% rotate and scale image by 'normalization landmarks'
algorithmStartTime = toc;  % this is timer that starts right before the algorithm 
                           % runs

if ~skipScaleNormalization   %Skip normalization
    
    % Initialize
    normLandmarksCVParameters = [ dataDirectory 'CVResults/CVNormLandmarks.' ...
        int2str(imageSize(1)) '.' ...
        int2str(eyeDist) '.' int2str(imgFeatureMode) '.' ...
        int2str(regressionMode) '.mat' ]; 
    normLandmarPCAparameters =  [ dataDirectory 'eyeDetectPCAData.mat'];
    clear doubleTuneParameters  % important

    % Tune parameters if necessary
    if ~exist( normLandmarksCVParameters, 'file')
        fiducialOffset = mean(mean( coordinateMatrix( [ leftEyeCoords(:); rightEyeCoords(:) ],trainThis), 1),2);               
        if skipWindowOpt
            display('Using default window size and position');
            tempCropSize = findCropSizeUltimate( [ leftEyeCoords(:); rightEyeCoords(:) ], ...
                coordinateMatrix(:,trainThis), eyeDefaultCropPerc );        
            if regressionMode == 4  || regressionMode == 6  %SVR or GPR
                parameters = [ .01; 5;  2; 2; [ imag(fiducialOffset);real(fiducialOffset)]; tempCropSize; 1 ];
            else
                parameters = [ .01; 5;  2; 2; [ imag(fiducialOffset);real(fiducialOffset)]; tempCropSize ];
            end
        else
            % Initialize variables
            display('Tune normalization landmark detector ...');
            parameters = [ .05; 4; 1.2 ; 1.2 ; 0; 0; .2];
            zCoordsTrain = [];
            if ~isempty( zCoords)
                zCoordsTrain = zCoords(:,trainThis );
            end
            
            %tune window size using KRR  if GPR regression used
            tempRegressionMode = regressionMode;
            if regressionMode == 6 % GPR
                tempRegressionMode = 5; 
            end

            [ parameters  paramsTemp cropSize alleyeOffsets ] = ...
                   CVSearchSimplexFaceDetector( maskFileFolder, nFoldCV, ...
                       imageMatrix(:,:, trainThis), ...
                       coordinateMatrix(:,trainThis), ...
                       W0, M, a, tol, maxSimplexIterations, kernel, ...
                       parameters, tempRegressionMode, imgFeatureMode, ...
                       trialNumber, [ leftEyeCoords(:); rightEyeCoords(:) ],...
                       calcM, windowOptAlgorithm, ...
                       [ imag(fiducialOffset);real(fiducialOffset)], eyeDist, ...
                       eyeMaxHW, dataDirectory, shapeVersion, mode3D, ...
                       zCoordsTrain);  
        
            % get error offsets for eye detections   
            numEyeCoords = length(leftEyeCoords);
            eyeDetectionOffsets = [ mean(alleyeOffsets(1:numEyeCoords,:),1) ; ...
                                    mean(alleyeOffsets(numEyeCoords*2+1:numEyeCoords*3,:),1) ; ...
                                    mean(alleyeOffsets(numEyeCoords+1:numEyeCoords*2,:),1) ; ...
                                    mean(alleyeOffsets(numEyeCoords*3+1:end,:),1) ];

            display('Learning eye error distributions...');
            [CT, mT ] = calcEyeDistribution(distScale, robustErrPercent, eyeDetectionOffsets );            
            eyeDistParams.CT = CT;
            eyeDistParams.mT = mT;
            
            % Format and save parameters
            parameters = parameters(:);
            if regressionMode == 4  %SVR needs 1 extra parameter
                parameters = [ parameters(1:6); cropSize(:); parameters(7) ];           
            else
                parameters = [ parameters(1:6); cropSize(:)  ]; 
            end           
            save( normLandmarksCVParameters, 'parameters', 'eyeDistParams' ); 
        end
    else
        load( normLandmarksCVParameters); %parameters and maybe doubleTuneParameters
    end

    %Tune just lambda/sigma with particle swarm ( for C1 features )
    if ~exist( 'doubleTuneParameters', 'var') && skipWindowOpt
        hwParameters = [ parameters(5:6); parameters(7:8) ];  %position; cropSize
        display( [ 'Tuning regression parameters for eyes ...' ] );
        [ parametersFine alleyeOffsets] = tuneLambdaSigmaEtc(  maskFileFolder, nFoldCV, ...
            imageMatrix(:,:, trainThis), coordinateMatrix(:,trainThis), ...
            W0, M, a, tol, maxSimplexIterations, kernel, ...
            parameters, regressionMode, imgFeatureMode, ...
            trialNumber, [ leftEyeCoords(:); rightEyeCoords(:) ], calcM, windowOptAlgorithm, ...
            [size(imageMatrix,1)/2 ;size(imageMatrix,2)/2] ,...
            eyeDist, wholeMaxHW, dataDirectory, hwParameters, shapeVersion, mode3D);
        parametersFine = parametersFine(:);              
        doubleTuneParameters = parameters;
        if regressionMode == 4 %SVR  (or for GPR:|| regressionMode == 6 )
            doubleTuneParameters([1:2 9]) = [ parametersFine(1:2); parametersFine(3) ];           
        else
            doubleTuneParameters([1:2]) = [ parametersFine(1:2) ];  
        end
        
        % get error offsets for eye detections
        numEyeCoords = length(leftEyeCoords);
        eyeDetectionOffsets = [ mean(alleyeOffsets(1:numEyeCoords,:),1) ; ...
                                mean(alleyeOffsets(numEyeCoords*2+1:numEyeCoords*3,:),1) ; ...
                                mean(alleyeOffsets(numEyeCoords+1:numEyeCoords*2,:),1) ; ...
                                mean(alleyeOffsets(numEyeCoords*3+1:end,:),1) ];

        display('Learning eye error distributions...');
        [CT, mT ] = calcEyeDistribution(distScale, robustErrPercent, eyeDetectionOffsets );            
        eyeDistParams.CT = CT;
        eyeDistParams.mT = mT;
        
        % Store parameters for later use
        save( normLandmarksCVParameters, 'parameters', 'doubleTuneParameters', 'eyeDistParams' );
    end 
    
    % Re-tune lambda/sigma with Di's KRR criterion
    % This only runs if doubleTuneParameters not found, important!
    if ~exist( 'doubleTuneParameters', 'var')
        if skipDiTuning || ( regressionMode ~= 5)
            doubleTuneParameters = parameters;
        else
            display( 'Fine tuning lambda and sigma for KRR');
            doubleTuneParameters = diCriterionKRRWrapper(  parameters, imageMatrix(:,:, trainThis),  ...
                    coordinateMatrix(:,trainThis), [ leftEyeCoords(:); rightEyeCoords(:) ], normLandmarPCAparameters, ...
                    imgFeatureMode, shapeVersion, mode3D, [] );
        end
        
        % display( 'Fine tuned parameters:');
        % doubleTuneParameters'
        save( normLandmarksCVParameters, 'parameters', 'doubleTuneParameters', 'eyeDistParams' );
    end
    
    % Detects all eye landmarks
    [eyeDetections shapeDetectionModes detections3D]  = ...
        faceShapeDetector( imageMatrix, coordinateMatrix, ...
            maskFile, regressionMode, kernel, imgFeatureMode, ...
            doubleTuneParameters, debugEyeDetector, ...
            [ leftEyeCoords(:); rightEyeCoords(:) ], ...
            W0,M, a, tol, maxSimplexIterations, ...
            calcM, modelFile, normLandmarPCAparameters, ...
            shapeVersion, mode3D, zCoords);
    
    % Average out the landmarks to get the center eye detections
    eyeDetectionsY = sideRealToY(eyeDetections);
    leftEye = mean( eyeDetectionsY(1:length(leftEyeCoords),:),1);
    rightEye = mean( eyeDetectionsY(length(leftEyeCoords)+1:end,:),1);
    eyeDetections = [ real(leftEye); imag(leftEye); real(rightEye); imag(rightEye) ];
    
    % Rotate Images according to eye Detections
    display( 'Rotating Object ...');
    [ rotatedImageMatrix rotatedCoordinateMatrix ] = rotateFaces(imageMatrix, ...
        [real(coordinateMatrix); imag(coordinateMatrix) ], trialNumber, ...
        eyeDist, expFactor, oriNumCoords, eyeCoords, ...
        eyeDistParams, debugRotation, eyeDetections, trainThis, ...
        testThis, dataDirectory);  
else
    %quick renaming of variables
    rotatedCoordinateMatrix = coordinateMatrix;  
    rotatedImageMatrix = imageMatrix;
    save([  dataDirectory 'RotatedFaceDataEyeDetector' int2str(trialNumber) '.mat' ], ...
        'rotatedCoordinateMatrix', 'rotatedImageMatrix');
end

%% Whole Shape Detection

% runs for whole/sub/AAM shape detection    
if (wholeVersion == 1 || wholeVersion == 2 ) ...
        ||  (wholeVersion == 3 && superbInitAAM )
    
    % initialize some variables
    mainObjectCVParameters = [ dataDirectory 'CVResults/CVMainObj.' int2str(imageSize(1)) '.' ...
        int2str(eyeDist) '.' int2str(imgFeatureMode) '.' ...
        int2str(regressionMode) '.mat' ];
    
    % Do some things differently is subshapes    
    if wholeVersion == 2
        mainObjectCVParameters =  [ dataDirectory 'CVResults/CVMainObjSub.' ...
            int2str(imageSize(1)) '.' ...        
            int2str(eyeDist) '.' int2str(imgFeatureMode) '.' ...
            int2str(regressionMode) '.mat' ];
    
        % get the fiducial coordinates in the matrix
        % update shape coordinates vector to account for this
        rotatedCoordinateMatrixBackup = rotatedCoordinateMatrix;
        shapeCoordsBackup = shapeCoords;
        clear rotatedCoordinateMatrix shapeCoords
        for i3 = 1:length(fiducialCoordinates)
            rotatedCoordinateMatrix(i3,:) =  [ mean(rotatedCoordinateMatrixBackup(fiducialCoordinates{i3},:),1) ]  ;
        end      
        shapeCoords = 1:length(fiducialCoordinates);
    end
    
    %Initialize things
    clear doubleTuneParameters  % important      
    fiducialOffset = mean(mean( rotatedCoordinateMatrix(shapeCoords(:),trainThis), 1),2);               
    PCAparameters = [ dataDirectory 'wholeShapePCAParameters.mat' ];
    objectDistParams = [];
    
    %Tune parameters if they are not already saved
    if ~exist( mainObjectCVParameters, 'file')
        
        %Check if you should use default window
        if skipWindowOpt  
            pushDownFace = 0; %100;  HERE FIX THIS
            
            % Use default window
            display('Using default window size and position');
            tempCropSize = findCropSizeUltimate( shapeCoords, rotatedCoordinateMatrix(:,trainThis), wholeDefaultCropPerc );
            if regressionMode == 4  %SVR  ( 6,for GPR)     
                parameters = [ .01; 5;  2; 2; [ imag(fiducialOffset)+pushDownFace;real(fiducialOffset)]; tempCropSize; 1 ];
            else
                % HERE
                parameters = [ .01; 5;  2; 2; [ imag(fiducialOffset)+pushDownFace;real(fiducialOffset)]; tempCropSize ];
            end 
        else
            %Tune window size and position
            display('Tune window size and position ...');
            parameters = [ .05; 4; 1.2 ; 1.2 ; 0; 0; .2];
            zCoordsTrain = [];
            if ~isempty( zCoords)
                zCoordsTrain = zCoords(:,trainThis);
            end
            
            %Tune window size using KRR if GPR regression used
            tempRegressionMode = regressionMode;
            if regressionMode == 6 % GPR
                tempRegressionMode = 5; 
            end
            
            % Tune r, lambda, sigma
            [ parameters paramsTemp cropSize YtrueMinusEstTotal] = ...
                CVSearchSimplexFaceDetector( ...
                maskFileFolder, nFoldCV, ...
                rotatedImageMatrix(:,:, trainThis ), ...
                rotatedCoordinateMatrix(:,trainThis ), ...
                W0, M, a, tol, maxSimplexIterations, kernel, ...
                parameters, tempRegressionMode, imgFeatureMode, ...
                trialNumber, shapeCoords, calcM, windowOptAlgorithm, ...
                [ imag(fiducialOffset);real(fiducialOffset)],...
                eyeDist, wholeMaxHW, dataDirectory, shapeVersion, ...
                mode3D, zCoordsTrain);
            parameters = parameters(:);
            if regressionMode == 4  %SVR needs epsSVR parameter 
                parameters = [ parameters(1:6); cropSize(:); parameters(7) ];           
            else
                parameters = [ parameters(1:6); cropSize(:)  ]; 
            end
            % YtrueMinusEstTotal is offset in terms of all X over all Y
            
            
            % if you are doing subshapes algorithm, combined landmarks into
            % MOSTLY FOR subshapes 
            display('Learning shape error distributions...');
            [CT, mT ] = calcEyeDistribution(distScale, robustErrPercent, YtrueMinusEstTotal );            

            objectDistParams.CT = CT;
            objectDistParams.mT = mT;
            
        end
        save( mainObjectCVParameters, 'parameters', 'objectDistParams');
    else
        load( mainObjectCVParameters); %, 'parameters', maybe 'doubleTuneParameters' ;
    end
      
    %Tune just lambda/sigma with particle swarm ( for C1 features )
    if ~exist( 'doubleTuneParameters', 'var')  && skipWindowOpt
        hwParameters = [ parameters(5:6); parameters(7:8) ];  %position; cropSize
        display( [ 'Tuning regression parameters ...' ] );
        [ parametersFine YtrueMinusEstTotal] = tuneLambdaSigmaEtc(  maskFileFolder, nFoldCV, ...
            rotatedImageMatrix(:,:, trainThis), rotatedCoordinateMatrix(:,trainThis), ...
            W0, M, a, tol, maxSimplexIterations, kernel, ...
            parameters, regressionMode, imgFeatureMode, ...
            trialNumber, shapeCoords, calcM, windowOptAlgorithm, ...
            [size(rotatedImageMatrix,1)/2 ;size(rotatedImageMatrix,2)/2] ,...
            eyeDist, wholeMaxHW, dataDirectory, hwParameters, shapeVersion, mode3D);
        parametersFine = parametersFine(:);              
        doubleTuneParameters = parameters;
        if regressionMode == 4 %SVR  (or for GPR:|| regressionMode == 6 )
            doubleTuneParameters([1:2 9]) = [ parametersFine(1:2); parametersFine(3) ];           
        else
            doubleTuneParameters([1:2]) = [ parametersFine(1:2) ];  
        end  
        
        display('Learning shape error distributions...');
        [CT, mT ] = calcEyeDistribution(distScale, robustErrPercent, YtrueMinusEstTotal );            

        objectDistParams.CT = CT;
        objectDistParams.mT = mT;

        % Store parameters for later use
        save( mainObjectCVParameters, 'parameters', 'doubleTuneParameters', 'objectDistParams' );
    end             

    % Optional Di KRR criterion
    if ~exist( 'doubleTuneParameters', 'var')
        display( 'Fine tuning lambda and sigma for KRR');
        zCoordsTrain = [];
        if ~isempty( zCoords)
            zCoordsTrain = zCoords(:,trainThis);
        end                
        if skipDiTuning || ( regressionMode ~= 5)
            doubleTuneParameters = parameters;
        else
            %Di KRR criterion 
            doubleTuneParameters = diCriterionKRRWrapper(  parameters, rotatedImageMatrix(:,:, trainThis),  ...
                    rotatedCoordinateMatrix(:,trainThis), shapeCoords, PCAparameters, ...
                    imgFeatureMode, shapeVersion, mode3D, zCoordsTrain );
        end
        %         display( 'Fine tuned parameters:');
        %         doubleTuneParameters'    
        save( mainObjectCVParameters, 'parameters', 'doubleTuneParameters', 'objectDistParams'  );
    end
    
    % Detecting the whole shape
    display( 'Detecting Whole Shape ... ');
    [detectedFaceCoordinates shapeDetectionModes detections3D]  = ...
        faceShapeDetector( rotatedImageMatrix, rotatedCoordinateMatrix, ...
            maskFile, regressionMode, kernel, imgFeatureMode, ...
            doubleTuneParameters, debugFaceShapeDetector, shapeCoords, ...
            W0,M, a, tol, maxSimplexIterations, ...
            calcM, modelFile, PCAparameters, shapeVersion, ...
            mode3D, zCoords);
end


%% Subshapes Section -----------------------------------
  
if wholeVersion == 2  %Subshapes

    % Initialize some variables  
    shapeCoords = shapeCoordsBackup;
    rotatedCoordinateMatrix = rotatedCoordinateMatrixBackup;
    
    % Put the fiducial detection in right spot in YfidPerturbed
    YfidPerturbed = rotatedCoordinateMatrix;          
    detectedFaceCoordinatesComplex = sideRealToY( detectedFaceCoordinates );    
    for i3 = 1:length(fiducialCoordinates)
        YfidPerturbed(fiducialCoordinates{i3},testThis) = repmat( detectedFaceCoordinatesComplex(i3,:), [length(fiducialCoordinates{i3}),1]);
    end
                % find the position detection error, so that the density
                % can be trained correctly
% %                 YtrueMinusEstTotalBackup = YtrueMinusEstTotal;
% %                 clear YtrueMinusEstTotal
% %                 for i3 = 1:length(fiducialCoordinates)
% %                     YtrueMinusEstTotal(i3,:) =  [ mean(YtrueMinusEstTotalBackup(fiducialCoordinates{i3},:),1) ]  ...
% %                          + 1i*[ mean(YtrueMinusEstTotalBackup(fiducialCoordinates{i3}+size(YtrueMinusEstTotalBackup,1)/2,:),1) ] ;
% %                 end
% %                 YtrueMinusEstTotal = [ real(YtrueMinusEstTotal); imag( YtrueMinusEstTotal) ];
                    
    % Perturb the training samples    
    CT = objectDistParams.CT;
    mT = objectDistParams.mT;
    Enoise = mvnrnd( mT', CT, length(trainThis))';
    complexEnoise = Enoise(1:size(Enoise,1)/2,:) + 1i*Enoise(size(Enoise,1)/2+1:end,:);
    
    % I was trying other things with this
    % % % This repeated over fiducials 
    % % for i3  = 1:length(fiducialCoordinates)
    % %     Enoise = repmat(  complexEnoise(i3,:), [length(fiducialCoordinates{i3}),1] );
    % %     YfidPerturbed( fiducialCoordinates{i3},trainThis) = ...
    % %         YfidPerturbed( fiducialCoordinates{i3},trainThis) + Enoise;
    % % end
    
    % For every fiducial
    for k1 = 1:length( fiducialCoordinates ) %detect each fiducial shape
        
        % Initialize and clear data
        modelFile =   [  dataDirectory  'Model' int2str(trialNumber)  '_ImSize' ...
            int2str(imageSize(1)) '_Feat' ...
            int2str(imgFeatureMode) '_Regress' ...
            int2str(regressionMode) '_Fid' int2str(k1) '.mat' ];
        mainObjectCVParameters = [ dataDirectory 'CVResults/CVFiducial' ...
            int2str(k1) '.' int2str(imageSize(1)) '.' ...
            int2str(eyeDist) '.' int2str(imgFeatureMode) '.' ...
            int2str(regressionMode) '.mat' ];               
        PCAparameters = [ dataDirectory 'Fiducial' int2str(k1) 'PCAparameters.mat'];
        clear doubleTuneParameters  parameters% important 
        
        % Calculate amount to perturb training samples
        offset = zeros( 1, size(YfidPerturbed,2));
        offset( 1,trainThis) = complexEnoise(k1,:);
            
        %crop fiducial here, then feed that to next part of system
        debugCropFiducial = 0;
%         testThis'
        
        fidCropSize = findCropSizeUltimate( fiducialCoordinates{k1} , YfidPerturbed, maxFidSizeInitialCrop );
        [ Xfid Yfid cropPosUnpadded] = cropFiducial( rotatedImageMatrix, YfidPerturbed, ...
            shapeCoords, fidCropSize, 0, ...
            offset, debugCropFiducial, fiducialCoordinates{k1} );
        fiducialOffset = mean(mean( Yfid(fiducialCoordinates{k1},trainThis), 1),2);   
                                                        

        % Check to see if CV parameters have been saved.  If not, go
        % through the first Stage of tuning.
        if ~exist( mainObjectCVParameters, 'file') 
            if skipWindowOpt
                
                % Not crop the shapes with a crop sized based on the
                % maximum size of aligned shapes
                display('Using default window size and position');
                tempCenteredShapes =  rotatedCoordinateMatrix -  repmat( mean(rotatedCoordinateMatrix,1), [size(rotatedCoordinateMatrix,1), 1] ); 
                tempCropSize = findCropSizeUltimate( fiducialCoordinates{k1}, tempCenteredShapes(:,trainThis), subDefaultCropPerc(:,k1) );       
                if regressionMode == 4  || regressionMode == 6  %SVR or GPR
                    parameters = [ .01; 5;  2; 2; [ imag(fiducialOffset);real(fiducialOffset)]; tempCropSize; 1 ];
                else
                    parameters = [ .01; 5;  2; 2; [ imag(fiducialOffset);real(fiducialOffset)]; tempCropSize ];
                end

            else
                % Tune Fiducial parameters
                display( [ 'Tuning fiducial ' int2str(k1) ' window size and position ...' ] );
                parameters = [ .05; 4; 1.2 ; 1.2 ; 0; 0; .2];
                zCoordsTrain = [];
                if ~isempty( zCoords)
                    zCoordsTrain = zCoords(:,trainThis );
                end

                %tune window size using KRR if GPR regression used
                tempRegressionMode = regressionMode;
                if regressionMode == 6 % GPR
                    tempRegressionMode = 5; 
                end
                
                % Run the cross validation
                [ parameters paramsTemp cropSize ] = CVSearchSimplexFaceDetector( maskFileFolder, nFoldCV, ...
                    Xfid(:,:, trainThis), ...
                    Yfid(:,trainThis), ...
                    W0, M, a, tol, maxSimplexIterations, kernel, ...
                    parameters, tempRegressionMode, imgFeatureMode, ...
                    trialNumber, fiducialCoordinates{k1}, calcM, windowOptAlgorithm, ...
                    [ imag(fiducialOffset);real(fiducialOffset)], eyeDist, ...
                    fidMaxHW(:,k1), dataDirectory, shapeVersion, mode3D, ...
                    zCoordsTrain);  
                parameters = parameters(:);

                % Format parameters for different regression styles
                if regressionMode == 4  %SVR 
                    parameters = [ parameters(1:6); cropSize(:); parameters(7) ];           
                else
                    parameters = [ parameters(1:6); cropSize(:)  ]; 
                end 
            end
            save( mainObjectCVParameters, 'parameters');
        else
            load( mainObjectCVParameters ); %, 'parameters', maybe 'doubleTuneParameters' ;
        end

        %Tune just lambda/sigma with particle swarm ( for C1 features )
        if ~exist( 'doubleTuneParameters', 'var')  && skipWindowOpt
            hwParameters = [ parameters(5:6); parameters(7:8) ];  %position; cropSize
            display( [ 'Tuning fiducial ' int2str(k1) ' regression parameters ...' ] );
            [ parametersFine YtrueMinusEstTotal] = tuneLambdaSigmaEtc( maskFileFolder, nFoldCV, ...
                Xfid(:,:, trainThis), Yfid(:,trainThis), ...
                W0, M, a, tol, maxSimplexIterations, kernel, ...
                parameters, regressionMode, imgFeatureMode, ...
                trialNumber, fiducialCoordinates{k1}, calcM, optAlgorithm, ...
                [ imag(fiducialOffset);real(fiducialOffset)], eyeDist, ...
                fidMaxHW(:,k1),  dataDirectory, hwParameters, shapeVersion, mode3D);
            parametersFine = parametersFine(:);              
            doubleTuneParameters = parameters;
            
            if regressionMode == 4  %SVR  (or for GPR:|| regressionMode == 6 )
                doubleTuneParameters([1:2 9]) = [ parametersFine(1:2); parametersFine(3) ];           
            else
                doubleTuneParameters([1:2]) = [ parametersFine(1:2) ];  
            end  
            save( mainObjectCVParameters, 'parameters', 'doubleTuneParameters' );
        end             


        % Optional parameter refinement with Di's KRR criterion
        if ~exist( 'doubleTuneParameters', 'var') 
            display( 'Fine tuning lambda and sigma for KRR'); 
            zCoordsTrain = [];
            if ~isempty( zCoords)
                zCoordsTrain = zCoords(fiducialCoordinates{k1},trainThis);
            end
            
            % Check if supposed to use Di KRR criterion
            if skipDiTuning || ( regressionMode ~= 5)
                doubleTuneParameters = parameters;
            else
                % Tune parameters further using Di's KRR criterion
                doubleTuneParameters = diCriterionKRRWrapper(  parameters, Xfid(:,:, trainThis),  ...
                    Yfid(:,trainThis), fiducialCoordinates{k1}, PCAparameters, ...
                    imgFeatureMode, shapeVersion, mode3D, zCoordsTrain );
            end            
            % display( 'Fine tuned parameters:');
            % doubleTuneParameters'
            save( mainObjectCVParameters, 'parameters', 'doubleTuneParameters' );
        end
        
        
        
%         debugFaceShapeDetector = 1;
        
        
        
        % Detecting fiducial ( with doubleTuneParameters )
        display(  [ 'Detecting Fiducial ' int2str(k1) ' ... ' ]);        
        [detectedFaceCoordinatesTemp  shapeDetectionModesTemp detections3DTemp ] = ...
            faceShapeDetector( Xfid, Yfid, maskFile, ...
                regressionMode, kernel, imgFeatureMode, ...
                doubleTuneParameters, debugFaceShapeDetector, fiducialCoordinates{k1}, ...
                W0,M, a, tol, maxSimplexIterations, ...
                calcM, modelFile, PCAparameters, shapeVersion, ...
                mode3D, zCoords);
         
        % shapeDetectionModes = [ shapeDetectionModes; shapeDetectionModesTemp ];
        fidCoord = fiducialCoordinates{k1};
        detectedFaceCoordinates(fidCoord(:), : ) = detectedFaceCoordinatesTemp;
        
            
        %apply offset associated with localizing and cropping fiducial
        testCropPositionOffset = zeros( 1, 2*length(testThis));
        testCropPositionOffset(1,1:2:end) = real(cropPosUnpadded(1,testThis))-1;  %-1 for single pixel bias necessary when repositions in image
        testCropPositionOffset(1,2:2:end) = imag(cropPosUnpadded(1,testThis))-1;  %-1 for single pixel bias necessary when repositions in image
        detectedFaceCoordinates(fidCoord(:), : ) = detectedFaceCoordinates(fidCoord(:), : ) ...
                  + repmat( testCropPositionOffset, [length(fidCoord), 1] );
                    
        if ~isempty( detections3DTemp ) 
            detections3D( fidCoord(:), : ) = detections3DTemp;
        end
    end 
end
       
%%
if wholeVersion == 3  %AAM with RIK shape detection (initilized with whole shape
    
    % Initialize variables
    detections3D = [];
    shapeDetectionModes = [];
    noiters = 20;
    scaleFactor = 1;
    modelFileAAM = [ dataDirectory 'AAMData/AAMRIKTrainedModel' int2str(trialNumber) '.mat'];

    % Crop face and train AAM
    display('crop faces for AAM');
    cropFaceForAAM(trialNumber, maskFile, debugCropWholeForAAM, eyeDist, dataDirectory, shapeCoords );
    srMain_AAM_RIK( trialNumber, noiters, showAAM, scaleFactor, modelFileAAM, dataDirectory );
    
    % Load AAM
    load( modelFileAAM );
    if ~exist( 'detectedFaceCoordinates', 'var')
        detectedFaceCoordinates = [];
    end
    
    % Fit AAM
    detectedFaceCoordinates = srTesting( trialNumber, trialNumber, scaleFactor, X, ...
        Xmvn, Q , Xim, ddim, vim, vR3N, ddR3N,bw,mXR,A, ...
        ACOEF,noiters, Cim, showAAM,mean_Xmvn, mean_Xim,ws,invp,tt, ...
        tri,ii_ipp,jj_ipp,stdu1,stdu2,sigma1,sigma2,K_CR3N, ...
        detectedFaceCoordinates, dataDirectory, superbInitAAM );                 
end


%%  Conditional density learning with 
%   Application to shape detection algorithm 

if wholeVersion == 5
    
    %Initialize variables
    detections3D = [];
    shapeDetectionModes = [];     
    numRegressionLayers = 3;
    shapeParameterFile = [dataDirectory 'CDLShapeParameters' int2str(trialNumber) '.mat'];     
    shapePercent = .85;
    nBins = 40;
    nWeak = 500;
    numTrainExpansion = 5;
    controlPoints = [];
    modelFile = [dataDirectory 'CDLModelParameters' int2str(trialNumber) '.mat'];     
    
    % Main shape detection function
    Yunformatted = mainCDL( rotatedImageMatrix, rotatedCoordinateMatrix, ...
        trainThis, testThis, numRegressionLayers, ...
        shapeVersion, mode3D, shapeParameterFile, ...
        shapePercent, nBins, nWeak, numTrainExpansion,...
        controlPoints, modelFile);
    detectedFaceCoordinates =  YtoSideReal( Yunformatted );    
end

%%  Timer stuff  ------------------------------------
detectionTime = abs(toc - algorithmStartTime); %end of main detection timer
displayString = sprintf( 'Detection Time for %d images: %f seconds.  %f seconds per image.', ...
            length(testThis), detectionTime, detectionTime/length(testThis)  ); 
display( displayString)
clear detectionTime displayString

%% Summarize Error results
tempSFMY = WtoY(Wsfm);
meanZ = [];
zCoordsTest = [];
tempSFMYTest = [];
if ~isempty( zCoords)
    meanZ = mean( zCoords(shapeCoords,trainThis), 2);
    zCoordsTest = zCoords(shapeCoords,testThis);
    tempSFMYTest = tempSFMY(shapeCoords,testThis);
end

% % 
% % [ allE allRMSE allPerc  allESFM allRMSESFM allPercSFM allEmu allRMSEmu  ...
% %   allPercmu allE3D allRMSE3D allEPerc3D allE3Dmu allRMSE3Dmu allEPerc3Dmu] = ...
% %        summarizeErrors( rotatedCoordinateMatrix(shapeCoords,testThis), ...
% %             detectedFaceCoordinates(:,1:2:end)+1i*detectedFaceCoordinates(:,2:2:end), ...
% %             zCoordsTest, detections3D, nonMissingMask(shapeCoords,testThis), ...
% %             tempSFMYTest, mean( rotatedCoordinateMatrix(shapeCoords,trainThis),2), ...
% %             meanZ );
% % 
% % % display( [ 'Total number landmarks: ' int2str(length(allE)) ]);
% % % display( [ 'average RMSE = ' num2str(mean(allRMSE)) ] );
% % % display( [ 'average Variance of RMSE = ' num2str(var(allRMSE)) ] );
% % 
% % display( [ 'Total number landmarks: ' int2str(length(allE)) ]);
% % display( [ 'Average pixel error = ' num2str(mean(allE)) ] );
% % % display( [ 'Average variance of pixel error = ' num2str(var(allE)) ] );
% % 
% % 
% % % for saving detections in a .mat file
% % % detectedCoordinatesFile = [dataDirectory 'shapeDetection'
% % % int2str(trialNumber) '.mat'] ;
% % % save( detectedCoordinatesFile, 'detectedFaceCoordinates' );
% % 
% % save( [ resultsdirectory 'errorResults' int2str(trialNumber) '.mat'] , 'allE', 'allRMSE', ...
% %             'allPerc',  'allESFM', 'allRMSESFM', 'allPercSFM', 'allEmu', 'allRMSEmu', ...
% %             'allPercmu', 'allE3D', 'allRMSE3D', 'allEPerc3D', 'allE3Dmu', 'allRMSE3Dmu', ...
% %             'allEPerc3Dmu' );

%% unwarp coordinates from detected to original 
if unwarpCoordinates
    unWarpCoordinates( trialNumber,detectedFaceCoordinates, detectedCoordFolder,  showUnwarping, ...
        commonDataFolder, database, maskFile, saveIndividualCoordinates, ...
        VJDetectionsFolder, oriImageFolder, dataDirectory, skipScaleNormalization, ...
        shapeDetectionModes, testThis, imageMatrix, coordinateMatrix, detections3D, ...
        imageFolder);     
end
             
% cleanItUp(needItClean, dataDirectory)
display( 'Finished!');


