%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%程序运行方法：
%需要调动子程序data_sim.m（许老师提供），直接按 RUN 既可运行，程序运行后，将出现4组图像：Figure1对应实验1
%Figure1对应实验3    Figure3对应实验3    Figure4对应实验4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%径向速度V=0时的高分辨率一维距离像
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I_freq,Q_freq] = data_sim(3,[897,901,905],[50,10,20],64,10000000,10000,0,900);%调用子程序[I_freq,Q_freq]
B=(64-1)*10000000%雷达信号带宽
k=3e8/(2*B)%径向距离分辨力
t=900-63.5*k/2:k/2:900+63.5*k/2%规定x轴为长度,因为变换时采用了补零,所以点与点间的距离取分辨力的一半
w=hamming(64)%加Hamming窗
IQ_freq=I_freq+Q_freq *j%正交分量合成复数形式信号
windowed_I_freq(1:64)=I_freq.*w%对同向分量加窗
windowed_Q_freq(1:64)=Q_freq.*w%对正交分量加窗
windowed_IQ_freq(1:64)=windowed_I_freq+windowed_Q_freq *j%加窗后的正交分量和同向分量合成复数形式的信号
IQ_time(1:128)=ifft(IQ_freq,128)%补零后再进行逆傅立叶变换可以增强图像的细节特征
shifted_IQ_time=ifftshift(IQ_time)%把零频率点搬移到频谱中心
windowed_IQ_time(1:128)=ifft(windowed_IQ_freq,128)%补零后再进行逆傅立叶变换可以增强图像的细节特征
shifted_windowed_IQ_time=ifftshift(windowed_IQ_time)%把零频率点搬移到频谱中心
subplot(1,2,1)%生成子图像
plot(t,20*log10(abs(shifted_IQ_time)))%y轴用分贝为单位
title('“未加窗”并“径向速度V=0”')
xlabel('距离(m)')%横坐标
ylabel('强度(DB)')%纵坐标
grid on
subplot(1,2,2)
plot(t,20*log10(abs(shifted_windowed_IQ_time)),'r')
title('“加Hanmming窗”并“径向速度V=0”')
xlabel('距离(m)')%横坐标
ylabel('强度(DB)')%纵坐标
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%径向速度V=100时的高分辨率一维距离像
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I_freq,Q_freq] = data_sim(3,[897,901,905],[50,10,20],64,10000000,10000,100,900);
B=(64-1)*10000000%雷达信号带宽
k=3e8/(2*B)%径向距离分辨力
t=900-63.5*k/2:k/2:900+63.5*k/2%规定x轴为长度,因为变换时采用了补零,所以点与点间的距离取分辨力的一半
w=hamming(64)%加Hamming窗
IQ_freq=I_freq+Q_freq *j%正交分量合成复数形式信号
windowed_I_freq(1:64)=I_freq.*w%对同向分量加窗
windowed_Q_freq(1:64)=Q_freq.*w%对正交分量加窗
windowed_IQ_freq(1:64)=windowed_I_freq+windowed_Q_freq *j%加窗后的正交分量和同向分量合成复数形式的信号
IQ_time(1:128)=ifft(IQ_freq,128)%补零后再进行逆傅立叶变换可以增强图像的细节特征
shifted_IQ_time=ifftshift(IQ_time)%把零频率点搬移到频谱中心
windowed_IQ_time(1:128)=ifft(windowed_IQ_freq,128)%补零后再进行逆傅立叶变换可以增强图像的细节特征
shifted_windowed_IQ_time=ifftshift(windowed_IQ_time)
figure
subplot(1,2,1)%生成子图像
plot(t,20*log10(abs(shifted_IQ_time)))%y轴用分贝为单位
title('“未加窗”并“径向速度V=100”')
xlabel('距离(m)')%横坐标
ylabel('强度(DB)')%纵坐标
grid on
subplot(1,2,2)
plot(t,20*log10(abs(shifted_windowed_IQ_time)),'r')
title('“加Hanmming窗”并“径向速度V=100”')
xlabel('距离(m)')%横坐标
ylabel('强度(DB)')%纵坐标
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%径向速度V=300时的高分辨率一维距离像
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I_freq,Q_freq] = data_sim(3,[897,901,905],[50,10,20],64,10000000,10000,300,900);
B=(64-1)*10000000%雷达信号带宽
k=3e8/(2*B)%径向距离分辨力
t=900-63.5*k/2:k/2:900+63.5*k/2%规定x轴为长度,因为变换时采用了补零,所以点与点间的距离取分辨力的一半
w=hamming(64)
IQ_freq=I_freq+Q_freq *j
windowed_I_freq(1:64)=I_freq.*w
windowed_Q_freq(1:64)=Q_freq.*w
windowed_IQ_freq(1:64)=windowed_I_freq+windowed_Q_freq *j
IQ_time(1:128)=ifft(IQ_freq,128)
shifted_IQ_time=ifftshift(IQ_time)%采用补零的逆傅立业变换提高绘图的质量
windowed_IQ_time(1:128)=ifft(windowed_IQ_freq,128)
shifted_windowed_IQ_time=ifftshift(windowed_IQ_time)
figure
subplot(1,2,1)
plot(t,20*log10(abs(shifted_IQ_time)))%y轴用分贝为单位
title('“未加窗”并“径向速度V=300”')
xlabel('距离(m)')%横坐标
ylabel('强度(DB)')%纵坐标
grid on  %网格
subplot(1,2,2)
plot(t,20*log10(abs(shifted_windowed_IQ_time)),'r')
title('“加Hanmming窗”并“径向速度V=300”')
xlabel('距离(m)')%横坐标
ylabel('强度(DB)')%纵坐标
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%径向速度V=-300时的高分辨率一维距离像
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I_freq,Q_freq] = data_sim(3,[897,901,905],[50,10,20],64,10000000,10000,-300,900);
B=(64-1)*10000000%雷达信号带宽
k=3e8/(2*B)%径向距离分辨力
t=900-63.5*k/2:k/2:900+63.5*k/2%规定x轴为长度,因为变换时采用了补零,所以点与点间的距离取分辨力的一半
w=hamming(64)
IQ_freq=I_freq+Q_freq *j
windowed_I_freq(1:64)=I_freq.*w
windowed_Q_freq(1:64)=Q_freq.*w
windowed_IQ_freq(1:64)=windowed_I_freq+windowed_Q_freq *j
IQ_time(1:128)=ifft(IQ_freq,128)
shifted_IQ_time=ifftshift(IQ_time)%采用补零的逆傅立业变换提高绘图的质量
windowed_IQ_time(1:128)=ifft(windowed_IQ_freq,128)
shifted_windowed_IQ_time=ifftshift(windowed_IQ_time)
figure
subplot(1,2,1)
plot(t,20*log10(abs(shifted_IQ_time)))%y轴用分贝为单位
title('“未加窗”并“径向速度V=-300”')
xlabel('距离(m)')%横坐标
ylabel('强度(DB)')%纵坐标
grid on
subplot(1,2,2)
plot(t,20*log10(abs(shifted_windowed_IQ_time)),'r')
title('“加Hanmming窗”并“径向速度V=-300”')
xlabel('距离(m)')%横坐标
ylabel('强度(DB)')%纵坐标
grid on