clc;clear;close all

%% 
% mydir = 'C:\Users\LIUYANG\Desktop\data\10\';
mydir = 'C:\Users\LIUYANG\Desktop\data\11111\';
% mydir = 'D:\My_Study\MATlab\USTB\data\excellent\08.22.22\';
% mydir='D:\My_Study\MATlab\USTB\data\bad\04.21.01\';
dirs = dir([mydir,'*.dat']);
sta = 1;
en = 104;
A = zeros(1024,en-sta);
A_fft = zeros(1024,en-sta);
for i = sta:en
    if ~dirs(i-sta+1).isdir
        fid = fopen(strcat(mydir,dirs(i-sta+1).name));    %���ļ��������ļ���ʶ
        A(:,i-sta+1) = fread(fid,'int32');
        A(1,i-sta+1)=0;
        A_fft(:,i-sta+1)=abs(fft(A(:,i-sta+1),1024));
        fclose(fid);
    end
end

%%
% load('mycolor.mat')
% map=colormap(newcolorbar);
% map = colormap(parula);
%%
% figure
% res0 = grs2rgb(A_fft(2:120,:),map);
% res0 = im2uint8(res0);
% imshow(res0,[])
% 
A1 = medfilt2(A_fft,[3,3]);     %Ĭ��ֵΪ[3 3]
% figure
% res1 = grs2rgb(A1(1:120,:),map);
% res1 = im2uint8(res1);
% imshow(res1,[])  %�޷�,ֱ��ӳ��
% figure
% h = imshow(res, 'DisplayRange',[]);
%% ӳ��
B = A1(1:120,:);
min_B = min(min(B));
max_B = max(max(B));
diff_B = max_B-min_B;
k = 255/diff_B;
b = -k*min_B;
new_B = B*k+b;

% res0 = grs2rgb(new_B,map);
% res0 = im2uint8(res0);
% imshow(res0,[])
figure
imshow(new_B,[])
%% 

%% ������ʾ
n=length(new_B(1,:));
% new_B(:,1:6)=0;
% B(1:40,:)=0;
% B(110:120,:)=0;
r=(1:120);
theta=linspace(-(90+53)/180.0*pi,-(90-8)/180.0*pi,n);%��
[R,Theta]=meshgrid(r,theta);%��������
% val=sin(R+Theta);%����������ֵ��
val=new_B(1:120,:);
% for i=1:y
%     val1= find(Arr(1:120,i)>0);
%     val(val1,i)=1;
% end
val = val';
% val = val/20;
max_val = max(max(val));
[X]=R.*cos(Theta)*0.09155+3.9;
[Y]=abs(R.*sin(Theta)*0.09155)-2;
% surf(X,Y,val,'parent',handles.axes1);
% figure
% surf(X,Y,val);%������
% shading interp;%ȥ��������
% view(0,90);
% grid on;%����������
% set(gca,'YDir','reverse');
% hold on; 
% �Գ�����
ii = find(X<-0.03);
val(ii) = zeros(size(ii));
figure
% mesh(X,Y,val);
surf(X,Y,val);%������
hold on
% mesh(-X,Y,val);
surf(-X,Y,val);%������
shading interp;
view(0,90);
grid on;%������
% axes(handles.axes1);
hold on
x_min = min(min(-X));
x_max = max(max(X));
y_min = min(min(Y));
y_max = max(max(Y));

xlin = linspace(x_min,x_max,n);
ylin = linspace(y_min,y_max,n);
[X1,Y1] = meshgrid(xlin,ylin);
val_zeros = zeros(size(X1));

surf(X1,Y1,val_zeros);
shading interp;%ȥ����������
grid on;%����������
axis equal
axis([x_min x_max y_min y_max])
set(gca,'XTick',[fix(x_min):1:fix(x_max)]);
% set(gca,'YTick',[fix(y_min):1:fix(y_max)]);
set(gca,'YDir','reverse');

% %% �ָ�����
% % val2=new_B(1:120,:);
% % val2 = val2';
% % [X]=R.*cos(Theta)*0.09155+3.9;
% % [Y]=R.*sin(Theta)*0.09155;
% % figure
% % surf(X,Y,val2);%������
% % shading interp;%ȥ��������
% % view(0,90);
% % grid on;%����������
% % hold on; 
%% Otsu�ָ�

new_B = uint8(new_B);

h2=fspecial('average',3);
bw1=medfilt2(new_B,[3,3]);
% bw1=medfilt2(bw1,[3,3]);
% figure
% imshow(bw1,[]) 

bw1=imfilter(bw1,h2,'replicate');
% figure
% res2 = grs2rgb(bw1,map);
% res2 = im2uint8(res2);
% imshow(res2,[])  %�޷�,ֱ��ӳ��
% figure
% imshow(bw1);

level = graythresh(bw1);
bw2 = im2bw(bw1,level);
% figure
% imshow(bw2)


%% ��̬ѧ����
bw2 = bwareaopen(bw2,100,4);%ȥ��С���

se=strel('rectangle',[1,1]);
bw3=imdilate(bw2,se);
bw4=imerode(bw3,se);
figure
imshow(bw4)
%% ��ģ
% im_add = double(bw4);
% [m,n] = size(bw1);
% for i = 1:m
%     for j= 1:n
%         if im_add(i,j) ~= 0
%             im_add(i,j) = bw1(i,j);
%         end
%     end
% end
% % figure
% % res2 = grs2rgb(im_add,map);
% % res2 = im2uint8(res2);
% % imshow(res2,[])  %
% % figure
% % imshow(im_add,[])
% %% �߽����ķ�
% % bw5 = fliplr(bw4);
% % new_bw = [bw5 ];
% % new_bw = double([zeros(40,50);bw4;zeros(30,50)]);
% new_bw = double(bw4);
% % new_bw = double(new_bw);
% [m,n]=size(new_bw);
% new_bw_mid=zeros(m,n);
% x = zeros(1,m);
% y = zeros(1,n);
% edge1 = edge(new_bw,'sobel', 0.09);
% % figure;imshow(edge1)
% for j=1:n  %ɨ����
%     I1=new_bw(:,j);  %��ȡһ��
%     dI1 = diff(I1);  %���,�ҵ��߽��
%     edge = find(dI1~=0);
%     if length(edge)==2  
%         y(j) = fix((edge(1)+edge(2)+1)/2);
%         x(j) = j;
%         new_bw_mid(y(j),x(j)) = 1;
%     end
% end
% %��ʾ��ȡ���е�
% % figure;imshow(new_bw_mid)
% %%
% [y,x] = find(new_bw_mid==1);
% % figure
% % plot(x,y,'.')
% % set(gca,'YDir','reverse');
% % axis([0 50 0 120]);
% %%
% anglestart=53;
% angleend=8;
% dis = 3.9;
% num = length(x);
% row = 120;
% col=num;
% per=fliplr(linspace(-angleend,anglestart,num));
% per=per/180.0*pi;
% pers=sin(per);
% perc=cos(per);
% ax=[];
% ay0=[];
% ay=[];
% idnum=0;
% for j=1:col
%     for i=1:row
%         if new_bw_mid(i,j)>0
%             ax=[ax,dis-i*0.09155*sin(per(j))];%ÿ��dat�е������������x����
%             ay0=[ay0,i*0.09155*cos(per(j))];
%         end
%     end
% end
% % [B,IX]=sort(A,dim,mode)modeΪ'ascend'ʱ����Ϊ'descend'ʱ����IXԭλ������
% [ax,I] = sort(ax,2,'ascend');
% for i=1:length(ax)
%     ay(i)=ay0(I(i));
% end
% %%
% aa = find(ax<0);
% ax(aa) = [];
% ay(aa) = [];
% 
% x1 = -ax;
% x1 = fliplr(x1);
% ax = [x1 ax];
% y1 = fliplr(ay);
% ay = [y1 ay];
% 
% az = (max_val+5)*ones(size(ax));
% % figure
% % plot(ax,ay,'.')
% 
% % 
% % % scatter3(ax,-ay,az,'ro','markersize',3);
% % figure
% 
% plot3(ax,abs(ay)-2.2,az,'ro','markersize',3);
% axis([x_min x_max y_min y_max -inf inf])
% view(0,90);
% hold off
% set(gca,'YDir','reverse');
% % ha = gca;
% %% ���
% % [xData, yData] = prepareCurveData( ax, ay );
% % 
% % % Set up fittype and options.
% % ft = fittype( 'gauss5' );
% % opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% % opts.Display = 'Off';
% % opts.Lower = [-Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0];
% % opts.StartPoint = [6.08039145981684 2.31957589286774 0.369361161127406 5.7019329636103 0.300956716731237 0.494559279904221 5.13723063309755 4.62199068123422 1.07667665440659 5.09963525903425 1.43818444145061 0.452368340193551 4.62789887762286 -0.950960447515218 0.657953216305125];
% % 
% % % Fit model to data.
% % [fitresult, gof] = fit( xData, yData, ft, opts );
% % 
% % % Plot fit with data.
% % % figure( 'Name', 'untitled fit 1' );
% % % cla(handles.axes2);
% % % axes(handles.axes2);
% % % h = plot( fitresult, xData, yData,'parent',handles.axes2 );
% % figure
% % h=plot( fitresult, xData, yData );
% % xlabel( '�������/m' );
% % ylabel( '¯�ľ���/m' );
% % set(gca,'XLim',[-5 5]);
% % % set(gca,'YLim',[0 8]);
% % axis equal;
% % set(gca,'YDir','reverse');
% % grid on
% %% 
% 
% % h1 = get(ha, 'children'); % ��ȡ�������children����
% % delete(h1(1));
% % delete(h1(2));
% % delete(h1(3));
