%Samuel Rivera
%date: jan 20, 2009
%file: runSVR.m
%
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)

function [e model YtrueMinusEst Yest] = runSVR(X, x, Y, y, params, modelFile ) 
 
C = params(1);
sigma = params(2);
epsParam = params( 3);
[d N ] = size( y );

f = zeros( d, N);


% % % %directory stuff
% % % currentDirectory = pwd;
% % % if strcmp( currentDirectory(1:6), '/media' )
% % %     cd /media/Data/matlab/libsvm-mat-3.0-1
% % % elseif strcmp( currentDirectory(1:7), '/nfs/04' )    
% % %     cd ~/matlab/libsvm-mat-3.0-1
% % % else
% % %     %display( 'running on my mac' );
% % %     cd ~/Documents/MATLAB/libsvm-mat-3.0-1
% % % end

model = cell( d, 1);

% If pre-stored SVR model
if exist( modelFile, 'file' )
    load( modelFile, 'model');
    display( 'loaded up pre-stored SVM model');  
    for i1 = 1: size(Y,1)
        libsvm_options = ''; %-c 1 -t 2 -g 1 -b 0 -p .2';
        [fTemp ] = svmpredict(y(i1,:)', x', model{i1} , libsvm_options);
            %, accuracy, decision_values
        f(i1,:) = fTemp';
    end
    
else % Train and test model
    for i1 = 1:d
        
        libsvm_options = [ '-s 3 -c ' num2str(C) ' -t 2 -g ' num2str(1./sigma) ' -b 0 -p ' num2str(epsParam) ];
                                        % notice that the 1./sqrt(sigma).
                                        % This is because the libsvm
                                        % parameters g = 1/sigma^2
        model{i1} = svmtrain( Y(i1,:)', X' , libsvm_options );

        libsvm_options = ''; 
        
        [fTemp] = svmpredict(y(i1,:)', x', model{i1} , libsvm_options);

        
        f(i1,:) = fTemp';
    end
    
% % %     % does not save during cross validation tuning portion
% % % %     if ~isempty( modelFile )
% % % %         This isn't working, don't know why
% % % %         save(  modelFile, 'model');
% % % %     end
end

% % % eval( ['cd ' currentDirectory ]);

Yest = f ; 

YtrueMinusEst = y - Yest;
e = ( mean(  YtrueMinusEst(:).^2 ,1));

