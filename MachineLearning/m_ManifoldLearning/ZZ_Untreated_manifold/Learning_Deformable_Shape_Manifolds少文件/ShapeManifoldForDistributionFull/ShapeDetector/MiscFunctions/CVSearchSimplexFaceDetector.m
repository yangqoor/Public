%Samuel Rivera
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)

% x is optimized paramters
function [ x paramsTemp cropSize YtrueMinusEstTotal shapeModeParams] = CVSearchSimplexFaceDetector(  maskFileFolder, ...
                        nFold, X, Y, W0, M,...
                        a, tol, maxIters, kernel, x0, regressionMode, ...
                        imgFeatureMode, index, shapeCoords, calcM, optAlgorithm, ...
                        fiducialOffset, eyeDist, maxHW, dataDirectory, shapeVersion, ...
                        mode3D, zCoords)
     
    % Initialize variables,   clear old shape paramters 
    tempPCAName = [ dataDirectory 'tempShapePCAParamFile.mat'];
    shapeCoords = shapeCoords(:);  
    if exist( tempPCAName, 'file')
        delete( tempPCAName );
    end
    if isempty( fiducialOffset )
        fiducialOffset = [ 0; 0];
    end
    for j = 1:nFold
        maskFile{j} = [maskFileFolder 'CVmaskFile' int2str(index) '.' int2str(j) '.mat'];
    end

    %customized cost function
    f = @(params)customCVcost( X, Y, W0, M, a, tol, maxIters, kernel, params, ...
                           regressionMode, maskFile, nFold, ...
                           imgFeatureMode, shapeCoords, calcM, tempPCAName, ...
                           shapeVersion, mode3D, zCoords );
                       
    paramsTemp = [];
    %if not SVR, use the first 6 params, else uses 7
    if regressionMode ~= 4 %SVR ( && regressionMode ~= 6   or GPR) 
        x0 = x0(1:6);
    end
        
    if optAlgorithm == 1 %simplex 
        options = optimset('MaxIter', 25, 'Display', 'iter', 'TolX', .001, 'TolFun', .0001);
        % options.zero_term_delta = .2; 
        % options.usual_delta = [.2; .2; .2; .2; 1; 1];
        % [x,fval,exitflag,output] = fminsearchOS( f ,x0, options);    
        [x,fval,exitflag,output] = fminsearch( f ,double(x0), options); 
    elseif optAlgorithm == 2 % R algorithm
        prob = ooAssign( f, x0 ); % ...
        paramsTemp = ooRun(prob, 'ralg');
        x = paramsTemp.xf;    
    elseif optAlgorithm == 3  %simulated annealing
        prob = ooAssign( f, x0 ); % ...
        paramsTemp = ooRun(prob, 'anneal');
        x = paramsTemp.xf;         
    elseif optAlgorithm == 5 %particle swarm
        if regressionMode == 5 || regressionMode == 8
                            % Boundary terms cerrespond to:
                            %MIN: lambda, sigma, heighPerc, widthPerc, ...
                    %                   yTransl, xTransl, epsSVR
                            %MAX: lambda, sigma, heighPerc,widthPerc, ...
                            %           yTransl, xTransl, epsSVR
%             psoBoundary = [.05  .3    .8       .8     -.3*eyeDist+fiducialOffset(1)  -.3*eyeDist+fiducialOffset(2) ; % Boundary Min
%                              3  8   maxHW(1)  maxHW(2) .3*eyeDist+fiducialOffset(1) .3*eyeDist+fiducialOffset(2) ]; % Boundary Min
%         else
%             psoBoundary =  [.05 .3    .6        .6    -.3*eyeDist+fiducialOffset(1) -.3*eyeDist+fiducialOffset(2) .01 ; % Boundary Min
%                              3  8  maxHW(1)  maxHW(2)  .3*eyeDist+fiducialOffset(1)   .3*eyeDist+fiducialOffset(2) 3];   % Boundary Max
%         end
        
        % This assumes the object image should be centered.  
        % You can comment the following and uncomment the above to 
        % also optimize the image position! 
            psoBoundary = [.01  .05    .8       .8          0*eyeDist+fiducialOffset(1)  .01*eyeDist+fiducialOffset(2) ; % Boundary Min
                            1   8   maxHW(1)  maxHW(2) 0*eyeDist+fiducialOffset(1)  .01*eyeDist+fiducialOffset(2) ]; % Boundary Min
                     
% %         elseif regressionMode == 4  % eps-SVR
% %             psoBoundary =  [.01  1    .6        .6     0*eyeDist+fiducialOffset(1)  .01*eyeDist+fiducialOffset(2) .01 ; % Boundary Min
% %                               2  20  maxHW(1)  maxHW(2)  0*eyeDist+fiducialOffset(1)  .01*eyeDist+fiducialOffset(2) .3];   % Boundary Max
% %             
            
        else    
            psoBoundary =  [.01 .05    .8        .8     0*eyeDist+fiducialOffset(1)  .01*eyeDist+fiducialOffset(2) .01 ; % Boundary Min
                              1  8  maxHW(1)  maxHW(2)  0*eyeDist+fiducialOffset(1)  .01*eyeDist+fiducialOffset(2) .3];   % Boundary Max
        end
        
        options = psooptimset('Generations', maxIters, 'Display', 'iter', 'TolCon', ...
                            .001, 'TolFun', .001, ...
                            'PopInitRange', psoBoundary, ...
                            'PopulationSize', 50); % This is so I can 
                                 % do a grid search, Normally 300 or
                                 % so, but for speed we cut it down
       
        if regressionMode == 4 %SVR (|| regressionMode == 6  GPR) 
            [x,fval,exitflag,output,population,scores] = ...
                pso(f, 7, [], [], [], [], ...
                    psoBoundary(1,:), psoBoundary(2,:),[],options);                 
        else
            
            [x,fval,exitflag,output,population,scores] = ...
                pso(f, length(x0),[], [], [], [], ...
                    psoBoundary(1,:), psoBoundary(2,:),[],options);  
        end
    else
        error( 'SR: Improper optAlgorithm specified' );
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
    epsSvr = .1;
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


end

function x = customCVcost( X, Y, W0, M, a, tol, maxIters, kernel, params, ...
                            regressionMode, maskFile, nFold, imgFeatureMode, ...
                            shapeCoords, calcM, tempPCAName, shapeVersion, ...
                            mode3D, zCoords)                       
%     params
    
    % Initialize variables
    showIt=0;  doItFast = 1;
    lambda = params(1);
    sigma = params(2);
    percentScaleForCropSize = params(3:4);
    eyeCropPosition = params(5:6);
    eyeCropPosition = eyeCropPosition(:);
    epsSvr = .1;
    if regressionMode == 4 % SVR( || regressionMode == 6  %(SVR or GPR) )
         epsSvr = params( 7 );
    end

    % Find crop size
    cropSize = findCropSizeUltimate( shapeCoords(:) , Y,  ...
        percentScaleForCropSize );
    cropSize = [ max( 1, cropSize(1) ) ;
        max( 1, cropSize(2) ) ];
            
    % Crop image regions    
    [ X2 Y2 ] = cropFiducial( X,  Y, shapeCoords, cropSize, 0, [], ...
        showIt, eyeCropPosition );
    if ~isempty( zCoords)
        zCoords = zCoords(shapeCoords ,:);
    end
    
    % Normalize data ( Images and shapes )
    Y2 = [real( Y2); imag(Y2); zCoords] ;  
    [ nX Yw ] = normalizeDataUltimate( tempPCAName, ...
                X2 , Y2,  ...
                1:size(Y2,2), doItFast, imgFeatureMode, [], ...
                calcM, shapeVersion, mode3D);             
                
    % lambda/sigma stuff for doing right type of regression
    if (lambda <= 0 || (sigma <= 0 || epsSvr  <= 0 ) )
        x = 10000 + abs(lambda) + abs(sigma) + abs(epsSvr);
    elseif  sum( percentScaleForCropSize < 0)
        x = 100000 + abs(lambda) + abs(sigma) + sum( abs(percentScaleForCropSize));
    else
        
        time1 =toc; %for timing each iteration
        
        % Use GCV criterion if doing KRR
        if regressionMode == 5 % GCV for KRR
            x = srGCV( nX, Yw, lambda, sigma );
           
            
        elseif regressionMode == 8 % GCV for KRR
            x = srGCVCurveKRR( nX, Yw, lambda, sigma );
            
        else

            % standard N-fold regression
            % x = 0;
            error = zeros(nFold,1);
            

            
            %make train/test cells
            allTrain = cell(nFold,1);
            allTest = cell(nFold,1);
            for k = 1:nFold
               load( maskFile{k} ); %load up train/test partitions 
               allTrain{k} = trainThis;
               allTest{k} = testThis;
            end
            
            %I am doign some experimental parallel for things 
            %matlabpool local 4 %4 ECE, 8 OSC 
            
            %parfor k = 1:nFold
            
            for k = 1:nFold  
                
                trainThis = allTrain{k};
                testThis = allTest{k};
                error(k) = runRegressionUltimate( nX(:,trainThis),  nX(:,testThis), ...
                        Yw(:,trainThis),  Yw(:,testThis), W0,M, a, tol, maxIters, ...
                        kernel, [lambda; sigma; epsSvr], regressionMode, 0, []);
                    
                
                % Old way I got error
                % x = x + runRegressionUltimate( nX(:,trainThis),  nX(:,testThis), ...
                %         Yw(:,trainThis),  Yw(:,testThis), W0,M, a, tol, maxIters, ...
                %         kernel, [lambda; sigma; epsSvr], regressionMode, 0, []);

            end
            
            
            %matlabpool close     % destroying the local pool
            
            % x = norm(error, 'fro').^2;
            % Old way I got error
            x = sum(abs(error))./nFold;  % HERE test
            

        end
        
        %time one iteration of the optimization
% %         time2 = toc - time1
% %         pause(.1);
    end
end
