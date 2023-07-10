%Samuel Rivera
%date: nov 13, 2008
%file: normalizeDataUltimate.m
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function [ nX Yw yMu V D Vimg V1 D1 yMu1 xMu Dimg ] = normalizeDataUltimate( parameterFile, X , Y,  ...
                                     trainThis, doItFast, imgFeatureMode, imageDimensions, ...
                                     calcM, shapeVersion, mode3D) 

% parameterFile: stores the PCAcomponents/parameters for the normalization
% X: matrix with images to read
% Y: matrix with corresponding coordinates, complex
% trainThis: vector specifying which are the training images (will be used to calculate PCA)
% doItFast: will check if parameters already stores, and use them if they exist
% imgFeatureMode = 1 for unit length pixels
%                  2 for C1 features
%                  3 for LBP ( local binary pattern)
%                  4 for Berkeley Wavelet Transform
%                  5 for unit PCA
%                  6 for Laplacian Eigenmaps
%                  7 for Pixel
%                  8 for PCA
%                  9 for center shifted unit pixel
%                 10 for Haar features
%                 11 for Gabor features (not implemented)
% 
% imageDimensions = hxw of image for reshape and getting the C1 features if
% the images are not already in vectorized format, I'll check of course

opts.disp=0;
xMu = []; 
Vimg = []; 
Dimg = [];

%------------------------
imagePercent = .99;
shapePercent = .99;      %.99 % for PR experiments, .9

%-----------------------------------------------------------------
%processing input variables X

trainThis = trainThis(:);
s = size( X );
if  size( size(X),2) == 3  % vectorize images if necessary
    X = reshape( X, size( X,1)*size(X,2), s(3) );
    imageDimensions = [s(1), s(2)];
end

N = size(X,2);

% feature selection
if imgFeatureMode == 1 %unit normalized pixel intensity
    nX =  normc(X ); 
    
elseif imgFeatureMode == 2 %C1 features
    c1file = [ 'C1File.mat' ];
    [r c lib] = calcC1( c1file, reshape( X(:,1) ,imageDimensions ));
    X2 = zeros( size(r,1), N);
    if ~exist( c1file, 'file' )
        save( c1file, 'c', 'lib' );
    end
    for i2 = 1:N
        [r c lib] = calcC1( c1file, reshape( X(:,i2) ,imageDimensions));

        X2(:,i2) = r;
    end
    nX = X2; 
    
    clear X2%cleanup
%     delete(c1file)

    X =  normc(nX ); 
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file') 

        load( parameterFile, 'xMu', 'Vimg', 'Dimg' );
        needLearnParams = 0;
        if size( X,1) ~= size( xMu,1)
            needLearnParams = 1;
            clear  xMu Vimg Dimg
        else
            nX = X - repmat( xMu, 1, N );
            nX =  diag(diag(Dimg).^(-1/2))*Vimg'*nX;
        end
    end

    if needLearnParams  % whiten and reduce
            xMu = mean(X( :, trainThis),2);
            [d N] = size(X); 
            Xc = X - repmat( xMu, 1, N ); 
            [V D ] = pcaSR(Xc(:,trainThis)', imagePercent);
            Dimg = D;
            Vimg = V;
            nX = diag(diag(Dimg).^(-1/2))*Vimg'*Xc;     
            % display( ['num PCA image modes is ' int2str(size(V,2)) ' out of ' ...
            %     int2str( min(size(Xc))) ]);
    end
    
% %     % If unit length PCA
% %     if imgFeatureMode ==5
% %     unit length, makes it nice for tuning
    
    nX = normc(nX);
    
    
    
% %     end
    
elseif imgFeatureMode == 3 %LBP
    %LBP code image using sampling points in SP, no mapping
    SP=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
    temp = lbp( reshape( X(:,1),imageDimensions ),SP, 0,'i'); 
    X2 = zeros( size(temp(:),1), N);
    for i2 = 1:N
        temp = lbp( reshape( X(:,i2), imageDimensions ),SP,0,'i');
        X2(:,i2) = temp(:);     
    end
    nX = normc(X2);
    clear X2 temp
    
elseif  imgFeatureMode == 4 %BWT, berkeley wavelet transform
                            %make sure image square
                            % and length a power of 3
    n = max( 3, round( log( min( imageDimensions  ) )/log( 3) ) );                    
    tempImg = imresize( reshape( X(:,1),imageDimensions ), ...
                                     [3^n 3^n ] );
    temp = bwt( tempImg ); 
    X2 = zeros( size(temp(:),1), N);
    for i2 = 1:N
        tempImg = imresize( reshape( X(:,i2),imageDimensions ), ...
                                     [3^n 3^n ] );
        temp = bwt( tempImg );
        X2(:,i2) = temp(:);     
    end
    nX = X2;  
    
elseif  ( imgFeatureMode ==5 ) ||  ( imgFeatureMode ==8 )   % 5 whiten unit length,
                                                            % 8 no unit length 
    X =  normc(X ); 
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file') 

        load( parameterFile, 'xMu', 'Vimg', 'Dimg' );
        needLearnParams = 0;
        if size( X,1) ~= size( xMu,1)
            needLearnParams = 1;
            clear  xMu Vimg Dimg
        else
            nX = X - repmat( xMu, 1, N );
            nX =  diag(diag(Dimg).^(-1/2))*Vimg'*nX;
        end
    end

    if needLearnParams  % whiten and reduce
            xMu = mean(X( :, trainThis),2);
            [d N] = size(X); 
            Xc = X - repmat( xMu, 1, N ); 
            [V D ] = pcaSR(Xc(:,trainThis)', imagePercent);
            Dimg = D;
            Vimg = V;
            nX = diag(diag(Dimg).^(-1/2))*Vimg'*Xc;     
            % display( ['num PCA image modes is ' int2str(size(V,2)) ' out of ' ...
            %     int2str( min(size(Xc))) ]);
    end
    
    % If unit length PCA
    if imgFeatureMode ==5
        nX = normc(nX);
    end
    
elseif imgFeatureMode == 6 %Laplacian Eigenmaps
    kNN= 5;
    nDim = 10;
    sigForEmb = 2.5;
    % (rows correspond to observations, columns to dimensions)
    [nX, mapping] = compute_mapping(X', 'Laplacian', nDim, kNN, sigForEmb);  
     nX = nX';
    % visualizeEmbeddedImages( nX(1:3,:),  [] ); %'embeddingMovie.avi'
    % pause;

elseif imgFeatureMode == 7 % Pixel intensity
    nX =  X;  
    clear X
    
% note that imgFeatureMode == 8 is PCA    
 
elseif imgFeatureMode == 9 % shifted to center, unit length pixel
    nX =  X -  repmat( mean( X,1 ), size(X,1), 1 );
    nX =  normc( nX );
        
elseif imgFeatureMode == 10 % Haar features
    haarScale = 2;
    desiredNumHaar = 10000;
    nX = calcHaarFeatures( reshape(X,s), haarScale, desiredNumHaar, []);
    nX = normc( nX);
    
elseif imgFeatureMode == 11 % Gabor filter bank
    gaborScale = 2;
    desiredNumGabor = 5000;
    nX = calcGaborFeatures( I, gaborScale, desiredNumGabor);
    
else
    error( 'SR: inappropriate image Feature mode '); 
end


%------------------------------------------------------------------
% standardize shapes using  PCA-like model

    %parameterize shape
    [ yMu V D Yw V1 D1 yMu1  ] = parameterizeShape( Y, doItFast, parameterFile, ...
                                        trainThis, shapePercent, shapeVersion, mode3D );
    % display( ['num PCA shape modes is ' int2str(size(V,2)) ' out of ' ...
    %                 int2str( min(size(Y))) ]);
     
% end

% Save parameters
if ~isempty(parameterFile)
    save(  parameterFile,  'yMu', 'V', 'D', 'xMu', 'Vimg', 'Dimg', 'V1', 'D1', 'yMu1', 'imageDimensions', '-v7.3' );
    if imgFeatureMode == 2
        save(  parameterFile, 'yMu', 'V', 'D', 'xMu', 'Vimg', 'Dimg', 'V1', 'D1', 'yMu1', 'imageDimensions', 'c', 'lib', '-v7.3'  );
    end                         
end


