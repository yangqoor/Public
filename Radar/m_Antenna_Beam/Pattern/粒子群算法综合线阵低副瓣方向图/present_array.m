function f_out=present_array(Ns,d,theta,pop_a_present)
f1=zeros(1,Ns);
c=3e8;
fc=6e9;                    % ����Ƶ�ʣ�hz��
numda=c/fc;                % ���� wave length
N=16;                      % ������
d=0.5*numda;               % ��Ԫ���
k=(2*pi)/numda;            % ����
%------ÿ��������������ֵֻΪ�����һ�룬��Ϊ����Գƣ��������ۺ�ʱ���轫һ�������Գƻָ����ɵ���amplitude_curve.m������
for i=1:N/2
    b(i)=pop_a_present(N/2-i+1);
end
pop_a_present1=[pop_a_present b];

for l=1:Ns
    for i=1:N
        f(l)=pop_a_present1(i)*exp(j*(k*(i-1)*d*sin(theta(l)*pi/180)));
        f1(l)=f1(l)+f(l);
    end
end
f_out=20*log10(abs(f1)/max(abs(f1)));%ת��ΪdB��ʽ��
