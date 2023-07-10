c = 1;
d = 2*c*(3*sqrt(2)+2)/7;
m = d*(3*sqrt(2)-4)/4;
l = m+d*(2-sqrt(2))/4; 
t = d*(2-sqrt(2))/4;
V = [c-l -t c; t -c+l c; -t -c+l c; -c+l -t c; -c+l t c; -t c-l c; t c-l c; c-l t c; c t c-l;...
    c -t c-l; c -c+l t; c -c+l -t; c -t -c+l; c t -c+l; c c-l -t; c c-l t; c-l c t; c-l c -t;...
    t c -c+l; -t c -c+l; -t c-l -c; t c-l -c; c-l t -c; -c+l t -c; -c+l c -t; -c c-l -t; -c t -c+l;...
    -c -t -c+l; -c+l -t -c; -t c c-l; t c c-l; -c+l c t; -c c-l t; -c t c-l; -c -t c-l; -c -c+l t;...
    -c+l -c t; -c+l -c -t; -c -c+l -t; -t -c -c+l; -t -c+l -c; t -c+l -c; t -c -c+l; c-l -c -t;...
    c-l -t -c; t -c c-l; -t -c c-l; c-l -c t];
F8 = [1 2 3 4 5 6 7 8; 17 18 19 20 25 32 30 31; 22 23 45 42 41 29 24 21;...
    37 38 40 43 44 48 46 47; 9 10 11 12 13 14 15 16; 26 27 28 39 36 35 34 33];
F6 = [5 6 30 32 33 34; 3 4 35 36 37 47; 1 2 46 48 11 10; 7 8 9 16 17 31; 20 25 26 27 24 21;...
    28 39 38 40 41 29; 14 23 22 19 18 15; 12 13 45 42 43 44];
F4 = [6 7 31 30; 1 10 9 8; 2 3 47 46; 4 5 34 35; 32 25 26 33; 36 37 38 39;...
    11 12 44 48; 15 16 17 18; 19 20 21 22; 27 24 29 28; 40 41 42 43; 13 14 23 45];
hold on;axis equal;grid on
axis([-1.5,1.5,-1.5,1.5,-1.5,1.5])
view(3);
patch('Vertices', V, 'Faces', F4, 'FaceColor', [0 .8 .9]);
patch('Vertices', V, 'Faces', F6, 'FaceColor', [0 .5 .9]);
patch('Vertices', V, 'Faces', F8, 'FaceColor', [0 .5 .5]);

% axProjection3D('XYZ') 
% axProjection3D('XZ') 

axProjection3D('X') 
axProjection3D('Y',[.7,0,0]) 
axProjection3D('Z',[0,0,.7]) 








