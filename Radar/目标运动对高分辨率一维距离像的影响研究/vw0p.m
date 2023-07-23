%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�������з�����
%��Ҫ�����ӳ���data_sim.m������ʦ�ṩ����ֱ�Ӱ� RUN �ȿ����У��������к󣬽�����4��ͼ��Figure1��Ӧʵ��1
%Figure1��Ӧʵ��3    Figure3��Ӧʵ��3    Figure4��Ӧʵ��4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����ٶ�V=0ʱ�ĸ߷ֱ���һά������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I_freq,Q_freq] = data_sim(3,[897,901,905],[50,10,20],64,10000000,10000,0,900);%�����ӳ���[I_freq,Q_freq]
B=(64-1)*10000000%�״��źŴ���
k=3e8/(2*B)%�������ֱ���
t=900-63.5*k/2:k/2:900+63.5*k/2%�涨x��Ϊ����,��Ϊ�任ʱ�����˲���,���Ե�����ľ���ȡ�ֱ�����һ��
w=hamming(64)%��Hamming��
IQ_freq=I_freq+Q_freq *j%���������ϳɸ�����ʽ�ź�
windowed_I_freq(1:64)=I_freq.*w%��ͬ������Ӵ�
windowed_Q_freq(1:64)=Q_freq.*w%�����������Ӵ�
windowed_IQ_freq(1:64)=windowed_I_freq+windowed_Q_freq *j%�Ӵ��������������ͬ������ϳɸ�����ʽ���ź�
IQ_time(1:128)=ifft(IQ_freq,128)%������ٽ����渵��Ҷ�任������ǿͼ���ϸ������
shifted_IQ_time=ifftshift(IQ_time)%����Ƶ�ʵ���Ƶ�Ƶ������
windowed_IQ_time(1:128)=ifft(windowed_IQ_freq,128)%������ٽ����渵��Ҷ�任������ǿͼ���ϸ������
shifted_windowed_IQ_time=ifftshift(windowed_IQ_time)%����Ƶ�ʵ���Ƶ�Ƶ������
subplot(1,2,1)%������ͼ��
plot(t,20*log10(abs(shifted_IQ_time)))%y���÷ֱ�Ϊ��λ
title('��δ�Ӵ������������ٶ�V=0��')
xlabel('����(m)')%������
ylabel('ǿ��(DB)')%������
grid on
subplot(1,2,2)
plot(t,20*log10(abs(shifted_windowed_IQ_time)),'r')
title('����Hanmming�������������ٶ�V=0��')
xlabel('����(m)')%������
ylabel('ǿ��(DB)')%������
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����ٶ�V=100ʱ�ĸ߷ֱ���һά������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I_freq,Q_freq] = data_sim(3,[897,901,905],[50,10,20],64,10000000,10000,100,900);
B=(64-1)*10000000%�״��źŴ���
k=3e8/(2*B)%�������ֱ���
t=900-63.5*k/2:k/2:900+63.5*k/2%�涨x��Ϊ����,��Ϊ�任ʱ�����˲���,���Ե�����ľ���ȡ�ֱ�����һ��
w=hamming(64)%��Hamming��
IQ_freq=I_freq+Q_freq *j%���������ϳɸ�����ʽ�ź�
windowed_I_freq(1:64)=I_freq.*w%��ͬ������Ӵ�
windowed_Q_freq(1:64)=Q_freq.*w%�����������Ӵ�
windowed_IQ_freq(1:64)=windowed_I_freq+windowed_Q_freq *j%�Ӵ��������������ͬ������ϳɸ�����ʽ���ź�
IQ_time(1:128)=ifft(IQ_freq,128)%������ٽ����渵��Ҷ�任������ǿͼ���ϸ������
shifted_IQ_time=ifftshift(IQ_time)%����Ƶ�ʵ���Ƶ�Ƶ������
windowed_IQ_time(1:128)=ifft(windowed_IQ_freq,128)%������ٽ����渵��Ҷ�任������ǿͼ���ϸ������
shifted_windowed_IQ_time=ifftshift(windowed_IQ_time)
figure
subplot(1,2,1)%������ͼ��
plot(t,20*log10(abs(shifted_IQ_time)))%y���÷ֱ�Ϊ��λ
title('��δ�Ӵ������������ٶ�V=100��')
xlabel('����(m)')%������
ylabel('ǿ��(DB)')%������
grid on
subplot(1,2,2)
plot(t,20*log10(abs(shifted_windowed_IQ_time)),'r')
title('����Hanmming�������������ٶ�V=100��')
xlabel('����(m)')%������
ylabel('ǿ��(DB)')%������
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����ٶ�V=300ʱ�ĸ߷ֱ���һά������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I_freq,Q_freq] = data_sim(3,[897,901,905],[50,10,20],64,10000000,10000,300,900);
B=(64-1)*10000000%�״��źŴ���
k=3e8/(2*B)%�������ֱ���
t=900-63.5*k/2:k/2:900+63.5*k/2%�涨x��Ϊ����,��Ϊ�任ʱ�����˲���,���Ե�����ľ���ȡ�ֱ�����һ��
w=hamming(64)
IQ_freq=I_freq+Q_freq *j
windowed_I_freq(1:64)=I_freq.*w
windowed_Q_freq(1:64)=Q_freq.*w
windowed_IQ_freq(1:64)=windowed_I_freq+windowed_Q_freq *j
IQ_time(1:128)=ifft(IQ_freq,128)
shifted_IQ_time=ifftshift(IQ_time)%���ò�����渵��ҵ�任��߻�ͼ������
windowed_IQ_time(1:128)=ifft(windowed_IQ_freq,128)
shifted_windowed_IQ_time=ifftshift(windowed_IQ_time)
figure
subplot(1,2,1)
plot(t,20*log10(abs(shifted_IQ_time)))%y���÷ֱ�Ϊ��λ
title('��δ�Ӵ������������ٶ�V=300��')
xlabel('����(m)')%������
ylabel('ǿ��(DB)')%������
grid on  %����
subplot(1,2,2)
plot(t,20*log10(abs(shifted_windowed_IQ_time)),'r')
title('����Hanmming�������������ٶ�V=300��')
xlabel('����(m)')%������
ylabel('ǿ��(DB)')%������
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����ٶ�V=-300ʱ�ĸ߷ֱ���һά������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I_freq,Q_freq] = data_sim(3,[897,901,905],[50,10,20],64,10000000,10000,-300,900);
B=(64-1)*10000000%�״��źŴ���
k=3e8/(2*B)%�������ֱ���
t=900-63.5*k/2:k/2:900+63.5*k/2%�涨x��Ϊ����,��Ϊ�任ʱ�����˲���,���Ե�����ľ���ȡ�ֱ�����һ��
w=hamming(64)
IQ_freq=I_freq+Q_freq *j
windowed_I_freq(1:64)=I_freq.*w
windowed_Q_freq(1:64)=Q_freq.*w
windowed_IQ_freq(1:64)=windowed_I_freq+windowed_Q_freq *j
IQ_time(1:128)=ifft(IQ_freq,128)
shifted_IQ_time=ifftshift(IQ_time)%���ò�����渵��ҵ�任��߻�ͼ������
windowed_IQ_time(1:128)=ifft(windowed_IQ_freq,128)
shifted_windowed_IQ_time=ifftshift(windowed_IQ_time)
figure
subplot(1,2,1)
plot(t,20*log10(abs(shifted_IQ_time)))%y���÷ֱ�Ϊ��λ
title('��δ�Ӵ������������ٶ�V=-300��')
xlabel('����(m)')%������
ylabel('ǿ��(DB)')%������
grid on
subplot(1,2,2)
plot(t,20*log10(abs(shifted_windowed_IQ_time)),'r')
title('����Hanmming�������������ٶ�V=-300��')
xlabel('����(m)')%������
ylabel('ǿ��(DB)')%������
grid on