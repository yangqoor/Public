clc
clear
close all
 
% 产生测试数据
[X, labels] = generate_data('helix', 2000);
figure, scatter3(X(:,1), X(:,2), X(:,3), 5, labels);
title('Original dataset'), drawnow

% 估计本质维数
no_dims = round(intrinsic_dim(X, 'MLE'));
disp(['MLE estimate of intrinsic dimensionality: ' num2str(no_dims)]);
 
% PCA降维
[mappedX, mapping] = compute_mapping(X, 'PCA', no_dims);
figure, scatter(mappedX(:,1), mappedX(:,2), 5, labels);
title('Result of PCA');
 
% % Laplacian降维
% scatter(mappedX(:,1), mappedX(:,2), 5, labels(mapping.conn_comp))  
% title('Result of Laplacian Eigenmaps')  
% drawnow  
%   
% % Isomap降维  
% [mappedX, mapping] = compute_mapping(X, 'Isomap', no_dims);  
% figure  
% scatter(mappedX(:,1), mappedX(:,2), 5, labels(mapping.conn_comp))  
% title('Result of Isomap')  
% drawnow  