function [x]=conjgrad_deconv_g_smp_wy(y,gaussmp,k,we,max_it,weight_i)

if (~exist('max_it','var'))
   max_it=200;
end

[N1,N2,t]=size(gaussmp);


[fs_y,fs_x]=size(k);

hfs1_x1=floor((size(k,2)-1)/2);
hfs1_x2=ceil((size(k,2)-1)/2);
hfs1_y1=floor((size(k,1)-1)/2);
hfs1_y2=ceil((size(k,1)-1)/2);
shifts1=[-hfs1_x1  hfs1_x2  -hfs1_y1  hfs1_y2];

hfs_x1=hfs1_x1;
hfs_x2=hfs1_x2;
hfs_y1=hfs1_y1;
hfs_y2=hfs1_y2;



N=N2*N1;
mask=zeros(N1,N2);
mask(hfs_y1+1:N1-hfs_y2,hfs_x1+1:N2-hfs_x2)=1;
%by=zeros(N,N2);
%by(hfs_y1+1:N1-hfs_y2,hfs_x1+1:N2-hfs_x2)=y;
by=y([ones(1,hfs_y1),1:end,end*ones(1,hfs_y2)],[ones(1,hfs_x1),1:end,end*ones(1,hfs_x2)]);
if (~exist('weight_i','var'))
  weight_i=ones(N1,N2);
end

x=by;

b=conv2((we^0.5*gaussmp(:,:,1)+by).*mask,k,'same')+we*weight_i.^0.5.*gaussmp(:,:,2);

%pad k with zeros up to a nearby integer with small prime factors, for fast fft
N1p=goodfactor(N1+hfs1_y1+hfs1_y2);
N2p=goodfactor(N2+hfs1_x1+hfs1_x2);
K=zero_pad2(k,ceil((N1p-fs_y)/2),floor((N1p-fs_y)/2),ceil((N2p-fs_x)/2),floor((N2p-fs_x)/2));
K=fft2(ifftshift(K));




if (max(size(k)<=5))
  Ax=conv2(conv2(x,flp(k),'same').*mask,  k,'same');
else
  Ax=fftconvf(fftconvf(x,flp(k),conj(K),'same').*mask,k,K,'same');
end


Ax=Ax+we*weight_i.*x;



r = b - Ax;

for iter = 1:max_it  
     rho = (r(:)'*r(:));

     if ( iter > 1 ),                       % direction vector
        beta = rho / rho_1;
        p = r + beta*p;
     else 
        p = r;
     end
     if (max(size(k)<=5))
       Ap=conv2(conv2(p,flp(k),'same').*mask,  k,'same');
     else  
       Ap=fftconvf(fftconvf(p,flp(k),conj(K),'same').*mask,k,K,'same');
     end
     Ap=Ap+we*weight_i.*p;
     

     q = Ap;
     alpha = rho / (p(:)'*q(:) );
     x = x + alpha * p;                    % update approximation vector

     r = r - alpha*q;                      % compute residual

     rho_1 = rho;

     if (rho<0.1^11)
         %iter
       %'convarged'
       break
     end

end



%iter