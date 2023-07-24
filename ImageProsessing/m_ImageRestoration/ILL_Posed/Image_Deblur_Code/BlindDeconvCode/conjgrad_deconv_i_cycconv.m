function [x]=conjgrad_deconv_i_cycconv(y,k,we,max_it,filts,w)

if (~exist('max_it','var'))
   max_it=200;
end


if (mod(size(filts,1),2)==0)
    tfilts=zeros(1+size(filts,1),size(filts,2),size(filts,3));
    tfilts(2:end,:,:)=filts;
    filts=tfilts;
end
if (mod(size(filts,2),2)==0)
    tfilts=zeros(size(filts,1),1+size(filts,2),size(filts,3));
    tfilts(:,2:end,:)=filts;
    filts=tfilts;
end


[N1,N2]=size(y);




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
mask=ones(N1,N2);



x=y;



b=cycconv(y,k);






Ax=cycconv(cycconv(x,flp(k)), k );

N3=size(filts,3);
for j=1:N3
    Ax=Ax+we/N3*cycconv(w(:,:,j).*cycconv(x,flp(filts(:,:,j))),filts(:,:,j));
end




r = b - Ax;

for iter = 1:max_it  
    
     rho = (r(:)'*r(:));

     if ( iter > 1 ),                       % direction vector
        beta = rho / rho_1;
        p = r + beta*p;
     else 
        p = r;
     end
     
     Ap=cycconv(cycconv(p,flp(k)), k);
     
     for j=1:N3
       Ap=Ap+we/N3*cycconv(w(:,:,j).*cycconv(p,flp(filts(:,:,j))),filts(:,:,j));
     end



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



