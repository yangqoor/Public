
G=tf(1,conv(conv([1,1],[1,2]),[1,5]));
Kp=2;%k=2
ti=[3,8,14,21,28];%时间常数取值
for i=1:5
G1=tf([Kp,Kp/ti(i)],[1,0]);
sys=feedback(G1*G,1);
step(sys);hold on
end
gtext('ti=3');gtext('ti=8');gtext('ti=14');gtext('ti=21');gtext('ti=28')
%绘制出不同曲线