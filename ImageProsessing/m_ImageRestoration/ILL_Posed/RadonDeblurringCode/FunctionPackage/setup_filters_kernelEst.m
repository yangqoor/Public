function filts = setup_filters_kernelEst(Isz,lambda_filter)

%% setup filters
% dx = [0 0 0; 0 1 -1; 0 0 0];
% dy = [0 0 0; 0 1 0; 0 -1 0];
% dcross1 = [0 0 0; 0 1 0; 0 0 -1];
% dcross2 = [0 0 -1; 0 1 0; 0 0 0];

if(length(lambda_filter) == 1)
    lambda_filter = repmat(lambda_filter, [4, 1]);
end

dx = 1;%[0 0 0; 0 1 -1; 0 0 0];
dy = 1;%[0 0 0; 0 1 0; 0 -1 0];
dcross1 = [0 0 0; 0 1 -1; 0 0 0];%1;%[0 0 0; 0 1 0; 0 0 -1];
dcross2 = [0 0 0; 0 1 0; 0 -1 0];%1;%


filts = [];
filts(1).G = dx;
filts(1).lambda = lambda_filter(1);
filts(2).G = dy;
filts(2).lambda = lambda_filter(2);
filts(3).G = dcross1;
filts(3).lambda = lambda_filter(3);
filts(4).G = dcross2;
filts(4).lambda = lambda_filter(4);
%filts(5).G = dL;
%filts(5).lambda = lambda_filter;

h = Isz(1);
w = Isz(2);

for i=1:length(filts)   
    filts(i).W = ones(h, w);
end