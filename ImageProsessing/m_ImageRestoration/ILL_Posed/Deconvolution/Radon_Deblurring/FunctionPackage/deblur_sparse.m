
function I = deblur_sparse(B,A,I,stdnoise,filts,rad, a, iters)

% hyper laplacian exponent
if ~exist('a', 'var')
    a = 0.8;
end
if ~exist('iters', 'var')
    iters = 10;
end

[h w c] = size(B);

% do deblurring
I = deblur_opt(B,A,I,stdnoise,filts,rad);

global display_iterations;
% global print_iters;

if (display_iterations)
    imshow(I);
    drawnow;
end

min_err = 0.003;

%% reweighted least squares
for i=1:iters

    Ipad = padarray(I, [rad rad], 'replicate', 'both');    
    
    % compute weights
    filts = compute_filter_weights(Ipad,filts,a);    
    I = deblur_opt(B,A,I,stdnoise,filts,rad);
    
    if (display_iterations)
        figure(1);
        imshow(I);
        drawnow;
    end
    
end

I = max(min(I,1),0);
