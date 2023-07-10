% Samuel Rivera
% Date: May 22, 2010
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
% May 21, 2010
% notes: This function should take in the shapes in matrix Y
% Y is column vectors of real shapes (dxN, N samples )
% so it is all x coordinates over all y coordinates.  over all z
% coordinates as well if 3D
% 
% This does various parameterizations:
%   1: regular PCA with whitening (no centering)
%   2: doformation model with a shift to center
%   3: combined deformation translation model
%   4: combined deformation/translation/scale
%  
% You can run this as a standard data normalization function with version
% 1, standard whitening/unwhitening

function [ yMu V D Yw V1 D1 yMu1 ] = parameterizeShape( Y, doItFast, parameterFile, ...
                                        trainThis, shapePercent, version, ...
                                        mode3D, shapeCoords )

Yori = Y;  % backup original landmarks for certain shape models

if mode3D && (version ~= 5)
    version = 5;
    warning( 'forcing shape version to be 5, since doing 3D shape detection');
end
 
V1 = [];
D1 = [];
yMu1  = [];
scale = [];

[ d N ] = size( Y);
 
if version == 1  % standard whitening
    
    [ d N ] = size( Y);
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D' );
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu,1)
            needLearnParams = 1;
            clear  yMu V D
        else   
            Yc = Y - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;    
        end
    end

    if needLearnParams
        %whiten output (using only training data to learn parameters)
        yMu = mean( Y( :, trainThis), 2);
        Yc = Y - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', shapePercent); % whiten and reduce
        Yw = diag(diag(D).^(-1/2))*V'*Yc; 
        
    end
%-------------------------------------------------------------------------

elseif version == 2  % shift to centroid then whiten
    [ d N ] = size( Y);
    % Note output is actually like this: Yw = [ Yw; shift];
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D' );
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu,1)
            needLearnParams = 1;
            clear  yMu V D
        else   
            shift = [ mean( Y(1:d/2,:), 1);
                      mean( Y( d/2+1:d,:),1)];
            Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                        repmat( shift(2,:), d/2, 1) ];
            Yc = Y - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;  
            Yw = [ Yw; shift];
        end
    end

    if needLearnParams
        %whiten output (using only training data to learn parameters)
        %shift to centroid
        shift = [ mean( Y(1:d/2,:), 1);
                  mean( Y( d/2+1:d,:),1)];
        Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
        yMu = mean( Y( :, trainThis), 2); % whiten
        Yc = Y - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', shapePercent); % whiten and reduce
        Yw = diag(diag(D).^(-1/2))*V'*Yc; 
        Yw = [ Yw; shift];
    end
%-------------------------------------------------------------------------

elseif version == 3 % combined deformation translation model
    [ d N ] = size( Y);
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D', 'V1', 'D1', 'yMu1');
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu1,1)
            needLearnParams = 1;
            clear  yMu V D D1 V1 yMu1
        else   
            shift = [ mean( Y(1:d/2,:), 1);
                      mean( Y( d/2+1:d,:),1)];
                  
            Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                        repmat( shift(2,:), d/2, 1) ];
                    
            Yc1 = Y - repmat( yMu1, 1, N );  
            Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1;  
            Yw1 = [ Yw1; shift];
            
            Yc = Yw1 - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;              
            
        end
    end

    if needLearnParams
        %shift to centroid then whiten output 
        
        shift = [ mean( Y(1:d/2,:), 1);
                  mean( Y( d/2+1:d,:),1)];
        Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
                
        yMu1 = mean( Y( :, trainThis), 2); % whiten
        Yc1 = Y - repmat( yMu1, 1, N );
        [V1 D1 ] = pcaSR(Yc1(:,trainThis)', shapePercent); % whiten and reduce
        Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1; 
        Yw1 = [ Yw1; shift];
        
        yMu = mean( Yw1(:, trainThis), 2); % whiten again
        Yc = Yw1 - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', min(size(Yc)) ); % whiten DON'T reduce
        Yw = diag(diag(D).^(-1/2))*V'*Yc;

    end
    
%-------------------------------------------------------------------------

elseif version == 4 % combined deformation translation scale model
    [ d N ] = size( Y);
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D', 'V1', 'D1', 'yMu1');
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu1,1)
            needLearnParams = 1;
            clear  yMu V D D1 V1 yMu1
        else   
            %  shift
            shift = [ mean( Y(1:d/2,:), 1);
                      mean( Y( d/2+1:d,:),1)];      
            Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                        repmat( shift(2,:), d/2, 1) ];
            
            % scale
            scale =  sqrt(sum(Y.^2,1));
            Y = Y./repmat(  scale, d,1);
            
            % whiten
            Yc1 = Y - repmat( yMu1, 1, N );  
            Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1;  
            Yw1 = [ Yw1; shift; scale];
            
            Yc = Yw1 - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;              
            
        end
    end

    if needLearnParams
        %shift to centroid then whiten output 
        
        % shift
        shift = [ mean( Y(1:d/2,:), 1);
                  mean( Y( d/2+1:d,:),1)];
              
              
        Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
        
        % scale
        scale =  sqrt(sum(Y.^2,1));
        Y = Y./repmat(  scale, d,1);
        
        % whiten
        yMu1 = mean( Y( :, trainThis), 2); 
        Yc1 = Y - repmat( yMu1, 1, N );
        [V1 D1 ] = pcaSR(Yc1(:,trainThis)', shapePercent); % whiten and reduce
        Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1; 
        
        % pad translation and scale
        Yw1 = [ Yw1; shift; scale];
        
        % whiten again
        yMu = mean( Yw1(:, trainThis), 2); 
        Yc = Yw1 - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', min(size(Yc)) ); %  DON'T reduce
        Yw = diag(diag(D).^(-1/2))*V'*Yc;

    end    

%--------------------------------------------------------------------------

elseif version == 5 % 3D combined deformation translation scale model
    
    [ d N ] = size( Y);
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D', 'V1', 'D1', 'yMu1');
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu1,1)
            needLearnParams = 1;
            clear  yMu V D D1 V1 yMu1
        else   
            %  shift
            shift = [ mean( Y(1:d/3,:), 1);
                  mean( Y( d/3+1:2*d/3,:),1);
                  mean( Y( 2*d/3+1:d,:),1)];     
        
            Y =  Y -  [ repmat( shift(1,:), d/3, 1 ) ; ...
                    repmat( shift(2,:), d/3, 1 ) ; ...
                    repmat( shift(3,:), d/3, 1 ) ];
            
            % scale
            scale =  sqrt(sum(Y.^2,1));
            Y = Y./repmat(  scale, d,1);
            
            % whiten
            Yc1 = Y - repmat( yMu1, 1, N );  
            Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1;  
            Yw1 = [ Yw1; shift; scale];
            
            Yc = Yw1 - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;              
            
        end
    end

    if needLearnParams
        %shift to centroid then whiten output 
        
        % shift
        shift = [ mean( Y(1:d/3,:), 1);
                  mean( Y( d/3+1:2*d/3,:),1);
                  mean( Y( 2*d/3+1:d,:),1)];
              
        Y =  Y -  [ repmat( shift(1,:), d/3, 1 ) ; ...
                    repmat( shift(2,:), d/3, 1 ) ; ...
                    repmat( shift(3,:), d/3, 1 ) ];
        
        % scale
        scale =  sqrt(sum(Y.^2,1));
        Y = Y./repmat(  scale, d,1);
        
        % whiten
        yMu1 = mean( Y( :, trainThis), 2); 
        Yc1 = Y - repmat( yMu1, 1, N );
        [V1 D1 ] = pcaSR(Yc1(:,trainThis)', shapePercent); % whiten and reduce
        Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1; 
        Yw1 = [ Yw1; shift; scale];
        
        yMu = mean( Yw1(:, trainThis), 2); % whiten again
        Yc = Yw1 - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', min(size(Yc)) ); % whiten DON'T reduce
        Yw = diag(diag(D).^(-1/2))*V'*Yc;

    end    
%-------------------------------------------------------------------------

elseif version == 6 % combined deformation translation scale - No whitening
    [ d N ] = size( Y);
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D', 'V1', 'D1', 'yMu1');
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu1,1)
            needLearnParams = 1;
            clear  yMu V D D1 V1 yMu1
        else   
            %  shift
            shift = [ mean( Y(1:d/2,:), 1);
                      mean( Y( d/2+1:d,:),1)];      
            Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                        repmat( shift(2,:), d/2, 1) ];
            
            % scale
            scale =  sqrt(sum(Y.^2,1));
            Y = Y./repmat(  scale, d,1);
            
            % whiten
            Yc1 = Y - repmat( yMu1, 1, N );  
            Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1;  
            Yw1 = [ Yw1; shift; scale];
            
            Yc = Yw1 - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;              
            
        end
    end

    if needLearnParams
        %shift to centroid then whiten output 
        
        % shift
        shift = [ mean( Y(1:d/2,:), 1);
                  mean( Y( d/2+1:d,:),1)];
        Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
        
        % scale
        scale =  sqrt(sum(Y.^2,1));
        Y = Y./repmat(  scale, d,1);
        
        % whiten
        yMu1 = mean( Y( :, trainThis), 2); 
        Yc1 = Y - repmat( yMu1, 1, N );
        [V1 D1 ] = pcaSR(Yc1(:,trainThis)', shapePercent); % whiten and reduce
        
        D1 = eye(size(D1,1)); %no whitening
        
        Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1; 
        Yw1 = [ Yw1; shift; scale];
        
        yMu = mean( Yw1(:, trainThis), 2); % whiten again
        Yc = Yw1 - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', min(size(Yc)) ); % whiten DON'T reduce
        
        D = eye(size(D,1)); %no whitening
        
        Yw = diag(diag(D).^(-1/2))*V'*Yc;

    end    

%--------------------------------------------------------------------------
elseif version == 7 % combined deformation translation scale, procrustes mean model
    [ d N ] = size( Y);
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D', 'V1', 'D1', 'yMu1');
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu1,1)
            needLearnParams = 1;
            clear  yMu V D D1 V1 yMu1
        else   
            %  shift
            shift = [ mean( Y(1:d/2,:), 1);
                      mean( Y( d/2+1:d,:),1)];      
            Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                        repmat( shift(2,:), d/2, 1) ];
            
            % scale
            scale =  sqrt(sum(Y.^2,1));
            Y = Y./repmat(  scale, d,1);
            
            % whiten
            Yc1 = Y - repmat( yMu1, 1, N );  
            Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1;  
            Yw1 = [ Yw1; shift; scale];
            
            Yc = Yw1 - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;              
            
        end
    end

    if needLearnParams
        %shift to centroid then whiten output 
        
        % shift
        shift = [ mean( Y(1:d/2,:), 1);
                  mean( Y( d/2+1:d,:),1)];
              
              
        Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
        
        % scale
        scale =  sqrt(sum(Y.^2,1));
        Y = Y./repmat(  scale, d,1);
        
        % whiten
        [yMu1 tempd] = eigs(Y( :, trainThis)*Y( :, trainThis)' ,1); %mean( Y( :, trainThis), 2); 
        Yc1 = Y - repmat( yMu1, 1, N );
        
        %need to Fix this part, pcaSR centers again...
        [V1 D1 ] = pcaSR(Yc1(:,trainThis)', shapePercent); % whiten and reduce
        Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1; 
        
        % Add shift and scale parameters
        Yw1 = [ Yw1; shift; scale];
        
        yMu = mean( Yw1(:, trainThis), 2); % whiten again
        Yc = Yw1 - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', min(size(Yc)) ); % whiten DON'T reduce
        Yw = diag(diag(D).^(-1/2))*V'*Yc;

    end 



%--------------------------------------------------------------------------
elseif version == 8 % RIK  ( not supported, and not even a good idea )
    error( 'SR: version 6 shape parameterization not supported');
    
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D' );
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu,1)
            needLearnParams = 1;
            clear  yMu V D
        else   
            Yc = Y - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;    
        end
    end

    if needLearnParams
        %[ mXR NOS vR3N ddR3N K_CR3N  Xmvn scr2d m2d mean_Xmvn sigma1] =
        %srGetShapeModel( nY2 );
        %from function definition
        %[ mXR NOS vR3N ddR3N K_CR3N  Xmvn scr2d m2d mean_Xmvn sigma1] = srGetShapeModel( X )
        % srGetShapeModel from Onur Hamsici
        %
        % mXR is the 2D shape for REGISTRATION
        % NOS = num of samples 
        % ddR3N is eigenvalues of gram matrix of shapes in RIK space
        % vR3N is the eigenvectors
        %K_CR3N is kernel matrix in the RIK kernel space

        yMu = mean( Y( :, trainThis), 2); %whiten output
        Yc = Y - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', shapePercent); % whiten and reduce
        Yw = diag(diag(D).^(-1/2))*V'*Yc; 
    end
    
%-------------------------------------------------------    
elseif version == 9
    
    % combined deformation, translation, scale, rotation model
    [ d N ] = size( Y);
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D', 'V1', 'D1', 'yMu1');
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu1,1)
            needLearnParams = 1;
            clear  yMu V D D1 V1 yMu1
        else   
            %  shift
            shift = [ mean( Y(1:d/2,:), 1);
                      mean( Y( d/2+1:d,:),1)];      
            Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                        repmat( shift(2,:), d/2, 1) ];
            
            % scale
            scale =  sqrt(sum(Y.^2,1));
            Y = Y./repmat(  scale, d,1);
            
            %-----
            % remove planar rotation
            Ycomplex = Y(1:d/2,:) + 1i*Y( d/2+1:d,:); 
            referenceShape = mean(Ycomplex(:,trainThis),2);
                    %ones(d/2,1)+1i*ones(d/2,1);  % arbitrary 
            referenceShape = referenceShape/sqrt(referenceShape'*referenceShape); %unit length normalization
        
            % calc angle to common reference shape
            theta = angle( referenceShape'*Ycomplex);

            % rotate the shapes
            Ycomplex = Ycomplex.*repmat( exp(1i*theta), [d/2,1]);  % this is how u transform
            Y = [ real(Ycomplex); imag(Ycomplex) ];
            %-----
            
            % whiten
            Yc1 = Y - repmat( yMu1, 1, N );  
            Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1;  
            Yw1 = [ Yw1; shift; scale; theta];
            
            Yc = Yw1 - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;              
            
        end
    end

    if needLearnParams
        %shift to centroid then whiten output 
        
        % shift
        shift = [ mean( Y(1:d/2,:), 1);
                  mean( Y( d/2+1:d,:),1)];         
        Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
        
        % scale
        scale =  sqrt(sum(Y.^2,1));
        Y = Y./repmat(  scale, d,1);
        
        %-----
        % remove planar rotation
        Ycomplex = Y(1:d/2,:) + 1i*Y( d/2+1:d,:); 
        referenceShape = mean(Ycomplex(:,trainThis),2);
                %ones(d/2,1)+1i*ones(d/2,1);  % arbitrary 
        referenceShape = referenceShape/sqrt(referenceShape'*referenceShape); %unit length normalization
        
        % calc angle to common reference shape
        theta = angle( referenceShape'*Ycomplex);
        
        % rotate the shapes
        Ycomplex = Ycomplex.*repmat( exp(1i*theta), [d/2,1]);  % this is how u transform
        Y = [ real(Ycomplex); imag(Ycomplex) ];
        %-----
        
        % whiten
        yMu1 = mean( Y( :, trainThis), 2); 
        Yc1 = Y - repmat( yMu1, 1, N );
        [V1 D1 ] = pcaSR(Yc1(:,trainThis)', shapePercent); % whiten and reduce
        Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1; 
        
        % pad translation and scale and planar rotation
        Yw1 = [ Yw1; shift; scale; theta];
        
        % whiten again
        yMu = mean( Yw1(:, trainThis), 2); 
        Yc = Yw1 - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', min(size(Yc)) ); %  DON'T reduce
        Yw = diag(diag(D).^(-1/2))*V'*Yc;

    end  
    
    
elseif version == 10 % combined deformation translation scale model
    [ d N ] = size( Y);
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D', 'V1', 'D1', 'yMu1');
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu1,1)
            needLearnParams = 1;
            clear  yMu V D D1 V1 yMu1
        else   
            %  shift
            shift = [ mean( Y(1:d/2,:), 1);
                      mean( Y( d/2+1:d,:),1)];      
            Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                        repmat( shift(2,:), d/2, 1) ];
            
            % scale
            scale =  sqrt(sum(Y.^2,1));
            Y = Y./repmat(  scale, d,1);
            
            % center
            Yc1 = Y - repmat( yMu1, 1, N );  
            
            
            % This is the normal projection onto bases
            % Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1;  
            
            % lease squares basis fit
            Yw1 = (V1'*V1\eye(size(V1,2)))*V1'*Yc1;  % A in my derivations
            
            
            Yw1 = [ Yw1; shift; scale];            
            Yc = Yw1 - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;              
            
        end
    end

    if needLearnParams
        %shift to centroid then whiten output 
        
        % shift
        shift = [ mean( Y(1:d/2,:), 1);
                  mean( Y( d/2+1:d,:),1)];
              
              
        Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
        
        % scale
        scale =  sqrt(sum(Y.^2,1));
        Y = Y./repmat(  scale, d,1);
        
        % center
        yMu1 = mean( Y( :, trainThis), 2); 
        Yc1 = Y - repmat( yMu1, 1, N );
        
        
        [V1 D1 ] = pcaSR(Yc1(:,trainThis)', shapePercent); % whiten and reduce
        
        % This is the normal projection onto bases
        % Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1;  

        % lease squares basis fit
        Yw1 = (V1'*V1\eye(size(V1,2)))*V1'*Yc1;  % A in my derivations
            

        % pad translation and scale
        Yw1 = [ Yw1; shift; scale];
        
        % whiten again
        yMu = mean( Yw1(:, trainThis), 2); 
        Yc = Yw1 - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', min(size(Yc)) ); %  DON'T reduce
        Yw = diag(diag(D).^(-1/2))*V'*Yc;

    end 
    
    
    
elseif version == 11  % combination of gaussians for subshapes
    shapeVersion = 4;
    [ d N ] = size( Y);
    Ycomplex = Y(1:d/2,:) + 1i*Y(d/2+1:end, :); 
    

    % this assumes Y is complex
    [ yMu V D Yw V1 D1 yMu1  ] =  paramShapeCOG( Ycomplex, doItFast, parameterFile, ...
                    trainThis, shapePercent, shapeCoords, shapeVersion );
                
                
%--------------------------------------------------------------------------

elseif version == 12  % mixture of gaussians

    numGaussians = 3;    
    shapeVersion = 4;  % coded for 4 and 10    
    
    [ yMu V D Yw V1 D1 yMu1  ] =  paramShapeMOG( Y, doItFast, parameterFile, ...
                    trainThis, shapePercent, numGaussians, shapeVersion );

%--------------------------------------------------------------------------

elseif version == 13  % deformation modes learned for normalized shapes, 
                       % but the scale and translation are not removed when
                       % projecting the data to those components
                       
    [ d N ] = size( Y);
    needLearnParams = 1;
    if doItFast && exist( parameterFile, 'file')
        load( parameterFile, 'yMu', 'V', 'D', 'V1', 'D1', 'yMu1');
        needLearnParams = 0;
        if size( Y,1) ~= size( yMu1,1)
            needLearnParams = 1;
            clear  yMu V D D1 V1 yMu1
        else   
%             %  shift
%             shift = [ mean( Y(1:d/2,:), 1);
%                       mean( Y( d/2+1:d,:),1)];      
%             Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
%                         repmat( shift(2,:), d/2, 1) ];
%             
%             % scale
%             scale =  sqrt(sum(Y.^2,1));
%             Y = Y./repmat(  scale, d,1);
            
            
%             Yc1 = Y - repmat( yMu1, 1, N );  

            % project shapes to principal modes of deformation
            Yw1 = V1'*Yori;  
            
            %Yw1 = [ Yw1; shift; scale];  % no longer
            
            % whiten
            Yc = Yw1 - repmat( yMu, 1, N );  
            Yw = diag(diag(D).^(-1/2))*V'*Yc;              
            
        end
    end

    if needLearnParams
        %shift to centroid then whiten output 
        
        % shift
        shift = [ mean( Y(1:d/2,:), 1);
                  mean( Y( d/2+1:d,:),1)];              
        Y =  Y -  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
        
        % scale
        scale =  sqrt(sum(Y.^2,1));
        Y = Y./repmat(  scale, d,1);
        
        % learn principal modes of deformation
        yMu1 = mean( Y( :, trainThis), 2); 
        Yc1 = Y - repmat( yMu1, 1, N );
        [V1 D1 ] = pcaSR(Yc1(:,trainThis)', shapePercent); % whiten and reduce               
        
        % project principal deformation modes
        %Yw1 = diag(diag(D1).^(-1/2))*V1'*Yc1;  %old way                
        Yw1 = V1'*Yori; %just project original shapes
        
        % pad translation and scale
        % no longer doing that
        %Yw1 = [ Yw1; shift; scale];
        
        % whiten 
        yMu = mean( Yw1(:, trainThis), 2); 
        Yc = Yw1 - repmat( yMu, 1, N );
        [V D ] = pcaSR(Yc(:,trainThis)', min(size(Yc)) ); %  DON'T reduce
        Yw = diag(diag(D).^(-1/2))*V'*Yc;

    end    

%--------------------------------------------------------------------------
                       

    
end


