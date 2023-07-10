
%Samuel Rivera
%function: runRegression
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
% 
% Notes: this function runs regression with the option to specify
% which particular type of regression to use

function [e W k YtrueMinusEst Yest] = runRegressionUltimate(  X, x, Y, y, W0, ...
                    M, a, tol, maxIters, kernel, params, regressionMode, ...
                    forceGradientDescent, modelFile)
W = [];
k = []; 
YtrueMinusEst = [];
Yest = [];

switch regressionMode
    
    case 1  % linear regression ( ols )
        ridge= 0;
        [e W k YtrueMinusEst Yest ] = gradDescMissing( X, x, Y, y, W0, M, a, tol, ...
                                                maxIters, ridge, kernel, params, ...
                                                forceGradientDescent );
                                            
    case 2  % ridge regression (regularized ols )
        ridge = 1;
        [e W k YtrueMinusEst Yest ] = gradDescMissing( X, x, Y, y, W0, M, a, tol, ...
                                                maxIters, ridge, kernel, params, ...
                                                forceGradientDescent );
    case 3 % lasso regression (sparse )
        [ e YtrueMinusEst Yest ] = lasso( X, x, Y, y, params, [] );
        
    case 4 % eps - SVR
        [e model YtrueMinusEst Yest] = runSVR(X, x, Y, y, params, modelFile ); 
        
    case 5  %Kernel Ridge regression
        % % ridge = 1;
        % % [e W k YtrueMinusEst Yest ] = gradDescMissing( X, x, Y, y, W0, M, a, tol, ...
        % %                                         maxIters, ridge, kernel, params, 0);
          
        % % % This is the way I want to do this eventually (gotta wait
        % until experiments done )
        lambda = params(1);
        sigma = params(2);
        [Yest] = KRR( X, Y, x , sigma, lambda, ''); %'' for modelFile
                                                    % don't save for now
                                                    
                                % lambda./size(X,2) is another alternative
                                
        e = norm( Yest-y, 'fro').^2; %error
        
        
    case 6 % Gaussian process regression
        [ e YtrueMinusEst Yest ] = runGPR( X, x, Y, y, params );
        
    case 7 %adaboost regression
        
        %reduce dimensionality for debugging adaboost
        % X = X(1:10:end, :);
        % x = x(1:10:end, :);

        nBins= 40;
        nWeak= min( 400, size(x,1));
        
        d = size(y,1);
        Yest = zeros( size(y));
        M = cell(d,1);
        knots = cell(d,1);
        minIndex = cell(d,1); 
        
        
        display( ['Boosting ' int2str(d) ' shape modes ... ']);
        for i1 = 1:d
            
            % Boost each model output and save, in case it crashes. 
            % Adaboost is VERY slow.
            tempModelFile = [ modelFile(1:end-4) 'Dim' int2str(i1) '.mat'];
            if ~exist( tempModelFile, 'file');
                tic
                [M{i1} knots{i1} minIndex{i1}] = adaBoostTrain( X, Y(i1,:), nBins, nWeak );
                display( [ 'Boosted ' int2str(i1) ' of ' int2str(size(y,1)) ' output dimensions.' ] );
                save ( tempModelFile, 'M', 'knots', 'minIndex' ); 
                toc
            else
                load(tempModelFile);
            end
            
        end    
        save( modelFile, 'M', 'knots', 'minIndex' ); 
        
        for i1 = 1:size(y,1);
            [ Yest(i1,:) ] = adaBoostTest( x, M{i1}, knots{i1}, minIndex{i1});
        end   
        e = norm( Yest-y, 'fro').^2;
        % save( modelFile, 'M', 'knots', 'minIndex' );
      
    case 8  %Kernel Ridge regression with Curvature penalization

        % % % This is the way I want to do this eventually (gotta wait
        % until experiments done )
        lambda = params(1);
        sigma = params(2);
        [Yest] = KRRCurvature( X, Y, x , sigma, lambda, ''); %'' for modelFile
                                                    % don't save for now
                                                    
                                % lambda./size(X,2) is another alternative
                                
        e = norm( Yest-y, 'fro').^2; %error
        
    otherwise
        error( 'Invalid regression method called in runRegressionUltimate' );
        
end
        
