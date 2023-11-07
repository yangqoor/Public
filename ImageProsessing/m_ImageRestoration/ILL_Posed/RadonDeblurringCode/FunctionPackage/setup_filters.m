function filts = setup_filters(Isz,lambda_filter)

%% setup filters
% dx = [0 0 0; 0 1 -1; 0 0 0];
% dy = [0 0 0; 0 1 0; 0 -1 0];
% dcross1 = [0 0 0; 0 1 0; 0 0 -1];
% dcross2 = [0 0 -1; 0 1 0; 0 0 0];
% 
% dL = fspecial('laplacian');



dy23 = [0, -1, 0; 0, 0, 0; 0, 1, 0];
dx23 = [0, 0, 0; -1, 0, 1; 0, 0, 0];
dy32 = [0, 1, 0; 0, -2, 0; 0, 1, 0];
dx32 = [0, 0, 0; 1, -2, 1; 0, 0, 0];


filts = [];
filts(1).G = dx23;
filts(1).lambda = lambda_filter;
filts(2).G = dy23;
filts(2).lambda = lambda_filter;
filts(3).G = dx32;
filts(3).lambda = lambda_filter;
filts(4).G = dy32;
filts(4).lambda = lambda_filter;
% filts(3).G = dcross1;
% filts(3).lambda = lambda_filter;
% filts(4).G = dcross2;
% filts(4).lambda = lambda_filter;
% filts(5).G = dL;
% filts(5).lambda = lambda_filter;

h = Isz(1);
w = Isz(2);

for i=1:length(filts)   
    filts(i).W = sparse(1:h*w, 1:h*w, 1, h*w, h*w);  
    filts(i).G_flip = fliplr(flipud(filts(i).G));
end