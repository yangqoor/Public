%Samuel Rivera
%uses simplex
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, Di You and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function [ x  YtrueMinusEstTotal shapeModeParams] = tuneLambdaSigmaSkipDensityMOG(  maskFileFolder, ...
                        nFold, X, Y, W0, M,...
                        a, tol, maxIters, kernel, x0, regressionMode, ...
                        imgFeatureMode, index, shapeCoords, calcM, optAlgorithm, ...
                        fiducialOffset, eyeDist, maxHW, dataDirectory, ...
                        hwParameters, shapeVersion, mode3D, shapePercent, fiducialCoordinates)
                    
    %  clear old temp PCA name 
    tempShapeModelFile = [ dataDirectory  'tempShapePCAParamFile.mat']; %wholeShapePCAParameters
    if exist( tempShapeModelFile, 'file')
        delete( tempShapeModelFile );
    end                
    % initialize things
    if isempty( fiducialOffset )
        fiducialOffset = [ 0; 0];
    end
    
    for j = 1:nFold
        maskFile{j} = [maskFileFolder 'CVmaskFile' int2str(index) '.' int2str(j) '.mat'];
    end

    
    showIt=0;
    doItFast = 1;  
    
    %initialize optimization parameters
    eyeCropPosition = hwParameters(1:2);
    cropSize = hwParameters(3:4);
    eyeCropPosition = eyeCropPosition(:);
    cropSize = cropSize(:);
    
    [ X2 Y2Cropped ] = cropFiducial( X,  Y, shapeCoords, cropSize, 0, [], showIt, ...
                                     eyeCropPosition );
                
    %convert from complex to vectorized, and normalize
    Y2 = [real( Y2Cropped); imag(Y2Cropped)] ;  
    
    
    [ nX Yw yMu V D Vimg V1 D1 yMu1 xMu Dimg] = normalizeDataMOG( tempShapeModelFile, ...
                    X2 , Y2,  1:size(Y2,2), doItFast, imgFeatureMode, [], ...
                    calcM, shapeVersion, mode3D, shapePercent, fiducialCoordinates); 
    [ aveDist allDist ] = calcPairwiseDistances( nX );
    sigmaInit = sqrt(aveDist/2);
    sigmaStdDev = std(sqrt(allDist/2));
                  
                
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
    
    %customized cost function
    f = @(params)customCVcost( nX, Yw, W0, M, a, tol, maxIters, kernel, params, ...
                           regressionMode, maskFile, nFold, ...
                           imgFeatureMode, shapeCoords, calcM, dataDirectory, hwParameters );
                       
    paramsTemp = [];
    
    %if not SVR,GPR use the first 6 params, else uses 7
    if regressionMode ~= 4 && regressionMode ~= 6  %(SVR or GPR) 
        x0 = [ x0(1); sigmaInit];
    else
        x0 = [ x0(1); sigmaInit; .1];
    end
        
    % Tune parameters using simplex search
    if optAlgorithm == 1 %simplex 
        %maxIters
        options = optimset('MaxIter', 25, 'Display', 'iter',   ...
                           'TolX', .01, 'TolFun', .01, ...
                           'MaxFunEvals', 50);
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
        if regressionMode == 5  || regressionMode == 8
            
    
            psoBoundary = [.01  sigmaInit-2*sigmaStdDev  ; 
                            .3   sigmaInit+2*sigmaStdDev ];
                 % change max sigma back to 8 when done
% %         elseif regressionMode == 4  % eps-SVR
% %             psoBoundary =  [.01 1 .01 ;
% %                              2  20  .3];
                         
        elseif   regressionMode == 4  || regressionMode == 6  % SVR, GPR
            psoBoundary =  [.01 sigmaInit-2*sigmaStdDev  .01 ;
                             .3  sigmaInit+2*sigmaStdDev  .3];
                         
        elseif   (regressionMode == 10) || (regressionMode == 11) %  KRRR, kernel reduced rank regression
            psoBoundary = [ sigmaInit-2*sigmaStdDev;
                            sigmaInit+2*sigmaStdDev];
        end
        
        options = psooptimset('Generations', maxIters, 'Display', 'iter', 'TolCon', ...
                                .001, 'TolFun', .001, ... % 'ConstrBoundary','absorb', ...
                                'PopInitRange', psoBoundary , ...
                                'PopulationSize', 50); % This is so I can 
                                                         % do a grid search
        
             
        if   (regressionMode == 10) || (regressionMode == 11) 
                            %  fixed params for KRRR, kernel reduced rank regression
            
            x = [rank(nX); sigmaInit];
            % x = [ 25; sigmaInit];
            
        else  % do the standard tuning
            [x ] = pso(f, length(x0),[], [], [], [], ...
                 psoBoundary(1,:), psoBoundary(2,:),[],options);  
        end
    elseif optAlgorithm == 6 %fminunc 
        %maxIters
        options = optimset('MaxIter', 25, 'Display', 'iter',   ...
                           'TolX', .01, 'TolFun', .01, ...
                           'MaxFunEvals', 50);   
        [x,fval,exitflag,output] = fminunc( f ,double(x0), options); 
        
    else  
        error( 'SR: Improper optAlgorithm specified' );
    end
    
    % cropSize = findCropSizeUltimate( shapeCoords(:) , Y, x(3:4) );

        % -----------------------------------------
    % Now do detections to calc error distribution
    % calculate error k fold
    %     Yest = cell(nFold,1);
%     lambda = x(1);
%     sigma = x(2);
%     epsSvr = .1;
%     tempMode3D = 0;
%     if regressionMode == 4 || regressionMode == 6  %(SVR or GPR) 
%          epsSvr = x( 3 );
%     end
    YtrueMinusEstTotal = [];
% %     for k = 1:nFold        
% %         load( maskFile{k} ); %load up train/test partitions
% %                 
% %         [tempError W tempk YtrueMinusEst Yest ]=  runRegressionUltimate( nX(:,trainThis),  nX(:,testThis), ...
% %             Yw(:,trainThis),  Yw(:,testThis), W0,M, a, tol, maxIters, ...
% %             kernel, [lambda; sigma; epsSvr], regressionMode, 0, []);
% %     
% %         % This is shapes as all X over all Y
% %         [ Yhat  ] = unparameterizeShape( Yest, yMu, V, D, shapeVersion, V1, D1, yMu1, tempMode3D );
% %         tempError = [ real(Y2Cropped(:, testThis)); imag(Y2Cropped(:, testThis))] ...
% %                      - Yhat;
% %         
% %         % This gives absolute error in terms of all X over all Y
% %         YtrueMinusEstTotal = [YtrueMinusEstTotal tempError]; 
% %         
% %         % detections = reshape( Yhat(1:numCoords*2,:), numCoords, [] ); 
% %         % trueCoords =  YtoSideReal( Y2Cropped(:, testThis));
% %     end
    
    
end

function error = customCVcost( nX, Yw, W0, M, a, tol, maxIters, kernel, params, ...
                            regressionMode, maskFile, nFold, imgFeatureMode, ...
                            shapeCoords, calcM, dataDirectory, hwParameters )

%     params
    
    error = 0;
    lambda = params(1);
    sigma = params(2);
    epsSvr = .1;
    if regressionMode == 4 || regressionMode == 6  %(SVR or GPR) 
         epsSvr = params( 3 );
    end
    
    % lambda/sigma stuff for doing right type of regression
    if (lambda <= 0 || (sigma <= 0 || epsSvr  <= 0 ) )
        error = 100000 + abs(lambda) + abs(sigma) + abs(epsSvr);
    else
        
        % fort iming one iteration of tuning
        %time1 = toc;
        
        % Now calculate the errors
        if regressionMode == 5 % GCV for KRR
            error = srGCV( nX, Yw, lambda, sigma );
            
        elseif regressionMode == 8 % GCV for KRR
            error = srGCVCurveKRR( nX, Yw, lambda, sigma );
                    
        else
            % standard N-fold regression
            tempErr = zeros(nFold,1);
            
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
                tempErr(k) = runRegressionUltimate( nX(:,trainThis),  nX(:,testThis), ...
                        Yw(:,trainThis),  Yw(:,testThis), W0,M, a, tol, maxIters, ...
                        kernel, [lambda; sigma; epsSvr], regressionMode, 0, []);
            end
            
            
            
            %matlabpool close     % destroying the local pool
            
            % This way gives better performance than old way
            % error = norm(tempErr, 'fro').^2;
            
            % Old way I got error
            error = sum(abs(tempErr))./nFold;  % (actually using this for paper)

        end
        
        %for timing one iteration of the optimization
       % time2 = toc - time1
%         pause(.1);
    end
end
