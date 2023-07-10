[filename pathname]=uigetfile(...
    {'*.bmp;*.jpg;*.png;*.jpeg','Image Files(*.bmp,*.jpg,*.png,*.jpeg)';...
    '*.*','All Files (*.*)'},...
    'Pick an image');
fpath=[pathname filename];%将文件名和目录名组合成一个完整的路径
img_src=imread(fpath);
imshow(img_src);
I = rgb2gray(img_src);
I=double(I);
[Gx Gy] = gradient(I);
A = abs(Gx) + abs(Gy);
A=uint8(A);
figure;
imshow(A,[]);

D=1;
t=[0 D;-D D;-D 0;-D -D];
grayt=graycomatrix(A,'offset',t);
stats = GLCM_Features1(grayt,0);
statsmax=[max(stats.contr) max(stats.dissi) max(stats.entro) max(stats.homom) max(stats.energ) ];
contrast=statsmax(1,1)
dissi=statsmax(1,2)
entro=statsmax(1,3)
homom=statsmax(1,4)
energ=statsmax(1,5)
