%Samuel Rivera
%uses simplex
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, Di You and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function [ x  ] = subTuneLambdaSigmaEtc(  maskFileFolder, ...
                        nFold, X, Y, W0, M,...
                        a, tol, maxIters, kernel, x0, regressionMode, ...
                        imgFeatureMode, index, shapeCoords, calcM, optAlgorithm, ...
                        fiducialOffset, eyeDist, maxHW, dataDirectory, ...
                        hwParameters, shapeVersion, mode3D)
                    
    %  clear old temp PCA name 
    tempShapeModelFile = [ dataDirectory 'tempShapePCAParamFile.mat'];
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
    
    [ X2 Y2 ] = cropFiducial( X,  Y, shapeCoords, cropSize, 0, [], showIt, ...
                            eyeCropPosition );
                
    %convert from complex to vectorized, and normalize
    Y2 = [real( Y2); imag(Y2)] ;  
    
    
    [ nX Yw] = normalizeDataUltimate( tempShapeModelFile, ...
                    X2 , Y2,  1:size(Y2,2), doItFast, imgFeatureMode, [], ...
                    calcM, shapeVersion, mode3D); 

    %customized cost function
    f = @(params)customCVcost( nX, Yw, W0, M, a, tol, maxIters, kernel, params, ...
                           regressionMode, maskFile, nFold, ...
                           imgFeatureMode, shapeCoords, calcM, dataDirectory, hwParameters );
                       
    paramsTemp = [];
    
    %if not SVR,GPR use the first 6 params, else uses 7
    if regressionMode ~= 4 && regressionMode ~= 6  %(SVR or GPR) 
        x0 = x0(1:2);
    else
        x0 = [ x0(1:2); 1];
    end
        
    if optAlgorithm == 1 %simplex 
        options = optimset('MaxIter', maxIters, 'Display', 'iter', 'TolX', .01, 'TolFun', .001);
        % options.zero_term_delta = .2; 
        options.usual_delta = [.2; .2; .2; .2; 1; 1];
        [x,fval,exitflag,output] = fminsearchOS( f ,x0, options);    
        
    elseif optAlgorithm == 2 % R algorithm
        prob = ooAssign( f, x0 ); % ...
        paramsTemp = ooRun(prob, 'ralg');
        x = paramsTemp.xf;  
        
    elseif optAlgorithm == 3  %simulated annealing
        prob = ooAssign( f, x0 ); % ...
        paramsTemp = ooRun(prob, 'anneal');
        x = paramsTemp.xf; 
        
    elseif optAlgorithm == 5 %particle swarm
        if regressionMode == 5
            psoBoundary = [.1  .5  ; 
                            3  8 ];
                 % change max sigma back to 8 when done
        else
            psoBoundary =  [.1 .5 .01 ;
                             3  8  3];
        end
        options = psooptimset('Generations', maxIters, 'Display', 'iter', 'TolCon', ...
                                .001, 'TolFun', .001, ...
                                'PopInitRange', psoBoundary ); %{[0;1]}]
                                %, 'SocialAttraction', 2.5, ...
                                %'CognitiveAttraction',  2.5);
       
        if regressionMode == 4 || regressionMode == 6  %(SVR or GPR) 
            [x,fval,exitflag,output,population,scores] = ...
                        pso(f, length(x0), [], [], [], [], ...
                            psoBoundary(1,:), psoBoundary(2,:),[],options);                 
        else
            
            [x,fval,exitflag,output,population,scores] = ...
                        pso(f, length(x0),[], [], [], [], ...
                         psoBoundary(1,:), psoBoundary(2,:),[],options);  
        end
        fval
        
    else
        error( 'SR: Improper optAlgorithm specified' );
    end
    
    % cropSize = findCropSizeUltimate( shapeCoords(:) , Y, x(3:4) );

end

function x = customCVcost( nX, Yw, W0, M, a, tol, maxIters, kernel, params, ...
                            regressionMode, maskFile, nFold, imgFeatureMode, ...
                            shapeCoords, calcM, dataDirectory, hwParameters )

    x = 0;
    lambda = params(1);
    sigma = params(2);
    epsSvr = 1;
    if regressionMode == 4 || regressionMode == 6  %(SVR or GPR) 
         epsSvr = params( 3 );
    end
    
    % lambda/sigma stuff for doing right type of regression
    if (lambda <= 0 || sigma <= 0 )
        x = 10 + abs(lambda) + abs(sigma);
    else
        
        if regressionMode == 5 % GCV for KRR
            x = srGCV( nX, Yw, lambda, sigma );
            
        else
            % standard N-fold regression
            for k = 1:nFold
                load( maskFile{k} ); %load up train/test partitions
                
                x = x + runRegressionUltimate( nX(:,trainThis),  nX(:,testThis), ...
                        Yw(:,trainThis),  Yw(:,testThis), W0,M, a, tol, maxIters, ...
                        kernel, [lambda; sigma; epsSvr], regressionMode, 0, []);
            end
            x = x./nFold;

        end
    end
end
