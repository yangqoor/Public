f=1000;
n=1024;
w=50;
t=0:1/f:n*1/f;
y=sin(2*pi*w*t);
plot(t,y)

RowData=y;
Y = RowData;
%%相空间重构
d =100;
ind = 1 : d ;
lag = 1;
lengen = length(RowData) ;
nrecord = fix((lengen - d + lag)/lag);
for i = 1 : nrecord 
    X(i,:) = RowData(ind);
    ind = ind + lag;
end
%%流形学习 参数勿改
f = isomap(X,3,30);  %f = isomap(X,3,30);  %<-原始
% neigbor = neigborselect(Y,M,conn,2);
% mappedX = somltsa(X,2,neigbor);

% [mappedX,M,conn] = somforneibor(X,5,2); 
% neigbor = neigborselect(Y,M,conn,2);
% mappedX = somltsa(X,2,neigbor);
% f = mappedX;

figure(1);
plot(f(:,1),f(:,2));title('3维主流形-1');
%%重构原始时间序列
figure(2);
plot(f(:,1),f(:,3));title('3维主流形-2');
figure(3);
plot(f(:,2),f(:,3));title('3维主流形-3');
figure(4);
scatter3(f(:,1),f(:,2),f(:,3),3);