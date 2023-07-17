% Set up example for denoising problem.

%f_temp = double(imread('Ratbert.gif'));
f_temp = double(imread('camera.gif'));
[nx,ny] = size(f_temp);
f_true = zeros(max(nx,ny),max(nx,ny));
f_true(1:nx,1:ny)=f_temp;
psf = fftshift(ifft2(ones(size(f_true))));
