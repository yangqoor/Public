clc;
close all;
clear;
I = double(imread('Image.jpg'));
% I = double(imread('color_lb_src.jpg'));

w = 10;
max_I  = zeros(size(I,1)/w,size(I,2)/w,size(I,3));
min_I  = zeros(size(I,1)/w,size(I,2)/w,size(I,3));
mean_I = zeros(size(I,1)/w,size(I,2)/w,size(I,3));
sig_I  = zeros(size(I,1)/w,size(I,2)/w,size(I,3));
for i = 0:size(max_I,1)-1
    for j = 0:size(max_I,2)-1
        aux = I(w*i+1:w*i+w,w*j+1:w*j+w,:);
        max_I (i+1,j+1,:) = max (max (aux));
        min_I (i+1,j+1,:) = min (min (aux));
        mean_I(i+1,j+1,:) = mean(mean(aux));
        sig_I (i+1,j+1,:) = sqrt(mean(mean(power(aux-repmat(mean_I(i+1,j+1,:),[w,w,1]),2))));
    end
end

X = [];
C = [];
for i = 1:size(max_I,1)
    for j = 1:size(max_I,2)
        aux = reshape([max_I(i,j,:),min_I(i,j,:),mean_I(i,j,:),sig_I(i,j,:)],[1,12]);
        X = [X;aux];
        C = [C;reshape(mean_I(i,j,:)/255.0,[1,3])];
    end
end

k = 25;
d = 3;

[Y,idxNN] = lle(X,k,d);

G = sparse(size(X,1));
for i = 1:size(X,1)
    G(i,idxNN(i,:)) = 1;
    G(idxNN(i,:),i) = 1;
end

figure;
spy(G);

% n=length(Y);
% c=1:n;

figure;
scatter3(Y(:,1),Y(:,2),Y(:,3),12,C);