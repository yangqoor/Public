% �Ƚ�������
clear,clc;
p=phantom(256);

pi=3.1415926;
rad=1*pi/180;
M=256;

% ����������Ⱦ���ͶӰ����
D=1000; %����Դ��ͼ�����ĵľ��� 
angle_spac=0.1;%�ȽǼ��Ϊ0.1
[F, fan_sensor_positions, fan_rotation_angles]=fanbeam(p,D,'FanSensorGeometry','arc','FanSensorSpacing',angle_spac);
[fan_sensors,fan_views]=size(F);% 213*360
figure,
subplot(131),imshow(F,[]);title('360��ͶӰ����');

%% Ȩ�غ���
deta=max(fan_sensor_positions);%ͶӰ������̽�����������ļн�10.6��
zdeta=-deta;
rdeta=deta*rad;%���ȱ�ʾ��deta
w=zeros(fan_sensors,fan_views);%Ȩ�غ���
 % 0��359�� for i=0:201
for i=0:fan_views-1 
    m=i+1;
    berta=i*rad;
    for j=zdeta:0.1:deta % -10.6��10.6��
        n=(j-zdeta)/0.1+1;
        n=uint8(n);
        afa=j*rad;
        temp1=2*(rdeta-afa);
        temp2=pi-2*afa;
        temp3=pi+2*afa;
        % temp3=pi+2*deta;
        a=pi/4;
        if (berta>=0) && (berta<=temp1)
            if afa~=rdeta
                th1=sin(a*berta/(rdeta-afa));
            else
                th1=sin(a*berta/(rdeta-afa+0.00001));
            end
            w(n,m)=th1*th1;
        elseif (berta>temp1) && (berta<=temp2)
            w(n,m)=1;
        elseif (berta>temp2) && (berta<=temp3)
            th2=sin(a*(pi+2*rdeta-berta)/afa);
            w(n,m)=th2*th2;
        end
    end
end
F=F.*w;
subplot(132),imshow(w,[]);title('Ȩ�غ���');
% subplot(132),imshow(F,[]);title('Ȩ�ش�����ͶӰ����');
clear temp1 temp2 temp3;
clear th1 th2;
clear a;

%% ����ͶӰ����
F_temp=zeros(fan_sensors,fan_views);
for j=1:360    
    for i=zdeta:0.1:deta
        n=(i-zdeta)/0.1+1;
        n=uint8(n);
        afa=i*rad;
        Dafa=D*cos(afa);
        F_temp(n,j)=Dafa*F(n,j);
    end
end
F=F_temp;
% subplot(224),imshow(F,[]);title('�������ͶӰ����');
clear Dafa;
clear F_temp;

%% �˲�����
N=fan_sensors-1;
d_k=1/N;
for k=-N/2:N/2
    s=k+N/2+1;
    % rs=s*rad;%���ȱ�ʾ
    rs=k/10*rad;
    sins=sin(rs);
    % t=s/sins;
    if(sins~=0)
        t=k/sins;
    else
        kk=0.01;
        sins=sin(kk/10*rad);
        t=kk/sins;
    end
    t=t*t;
    if k==0 
        h(s)=1/4/d_k/d_k;
        g(s)=h(s)*t;
    elseif mod(k,2)==1
        h(s)=-1/(pi*k*d_k)^2;% h(s)=-1/(pi*sin(k*d_k))^2
        g(s)=h(s)*t;
    else
        h(s)=0;
        g(s)=h(s)*t;
    end
end
% subplot(224),plot(h),title('�˲�����');
clear t sins rs s;

%% ���
% temp=zeros(425,360);% 213+213-1
for n=1:360
    temp(:,n)=conv(F(:,n),g,'same');% ���������м䲿��
end
% F=temp(180:392,:);
F=temp;
% figure,
% subplot(121),imshow(F,[]);title('�˲���ͶӰ����');
subplot(133),imshow(F,[]);title('�˲���ͶӰ����');
clear temp;

%% ��ͶӰ
res=zeros(M,M);% 256*256
viemax=pi+2*rdeta;
du=viemax/pi*180;
vm=floor(du);
for v=0:1:vm
    k=v+1;
    berta=v*rad;
    for i=1:M
        for j=1:M
            x=i-M/2;
            y=j-M/2;
            %ת���ɼ�����
            r=sqrt(x^2+y^2);
            if x==0 && y==0
                theta=0;
            elseif x>0
                theta=asin(y/r);
                if theta<0
                    theta=2*pi+theta;
                end
            else
                theta=pi-asin(y/r);
            end
%             bb=r*cos(berta-theta);
%             aa=r*sin(berta-theta);
            bb=r*cos(theta-berta);
            aa=r*sin(theta-berta);
            a=D+aa;
            Dp=a^2+bb^2;
            % garm=asin(bb/(sqrt(Dp)));
            garm=atan(bb/a);
            dgarm=garm/pi*180;
            if ((dgarm>=0) && (dgarm<=10.6)) || ((dgarm>=-10.6) && (dgarm<0))
                kg=(dgarm-zdeta)/0.1+1;
                g=fix(kg);
                gg=kg-g;
                res(j,i)=res(j,i)+((1-gg)*F(g,k)+gg*(F(g+1,k)))/Dp;
                % res(j,i)=res(j,i)+F(g,k);
            else
                res(j,i)=res(j,i);
            end
        end
    end
end
clear viemax du bb aa a Dp garm dgarm kg g gg;

img=res(M,M);
for i=1:M
    for j=1:M
        img(i,j)=res(M-i+1,j);
    end
end
% subplot(122),imshow(img,[]);title('�ؽ����ͼ��');

% ��ԭͼ������Ƚ�
% FigSub(img,p);

           
            