function f_out=present_array(Ns,d,theta,pop_a_present)
f1=zeros(1,Ns);
c=3e8;
fc=6e9;                    % 工作频率（hz）
numda=c/fc;                % 波长 wave length
N=16;                      % 阵列数
d=0.5*numda;               % 阵元间距
k=(2*pi)/numda;            % 波数
%------每个粒子所包含的值只为馈电的一半，因为馈电对称，所以在综合时，需将一半的馈电对称恢复。可调用amplitude_curve.m函数。
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
f_out=20*log10(abs(f1)/max(abs(f1)));%转化为dB形式。
