% f = @(t) [3.0*cos(4.0*pi*t),3.0*sin(4.0*pi*t),12.0*pi*t];
% 
% N = 2000;
% t = linspace(0.0,1.0,N)';
% 
% eta = 0.1;
% 
% X = f(t);
% X = X + eta*randn(size(X));
% 
% figure;
% scatter3(X(:,1),X(:,2),X(:,3),5,t);
% colormap(jet);
% 
% 
% [T,B,idxNN] = ltsa(X,20,1);
% 
% figure;
% spy(B);
% 
% figure;
% scatter(t,T,5,t);
% colormap(jet);
clc;
close all;
clear;

I = double(imread('purple_stp.jpg'));

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

k = 100;
d = 2;

[T,B,idxNN] = ltsa1(X,k,d);

% mappedX = ltsa(X, d, k);
% T=mappedX;

figure;
spy(B);

figure;
scatter(T(:,1),T(:,2),5,C);

% DIR = dir('coil_100');
% X = [];
% C = [];
% w = 16;
% dirs = [];
% for i = 3:length(DIR)
%     dirname = strcat('coil_100/',DIR(i).name);
%     AUX_DIR = dir(dirname);
%     dirs = [dirs, DIR(i).name];
%     for j = 3:length(AUX_DIR)
%         auxfilename = strcat(dirname,'/',AUX_DIR(j).name);
%         aux = double(imread(auxfilename))/255.0;
%         
%         mean_aux = zeros([size(aux,1)/w,size(aux,2)/w,size(aux,3)]);
%         min_aux  = zeros([size(aux,1)/w,size(aux,2)/w,size(aux,3)]);
%         max_aux  = zeros([size(aux,1)/w,size(aux,2)/w,size(aux,3)]);
%         for k = 0:size(mean_aux,1)-1
%             for l = 0:size(mean_aux,2)-1
%                 aux3 = aux(w*k+1:w*k+w,w*l+1:w*l+w,:);
%                 mean_aux(k+1,l+1,:) = mean(mean(aux3));
%                 min_aux(k+1,l+1,:)  = min(min(aux3));
%                 max_aux(k+1,l+1,:)  = max(max(aux3));
%             end
%         end
%         %d = size(aux2);
%         X = [X ; reshape(min_aux,[1,numel(min_aux)]),reshape(mean_aux,[1,numel(mean_aux)]),reshape(max_aux,[1,numel(max_aux)]) ];
%         C = [C ; i-3];
%     end
% end
% 
% k = 200;
% d = 3;
% [T,B,idxNN] = ltsa(X,k,d);
% 
% figure;
% spy(B);
% 
% figure;
% hold on;
% grid on;
% for i = 3:length(DIR)
%     idx = (C == i-3);
%     scatter3(T(idx,1),T(idx,2),T(idx,3),7,C(idx),'filled','MarkerEdgeColor','k','DisplayName',DIR(i).name);
% end
% colormap(colorcube);
% legend(gca,'show');
% hold off;