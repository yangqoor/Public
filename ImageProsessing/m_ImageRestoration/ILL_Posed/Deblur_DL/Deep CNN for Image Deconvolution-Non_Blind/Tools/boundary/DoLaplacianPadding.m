function  padimg = DoLaplacianPadding(FBImg, kH, kW, ypad, xpad)


method= 'laplacian';

[imH,imW] = size(FBImg);
padimg = zeros(imH+ypad*2,imW+xpad*2);

%% For Pad B(left and right of g) and C(up and bottom of g)

% boundary condition 
ll = FBImg(:,1:kW);
rr = FBImg(:,end-kW+1:end);
uu = FBImg(1:kH,:);
dd = FBImg(end-kH+1:end,:);

%%  horizontal 
map = zeros(imH,xpad+2*kW);
valmap = zeros(imH,xpad+2*kW);

map(1:imH,1:kW) = 1;
map(1:imH,kW+xpad+1:2*kW+xpad) = 2;
interval = round(xpad/kW);
map(imH,kW+1:interval:kW+xpad) = 3;
map(1,kW+1:interval:kW+xpad) = 4;

valmap(map==1)=rr;
valmap(map==2)=ll;

% linear interpolate
numpix = sum(sum(map==3));
diff = (FBImg(imH,1)- FBImg(imH,imW))/numpix;
index = 1:numpix;
Zd = FBImg(imH,imW)+diff.*index(:);
valmap(map==3)=Zd;

numpix = sum(sum(map==4));
diff = (FBImg(1,1)- FBImg(1,imW))/numpix;
index = 1:numpix;
Zu = FBImg(1,imW)+ diff.*index(:);
valmap(map==4)=Zu;

[ycoor, xcoor] = find(map>0);
zval = valmap(map>0);

zfit = gridfit(xcoor,ycoor,zval,1:xpad+2*kW,1:imH,'regularizer',method);
padhori = zfit(:,kW+1:kW+xpad);

%% vertical 
map = zeros(ypad+2*kH,imW);
valmap = zeros(ypad+2*kH,imW);

map(1:kH,1:imW) = 1;
map(kH+ypad+1:2*kH+ypad,1:imW) = 2;
interval = round(ypad/kH);
map(kH+1:interval:kH+ypad,imW) = 3;
map(kH+1:interval:kH+ypad,1) = 4;

valmap(map==1)=dd;
valmap(map==2)=uu;

% linear interpolate
numpix = sum(sum(map==3));
diff = (FBImg(1,imW)- FBImg(imH,imW))/numpix;
index = 1:numpix;
Zr = FBImg(imH,imW)+diff.*index(:);
valmap(map==3)=Zr;

numpix = sum(sum(map==4));
diff = (FBImg(1,1)- FBImg(imH,1))/numpix;
index = 1:numpix;
Zl = FBImg(imH,1)+ diff.*index(:);
valmap(map==4)=Zl;

[ycoor, xcoor] = find(map>0);
zval = valmap(map>0);

zfit = gridfit(xcoor,ycoor,zval,1:imW,1:ypad+2*kH,'regularizer',method);
padver = zfit(kH+1:kH+ypad,:);

%% corner

map = zeros(ypad+2*kH,xpad+2*kW);
valmap = zeros(ypad+2*kH,xpad+2*kW);

map(:,1:kW) = 1;
map(:,kW+xpad+1:end) = 2;
map(1:kH,kW+1:kW+xpad) = 3;
map(kH+ypad+1:end,kW+1:kW+xpad) = 4;

valmap(map==1)=zfit(:,end-kW+1:end);
valmap(map==2)=zfit(:,1:kW);
valmap(map==3)=padhori(end-kH+1:end,:);
valmap(map==4)=padhori(1:kH,:);

[ycoor, xcoor] = find(map>0);
zval = valmap(map>0);

zfit = gridfit(xcoor,ycoor,zval,1:xpad+2*kW,1:ypad+2*kH,'regularizer',method);
padcor= zfit(kH+1:kH+ypad,kW+1:kW+xpad);


%%
padimg(1:ypad,1:xpad) = padcor;
padimg(end-ypad+1:end,1:xpad) = padcor;
padimg(1:ypad,end-xpad+1:end) = padcor;
padimg(end-ypad+1:end,end-xpad+1:end) = padcor;
padimg(ypad+1:ypad+imH,1:xpad) = padhori;
padimg(ypad+1:ypad+imH,end-xpad+1:end) = padhori;
padimg(1:ypad,xpad+1:xpad+imW) = padver;
padimg(end-ypad+1:end,xpad+1:xpad+imW) = padver;
padimg(ypad+1:ypad+imH,xpad+1:xpad+imW) = FBImg;


end