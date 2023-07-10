[X, labels] = generate_data('helix', 2000);
	figure, scatter3(X(:,1), X(:,2), X(:,3), 5, labels); title('Original dataset'), drawnow
	no_dims = round(intrinsic_dim(X, 'MLE'));
	disp(['MLE estimate of intrinsic dimensionality: ' num2str(no_dims)]);
	mappedX = compute_mapping(X, 'Laplacian', no_dims, 7);	
	figure, scatter(mappedX(:,1), mappedX(:,2), 5, labels); 
    title('Result of dimensionality reduction'), drawnow
