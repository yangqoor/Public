DIR = dir('train_set');
X = [];
C = [];
for i = 3:length(DIR)
    dirname = strcat('train_set/',DIR(i).name);
    AUX_DIR = dir(dirname);
    for j = 3:length(AUX_DIR)
        auxfilename = strcat(dirname,'/',AUX_DIR(j).name);
        aux = double(imread(auxfilename))/255.0;
        d = size(aux);
        X = [X ; reshape(aux,[1,numel(aux)])];
        C = [C ; i-3];
    end
end

[Y,idxNN] = isomap(X,32,3);

scatter3(Y(:,1),Y(:,2),Y(:,3),9,C);