function [X,Y]=trajectory(Ts,offtime)
% trajectory(2,660);
% ������ʵ����[X,Y]������ֱ������ϵ����ʾ��
% TsΪ�״�ɨ�����ڣ�ÿ��Ts��ȡһ���۲�����
% ����������˶�����������������90�ȵĻ���ת��

if nargin>2
    error('����ı������࣬����');
end

if offtime<600
    error('����ʱ��������600s������������');
end

x=zeros(offtime,1);
y=zeros(offtime,1);
X=zeros(ceil(offtime/Ts),1);
Y=zeros(ceil(offtime/Ts),1);

% t=0:400s���ٶ�vx,vyΪ��x��y����ٶȷ���(m/s)
x0=2000;%��ʼ������
y0=10000;
vx=0;
vy=-15; % ��-y����

for t=1:400
    x(t)=x0+vx*t;
    y(t)=y0+vy*t;
end

% t=400:600s��ax,ayΪ��x��y��ļ��ٶȷ���(m/s/s)
ax=0.075;
ay=0.075;

for t=0:200
    x(t+401)=x(400)+vx*t+ax*t*t/2;
    y(t+401)=y(400)+vy*t+ay*t*t/2;
end

vx=vx+ax*200; % ��һ�λ���ת�����ʱ���ٶ�
vy=vy+ay*200;

% t=600:610s�����˶�
for t=0:10
    x(t+601)=x(601)+vx*t;
    y(t+601)=y(601)+vy*t;
end

% t=610:660s���ڶ���ת��
ax=-0.3;
ay=0.3;

for t=0:50
    x(t+611)=x(611)+vx*t+ax*t*t/2;
    y(t+611)=y(611)+vy*t+ay*t*t/2;
end

vx=vx+ax*(660-610);% �ڶ��λ���ת�����ʱ���ٶ�
vy=vy+ay*(660-610);

% 660s�Ժ������˶���һֱ����ֹʱ��
for t=0:(offtime-660)
    x(t+661)=x(661)+vx*t;
    y(t+661)=y(661)+vy*t;
end

% �õ��״�Ĺ۲�����
for n=0:Ts:offtime
    X(n/Ts+1)=x(n+1);
    Y(n/Ts+1)=y(n+1);
end


%��ʾ��ʵ�켣
plot(X,Y,'LineWidth',2),axis([1800 4500 2000 10000]),grid on;
legend('Ŀ����ʵ����');
