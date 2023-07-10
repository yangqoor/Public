function XE=Kalman_filter(Ts,offtime,d,Flag)
% XE=Kalman_filter(Ts,offtime,d,Flag);
% Kalman_filter             ����Kalman�˲��������ӹ۲���ֵ�еõ������Ĺ���
% XE                        ���x�᷽���ϵ����
% Ts                        ����ʱ�䣬���״﹤������
% offtime                   �����ֹʱ��
% d                         �����ı�׼��ֵ
% Flag                      �жϼ���x���y������,'0'--x,'1'--y
if nargin>4
    error('����ı������࣬����');
end

if offtime<600
    error('����ʱ��������600s������������');
end

Pv=d*d; % �����Ĺ���
N=ceil(offtime/Ts); % ��������
sigma=10;% ���ٶȷ���ĵ��Ŷ�

switch Flag
    case 0
        a=[zeros(1,400) 0.075*ones(1,200) zeros(1,10) -0.3*ones(1,50) zeros(1,offtime-660)]; % �Բ�ͬʱ�εļ��ٶȽ�������
    case 1
        a=[zeros(1,400) 0.075*ones(1,200) zeros(1,10)  0.3*ones(1,50) zeros(1,offtime-660)];
    otherwise
        error('�������Ϊ0��1');
end 

% ����ϵͳ��״̬����
Phi=[1,Ts;0,1];
Gamma=[Ts*Ts/2;Ts];
C=[1 0];
R=Pv;
Q=sigma^2;W=[];

randn('state',sum(100*clock)); % ���������������
for n=0:Ts:offtime-1
    W(n/Ts+1)=a(n+1)+sigma*randn(1,1);
end


Xest=zeros(2,1); % ��ǰk-1ʱ�̵����ֵ����kʱ�̵�Ԥ��ֵ
Xfli=zeros(2,1); % kʱ��Kalman�˲��������ֵ
Xes=zeros(2,1); % Ԥ��������
Xef=zeros(2,1); % �˲�����������
Pxe=zeros(2,1); % Ԥ���������������� 
Px=zeros(2,1);  % �˲���������������
XE=zeros(1,N); % �õ����յ��˲����ֵ���������Ǿ������

[x,y]=trajectory(Ts,offtime); % �������۵ĺ���

for i=1:N
   vx(i)=d*randn(1); % �۲����������߶���
   vy(i)=d*randn(1);
   zx(i)=x(i)+vx(i); % ʵ�ʹ۲�ֵ
   zy(i)=y(i)+vy(i);
end

switch Flag
    case 0
        Xfli=[zx(2) (zx(2)-zx(1))/Ts]'; %����ǰ�����۲�ֵ���Գ�ʼ�������й���
        Xef=[-vx(2) Ts*W(1)/2+(vx(1)-vx(2))/Ts]';
        Px=[Pv,Pv/Ts;Pv/Ts,2*Pv/Ts+Ts*Ts*Q/4];

        for k=3:N
        Xest=Phi*Xfli; % ���¸�ʱ�̵�Ԥ��ֵ
        Xes=Phi*Xef+Gamma*W(k-1); % Ԥ��������
        Pxe=Phi*Px*Phi'+Gamma*Q*Gamma'; % Ԥ������Э������
        K=Pxe*C'*inv(C*Pxe*C'+R); % Kalman�˲�����
    
        Xfli=Xest+K*(zx(k)-C*Xest); 
        Xef=(eye(2)-K*C)*Xes-K*vx(k);
        Px=(eye(2)-K*C)*Pxe;
        
        XE(k)=Xfli(1,1);
        end
        
        XE(1)=zx(1);XE(2)=zx(2);
        
    case 1
        Xfli=[zy(2) (zy(2)-zy(1))/Ts]'; %����ǰ�����۲�ֵ���Գ�ʼ�������й���
        Xef=[-vy(2) Ts*W(1)/2+(vy(1)-vy(2))/Ts]';
        Px=[Pv,Pv/Ts;Pv/Ts,2*Pv/Ts+Ts*Ts*Q/4];

        for k=3:N
        Xest=Phi*Xfli; % ���¸�ʱ�̵�Ԥ��ֵ
        Xes=Phi*Xef+Gamma*W(k-1); % Ԥ��������
        Pxe=Phi*Px*Phi'+Gamma*Q*Gamma'; % Ԥ������Э������
        K=Pxe*C'*inv(C*Pxe*C'+R); % Kalman�˲�����
    
        Xfli=Xest+K*(zy(k)-C*Xest); 
        Xef=(eye(2)-K*C)*Xes-K*vy(k);
        Px=(eye(2)-K*C)*Pxe;
        
        XE(k)=Xfli(1,1);
        end
        
        XE(1)=zy(1);XE(2)=zy(2);       
    otherwise
        error('False iuput nargin');
end




   
    
