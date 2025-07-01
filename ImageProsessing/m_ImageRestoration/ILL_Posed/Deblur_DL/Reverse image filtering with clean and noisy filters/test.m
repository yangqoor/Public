x = im2double(imread('141012.jpg'));
% x=im2double(imread('78098.jpg'));


%  filter
% H = fspecial('gaussian', [5 5],2);
H = fspecial('motion',21,11);
% H = fspecial('disk',5);
% f=@(x) imfilter(x,H,'circular'); 
f = @(x) imnoise(imfilter(x,H,'circular'),'gaussian',0,0.0001); 

y = f(x);


% General options for all the methods 
options.tau = 0.1;
options.mu = 5e-5;


disp('Running Landweber iterations');
options.maxiter = 2000;
L = Landweber(f, y, options);

disp('Running Nesterov accelerated Landweber iterations');
options.maxiter = 500;
NAL = NA_Landweber(f, y, options); 

disp('Running phase corrected Landweber iterations');
options.maxiter = 1000;
PCL = PC_Landweber(f, y, options); 


figure, imshow([x, y, L]), title('Landweber iterations');
figure, imshow([x, y, NAL]), title('Nesterov accelerated Landweber iterations');
figure, imshow([x, y, PCL]), title('Phase corrected Landweber iterations');
