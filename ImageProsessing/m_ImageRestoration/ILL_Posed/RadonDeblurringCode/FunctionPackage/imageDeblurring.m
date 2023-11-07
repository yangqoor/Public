function D = imageDeblurring(B, KD, stdnoiseB)

%% setup gradient filters for deblurring
lambda = 2;%8;% 
rad = floor(size(KD,1)/2);
filts = setup_filters(size(B)+2*rad,lambda);

global display_iterations;
display_iterations = 1;

%% deblur 
D = deblur_sparse(B,KD,B,stdnoiseB,filts,rad);
