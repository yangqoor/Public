function [XER,YER]=filter_result(Ts,mon,d)
% [XER,YER]=filter_result(2,50,100);
% filter_result         �Թ۲����ݽ��п������˲����õ�Ԥ��ĺ����Լ��������ľ�ֵ�ͱ�׼��
% Ts                    ����ʱ�䣬���״�Ĺ�������
% mon                   ����Monte-Carlo����Ĵ���
% d                     ���������,��λm
%����ֵ�����˲�Ԥ���Ĺ��ƺ���,�Լ���ֵ�����Э����

if nargin>3
    error('Too many input arguments.');
end

offtime=800;

% �������۵ĺ���
[x,y]=trajectory(Ts,offtime);
Pv=d*d;
N=ceil(offtime/Ts);

randn('state',sum(100*clock)); % ���������������
for i=1:N
   vx(i)=d*randn(1); % �۲����������߶���
   vy(i)=d*randn(1);
   zx(i)=x(i)+vx(i); % ʵ�ʹ۲�ֵ
   zy(i)=y(i)+vy(i);
end

% �����۲�����
for n=1:mon
    % �ÿ������˲��õ����Ƶĺ���
    XE=Kalman_filter(Ts,offtime,d,0); 
    YE=Kalman_filter(Ts,offtime,d,1);
    %������
    XER(1:N,n)=x(1:N)-(XE(1:N))';
    YER(1:N,n)=y(1:N)-(YE(1:N))';
end



%�˲����ľ�ֵ
XERB=mean(XER,2);
YERB=mean(YER,2);

%�˲����ı�׼��
XSTD=std(XER,1,2); % ������ƫ�Ĺ���ֵ��flag='1'
YSTD=std(YER,1,2);

%��ͼ
figure
plot(x,y,'r');hold on;
plot(zx,zy,'g');hold on;
plot(XE,YE,'b');hold off;
axis([1500 5000 1000 10000]),grid on;
legend('��ʵ�켣','�۲�����','�˲�����');

figure
subplot(2,2,1)
plot(XERB)
axis([0 500 -50 50])
xlabel('�۲����')
ylabel('X�����˲�����ֵ'),grid on;
subplot(2,2,2)
plot(YERB)
axis([0 500 -50 50])
xlabel('�۲����')
ylabel('Y�����˲�����ֵ'),grid on;
subplot(2,2,3)
plot(XSTD)
axis([0 500 0 150])
xlabel('�۲����')
ylabel('X�����˲�����׼ֵ'),grid on;
subplot(2,2,4)
plot(YSTD)
axis([0 500 0 150])
xlabel('�۲����')
ylabel('Y�����˲�����׼ֵ'),grid on;

X=XER;Y=YER;