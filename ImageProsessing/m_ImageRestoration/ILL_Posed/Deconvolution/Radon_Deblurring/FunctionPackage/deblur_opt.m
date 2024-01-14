function img = deblur_opt(blur,A,x,stdnoise,filts,rad)

% see if we have a matrix for spatially varying deblurring or just a kernel
if (issparse(A))
    use_matrix = 1;
else
    use_matrix = 0;
    kernel = A;
    kernel_flip = flipud(fliplr(kernel));
end
    
% display stuff
global g_fig_iter;
global display_iterations;
global print_iters;

if (isempty(display_iterations))
    display_iterations = 0;
end

if (isempty(print_iters))
    print_iters = 0;
end

[h w c] = size(x);

maxiters = 25;

% masking and padding to handle boundry artifacts
mask = zeros(h+2*rad,w+2*rad,c);
mask(1+rad:h+rad,1+rad:w+rad,:) = 1;

blur = padarray(blur, [rad rad], 0, 'both');
x = padarray(x, [rad rad], 'replicate', 'both');

% scale by noise
blur = ((1./stdnoise.^2).*blur);

% compute A'b
if (use_matrix)
    b = reshape(blur,size(blur,1)*size(blur,2),size(blur,3));
    b = A'*b;
else
    b = imconv(blur.*mask,kernel_flip,'same');
end

b = b(:);

% conjugate gradient
x = minres(@compute_Ax,b(:),1e-4,maxiters,[],[],x(:),A,stdnoise,filts,mask);

x = reshape(x,size(mask));
x = x(1+rad:h+rad,1+rad:w+rad,:);

img = x;
img = max(min(img,1),0);

function Ax = compute_Ax(x,A,stdnoise,filts,mask)

if (issparse(A))
    use_matrix = 1;
else
    use_matrix = 0;
    kernel = A;
    kernel_flip = flipud(fliplr(kernel));
end

x_img = reshape(x,size(mask));

fprintf('.');

% compute A'Ax
if (use_matrix)
    Ax = reshape(x_img,size(x_img,1)*size(x_img,2),size(x_img,3));
    Ax = A*Ax;
    Ax = Ax(:);
    
    Ax = (1./stdnoise.^2).*(Ax).*mask(:);
    Ax = reshape(Ax,size(x_img,1)*size(x_img,2),size(x_img,3));
    Ax = (A'*Ax);    
else
    Ax = (1./stdnoise.^2).*imconv(x_img,kernel,'same').*mask;
    Ax = imconv(Ax,kernel_flip,'same');
end

Ax = Ax(:);

% filter responces
Afilter = filter_responces_for_cg(x_img,filts);

Ax = Ax + Afilter(:);