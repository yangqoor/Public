    patchSize = 8;
    % load GMM model

    load('./epll/GSModel_8x8_200_2M_noDC_zeromean.mat');
    
    % initialize prior function handle
    excludeList = [];
    prior = @(Z,patchSize,noiseSD,imsize) aprxMAPGMM(Z,patchSize,noiseSD,imsize,GS,excludeList);
    % comment this line if you want the total cost calculated
    LogLFunc = [];