clear all;
close all;
%%�����������ݷ���
[filename,pathname]=uigetfile('1x.txt','choose a data file');
fid=fopen([pathname,filename],'r');
[RowData,len]=fscanf(fid,'%f',[1 inf]);
figure;
plot(RowData);
Y = RowData;
%%��ռ��ع�
d =100;
ind = 1 : d ;
lag = 1;
lengen = length(RowData) ;
nrecord = fix((lengen - d + lag)/lag);
for i = 1 : nrecord 
    X(i,:) = RowData(ind);
    ind = ind + lag;
end
%%����ѧϰ �������
f = isomap(X,3,30);  %f = isomap(X,3,30);  %<-ԭʼ
% neigbor = neigborselect(Y,M,conn,2);
% mappedX = somltsa(X,2,neigbor);

% [mappedX,M,conn] = somforneibor(X,5,2); 
% neigbor = neigborselect(Y,M,conn,2);
% mappedX = somltsa(X,2,neigbor);
% f = mappedX;
figure(4);
scatter3(f(:,1),f(:,2),f(:,3),3);
figure(1);
plot(f(:,1),f(:,2));title('3ά������-1');
%%�ع�ԭʼʱ������
figure(2);
plot(f(:,1),f(:,3));title('3ά������-2');
figure(3);
plot(f(:,2),f(:,3));title('3ά������-3');




