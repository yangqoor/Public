im=zeros(256,256);

%draw the center point
radius=2;
im1=draw_circle(im,radius);

%draw the first inner circle
radius=25;
im1=draw_circle(im1,radius);

%draw the 2nd circle
radius=51;
im1=draw_circle(im1,radius);

%draw the 3rd inner circle
radius=61;
im1=draw_circle(im1,radius);

%draw the first 4th circle
radius=114;
im1=draw_circle(im1,radius);

%draw the first 5th circle
radius=124;
im1=draw_circle(im1,radius);

im1=double(im1); 
