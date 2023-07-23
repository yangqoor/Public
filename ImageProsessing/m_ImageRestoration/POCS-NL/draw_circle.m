function im1=draw_circle(im,radius,center)
if nargin>=2
    width=1;
elseif nargin<2
    error('not have enough parameter');
end


    
[m,n]=size(im);
im1=zeros(m,n);

%center of image
if nargin<3;
    cx=round(m/2); cy=round(n/2);
else
    cx=center(1);cy=center(2);
end

%cordinate of x,y
corx=1:m; cory=1:n;

%meshgrid of (x,y)
[CorX,CorY]=meshgrid(corx,cory);

%compute distance
dist1=sqrt((CorX-cx).^2+(CorY-cy).^2);

%mark point to be drawn
outer_circle=(dist1>=radius);
if radius<=3
    inner_circle=ones(m,n);
else
    inner_circle=(dist1>=(radius-width));
end

%draw circle;
temp=double(inner_circle)-double(outer_circle);

im1=temp|im;











