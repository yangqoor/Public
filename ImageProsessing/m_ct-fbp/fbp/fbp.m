%fbp.m for faridani's code;
%Parallel-beam filtered backprojection algorithm
% for the standard lattice
% Last revision: August 29, 2001

%specify input parameters here 

p=200; %number of view angles between 0 and pi
q=64; %q=1/d, d = detector spacing
MX=128;  MY = 128; %matrix dimensions 
roi=[-1,1,-1,1]; %roi=[xmin xmax ymin ymax]
% roi=[-0.5,0.5,-0.5,0.5];                  %region of interest where
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
x1 = x1(chi); x2 = x2(chi);
P = zeros(MY,MX);    Pchi = P(chi);
%P= zeros(128,200);
h = 1/q;		
s = h*[-q:q-1];
% s= h*[-32:0.5:31.5];
bs = [-2*q:2*q-1]/(q*rps);

wb = slkernel(bs)/(rps^2); %compute discrete convolution kernel.

pp= 0;
for j = 1:p          % j=1:200;
  phi = (pi*(j-1)/p);
  theta = [cos(phi);sin(phi)];
  RF = Rad(theta,phi,s,xe,ye,ae,be,alpha,rho); %compute line integrals
%   P(:,j)=RF';
% end

  %   convolution 
  C = conv(RF,wb);
  Q = h*C(2*q+1:4*q); Q(2*q+1)=0; 
  

%    interpolation and backprojection 

     Q = [real(Q)';0];
     t = theta(1)*x1 + theta(2)*x2;
     k1 = floor(t/h);
     u = (t/h-k1);
    k = max(1,k1+q+1); k = min(k,2*q);
     Pupdate = ( (1-u).*Q(k)+u.*Q(k+1));
   % Pupdate = Q(k);
%     Pchi=Pchi+ Pupdate;
    Pchi= Pchi + Pupdate;

end   % j-loop

P(chi) = Pchi*(2*pi/p);
P(chi)= Pchi* (2*pi/p);

pmin = min(min(P)); 
pmax = max(max(P));
figure,window3(pmin,0.15,roi,P); title('q=64,p=200');% view the computed image
%figure,window3(-0.07,0.07,roi,P); title('q=64,p=200')
