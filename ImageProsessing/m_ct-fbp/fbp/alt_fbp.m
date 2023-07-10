%fbp.m for faridani's code;
%Parallel-beam filtered backprojection algorithm
% for the standard lattice
% Last revision: August 29, 2001

%specify input parameters here 

p=200; %number of view angles between 0 and pi
q=64; %q=1/d, d = detector spacing
MX=128;  MY = 128; %matrix dimensions 
%roi=[-0.3  0.3 -0.3  0.3]; %roi=[xmin xmax ymin ymax]
 roi=[-1,1,-1,1];                  %region of interest where 
                   %reconstruction is computed 
circle = 1; % If circle = 1 image computed only inside 
            % circle inscribed in roi.


%Specify parameters of ellipses for mathematical phantom. 
% xe = vector of x-coordinates of centers 
% ye = vector of y-coordinates of centers 
% ae = vector of first half axes
% be = vector of second half axes
% alpha = vector of rotation angles (degrees)
% rho = vector of densities 
xe=[0 0 0.22 -0.22 0 0 0 -0.08 0 0.06 0.5538];
ye=[0 -0.0184 0 0 0.35 0.1 -0.1 -0.605 -0.605 -0.605 -0.3858];
ae=[0.69 0.6624 0.11 0.16 0.21 0.046 0.046 0.046 0.023 0.023 0.0333];
be=[0.92 0.874 0.31 0.41 0.25 0.046 0.046 0.023 0.023 0.046 0.206];
alpha=[0 0 -18 18 0 0 0 0 0 0 -18];
rho=  [1 -0.98 -0.02 -0.02 0.01 0.01 0.01 0.01 0.01 0.01 0.03];

%end of input section 
tic
b=pi*q; rps=1/b;
alpha = alpha*pi/180;

if MX > 1 
 hx = (roi(2)-roi(1))/(MX-1);
 xrange = roi(1) + hx*[0:MX-1];
else 
 hx = 0; xrange = roi(1);
end

if MY > 1 
 hy = (roi(4)-roi(3))/(MY-1);
 yrange = flipud((roi(3) + hy*[0:MY-1])');
else 
 hx = 0; yrange = roi(3);
end

center = [(roi(1)+roi(2)), (roi(3)+roi(4))]/2;
x1 = ones(MY,1)*xrange; %x-coordinate matrix
x2 = yrange*ones(1,MX); %y-coordinate matrix
if circle == 1
  re = min([roi(2)-roi(1),roi(4)-roi(3)])/2;
  chi = ((x1-center(1)).^2 + (x2-center(2)).^2 <= re^2); %char. fct of roi;
else
  chi = isfinite(x1);
end
% chi= logical(ones(16384,1));

P = zeros(MY,MX);  
PP= zeros(128,200);
h = 1/q;		
s = h*[-q:q-1];
bs = [-2*q:2*q-1]/(q*rps);
wb = slkernel(bs)/(rps^2); %compute discrete convolution kernel.

for j = 1:p    % j=1:200;
    disp(j);
    Q= zeros(MY,MX);
  phi = (pi*(j-1)/p);
  theta = [cos(phi);sin(phi)];
  RF = Rad(theta,phi,s,xe,ye,ae,be,alpha,rho); %compute line integrals
  PP(:,j)=RF';
% end

  %   convolution 
  for in=1: max(size(s))
      bb= x1*theta(1) + x2*theta(2)- s(in);
      bb= bb/ rps;
      ww= slkernel(bb)/rps^2;
      Q= Q+ ww* RF(in);
  end
     P= P +Q;
%    interpolation and backprojection 
      
end   % j-loop

pmin = min(min(P)); 
pmax = max(max(P));
alt_fbp_time= toc/60
figure,window3(0,0.2,roi,PP);
figure,window3(pmin,pmax,roi,P); title('q=32,p=200');% view the computed image
%figure,window3(-0.07,0.07,roi,P); title('q=64,p=200')
