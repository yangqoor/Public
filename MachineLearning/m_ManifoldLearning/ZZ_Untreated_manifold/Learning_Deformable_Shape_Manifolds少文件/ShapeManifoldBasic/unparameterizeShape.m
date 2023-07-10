% Samuel Rivera
% Date: May 22, 2010
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
% notes: This function should take in the shapes in matrix Y
% Y is column vectors of real shapes (dxN, N samples )
% 
% Versions are 1 :  reverse whitening. (no shift/rotation)  
%              2 : reverse whitening with a shift from centroid
 

function [ Yhat  ] = unparameterizeShape( Yest, yMu, V, D , version, V1, D1,...
                                          yMu1, mode3D, shapeCoords )
                                      
if mode3D && (version ~= 5)
    version = 5;
    warning( 'forcing shape version to be 5, since doing 3D shape detection');
end
                    
if version == 1 % standard whitening
    
    Yhat = V*diag(diag(D).^(1/2))*Yest + repmat( yMu, 1,size(Yest,2) );

elseif version == 2 % centroid shift plus whitening
    
    shift = Yest(end-1:end, : );
    Yest(end-1:end, : ) = [];
    d = size( V,1);
    Yhat = V*diag(diag(D).^(1/2))*Yest + repmat( yMu, 1,size(Yest,2) );
    Yhat = Yhat +  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];

elseif version == 3 % combined deformation - translation model
    
    % decouple shape and translation
    Yest = V*diag(diag(D).^(1/2))*Yest + repmat( yMu, 1,size(Yest,2) );
    
    % unwhiten and un-shift
    shift = Yest(end-1:end, : );
    Yest(end-1:end, : ) = [];
    d = size( V1,1);
    Yhat = V1*diag(diag(D1).^(1/2))*Yest + repmat( yMu1, 1,size(Yest,2) );
    Yhat = Yhat +  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
       
elseif (version == 7) || ((version == 4) || (version == 6))   % combined deformation translation model with scaling
    
    % decouple shape and translation
    Yest = V*diag(diag(D).^(1/2))*Yest + repmat( yMu, 1,size(Yest,2) );
    
    % cut off shift and scale from vector 
    shift = Yest(end-2:end-1, : );
    scale = Yest(end, : );
    Yest(end-2:end, : ) = []; 
    
    % unwhiten
    d = size( V1,1);
    Yhat = V1*diag(diag(D1).^(1/2))*Yest + repmat( yMu1, 1,size(Yest,2) );
    
    %scale
    Yhat = Yhat.*repmat(  scale, d,1);
    
    % shift
    Yhat = Yhat +  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
                       
elseif version == 5 % 3D combined deformation translation model with scaling
    
    % decouple shape and translation
    Yest = V*diag(diag(D).^(1/2))*Yest + repmat( yMu, 1,size(Yest,2) );  
    
    % cut off shift and scale from vector 
    shift = Yest(end-3:end-1, : );
    scale = Yest(end, : );
    Yest(end-3:end, : ) = []; 
    
    % unwhiten
    d = size( V1,1);
    Yhat = V1*diag(diag(D1).^(1/2))*Yest + repmat( yMu1, 1,size(Yest,2) );
    
    %scale
    Yhat = Yhat.*repmat(  scale, d,1);
    
    % shift
    Yhat =  Yhat +  [ repmat( shift(1,:), d/3, 1 ) ; ...
            repmat( shift(2,:), d/3, 1 ) ; ...
            repmat( shift(3,:), d/3, 1 ) ];
                
       
elseif version == 9   % combined deformation, translation, scale, rotation model
    
    % decouple shape and translation
    Yest = V*diag(diag(D).^(1/2))*Yest + repmat( yMu, 1,size(Yest,2) );
    
    % cut off shift, scale, and rotation from vector 
    shift = Yest(end-3:end-2, : );
    scale = Yest(end-1, : );
    theta = Yest(end, : );
    Yest(end-3:end, : ) = []; 
    
    % unwhiten
    d = size( V1,1);
    Yhat = V1*diag(diag(D1).^(1/2))*Yest + repmat( yMu1, 1,size(Yest,2) );
    
    % unrotate
    Ycomplex = Yhat(1:d/2,:) + 1i*Yhat( d/2+1:d,:); 
    Ycomplex = Ycomplex.*repmat( exp(-1i*theta), [d/2,1]);  % note -theta                  
    Yhat = [ real(Ycomplex); imag(Ycomplex) ];
            
    %scale
    Yhat = Yhat.*repmat(  scale, d,1);
    
    % shift
    Yhat = Yhat +  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];


elseif (version == 10)   % LS basis fit, + Translation and Scale model
    
    % decouple shape and translation
    Yest = V*diag(diag(D).^(1/2))*Yest + repmat( yMu, 1,size(Yest,2) );
    
    % cut off shift and scale from vector 
    shift = Yest(end-2:end-1, : );
    scale = Yest(end, : );
    Yest(end-2:end, : ) = []; 
    
    
    
    % unwhiten
    d = size( V1,1);
%     Yhat = V1*diag(diag(D1).^(1/2))*Yest + repmat( yMu1, 1,size(Yest,2) );
    Yhat = V1*Yest + repmat( yMu1, 1,size(Yest,2) );
    
    %scale
    Yhat = Yhat.*repmat(  scale, d,1);
    
    % shift
    Yhat = Yhat +  [ repmat( shift(1,:), d/2, 1 ) ; ...
                    repmat( shift(2,:), d/2, 1) ];
                       
  
elseif version == 11  %Combination of gaussians for subshapes (with trans + scale)
    
    shapeVersion = 4; 
%     shapeCoords = [];
    
    mode3D = 0;
    [ Yhat  ] = unparameterizeShapeCOG( Yest, yMu, V, D , shapeVersion, V1, D1,...
                                          yMu1, shapeCoords );
                                      
    %Yhat is all real over all imag
    
elseif version == 12  %MOG with translation+scale
    
    shapeVersion = 4;     
    [ Yhat  ] = unparameterizeShapeMOG( Yest, yMu, V, D , shapeVersion, V1, D1,...
                                          yMu1, shapeCoords );
                                      
    %Yhat is all real over all imag    
 
    
elseif version == 13 % The deformation learned after aligning shapes by 
                     % translation and scale, but original shapes projected
                     % there
                     
                     
    % unwhiten
    Yest = V*diag(diag(D).^(1/2))*Yest + repmat( yMu, 1,size(Yest,2) );
    
    % reverse projection    
    Yhat = V1*Yest; % + repmat( yMu1, 1,size(Yest,2) );
    
%     %scale
%     Yhat = Yhat.*repmat(  scale, d,1);
%     
%     % shift
%     Yhat = Yhat +  [ repmat( shift(1,:), d/2, 1 ) ; ...
%                     repmat( shift(2,:), d/2, 1) ];   
    
    
end