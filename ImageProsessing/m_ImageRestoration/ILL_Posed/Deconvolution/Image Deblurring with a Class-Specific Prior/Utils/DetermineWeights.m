function w = DetermineWeights(b, It)
    
    opts.w = size(b,1);
    opts.h = size(b,2);
    y= reshape(b, opts.w *opts.h, 1);
    for i=1: size(It,2)
       A(:,i) = reshape(It(i).I, opts.w * opts.h, 1);
    end
    lambda = 0.01; % regularization parameter
    rel_tol = 0.01; % relative target duality gap
    [w, status]=l1_ls(A,y,lambda,rel_tol,'true');
      
end