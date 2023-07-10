%--------------------------------------------------------------------------
%   spec(sig,fs,Nfft,select)
%--------------------------------------------------------------------------
%   ���ܣ�
%   �ź�Ƶ�׷������ߣ����ڷ����źŵķ�Ƶ��Ӧ����Ƶ��Ӧ��������Ӧ
%--------------------------------------------------------------------------
%   ���룺
%           sig             ԭʼ�ź�
%           fs              ��������
%           Nfft            fft����
%           select          ѡ��������λֵ       
%--------------------------------------------------------------------------
%   ���ӣ�
%   spec(sig,fs)                    ��ָ��fft����
%   spec(sig,fs,nfft)               ָ��fft����
%   spec(sig,fs,nfft,select)        ���ָ��������λֵ
%--------------------------------------------------------------------------
function spec(sig,fs,Nfft,select)
if nargin <=2
    N2 = nextpow2(length(sig));
    Nfft = 2^N2;
end
disp(['�źų���Ϊ -> ' num2str(numel(sig)) ' FFT����Ϊ -> ' num2str(Nfft)]);
f1 = figure(1);
f1.Position = [95 450 1671 494];
if isreal(sig)==1                                                           %ʵ�źŷ��������߹�����
    f = linspace(0,fs/2-fs/Nfft,Nfft/2);
    A = fft(sig,Nfft);
    A = A(1:Nfft/2);
    subplot(231);plot(f,pow2db(abs(A).^2));
    xlabel('Ƶ�� hz');ylabel('���� dB');grid on
    title(['��������' num2str(fs/1e6) ' Mhz ʵ�źŷ�Ƶ��Ӧ'])

    subplot(232);plot(pow2db(abs(A).^2));
    xlabel('����');ylabel('���� dB');grid on
    title(['��������' num2str(fs/1e6) ' Mhz ʵ�źŷ�Ƶ��Ӧ'])

    subplot(234);plot(f,rad2deg(angle(A)));
    xlabel('Ƶ�� hz');ylabel('��λ ��');ylim([-180 180]);grid on
    title(['��������' num2str(fs/1e6) ' Mhz ʵ�ź���Ƶ��Ӧ'])

    subplot(235);plot(rad2deg(angle(A)));
    xlabel('����');ylabel('��λ ��');ylim([-180 180]);grid on
    title(['��������' num2str(fs/1e6) ' Mhz ʵ�ź���Ƶ��Ӧ'])

    subplot(133);
    plot3(1:length(A),real(A),imag(A));grid on
    xlabel('����');ylabel('ʵ��');zlabel('�鲿')
    axis([0 length(A) -max(abs(A)) max(abs(A)) -max(abs(A)) max(abs(A))])
    %----------------------------------------------------------------------
    if nargin <=3                                                           %��������� �Զ�Ѱ�����ֵ
        select = find(A==max(A));
        ang = rad2deg(angle(A(select)));
    end
    if nargin ==4                                                           %��������� �Զ�Ѱ�����ֵ
        ang = rad2deg(angle(A(select)));
    end
    title(['�� ' num2str(select) ' ��λΪ ' num2str(ang) ' ��']);
    %----------------------------------------------------------------------
else                                                                        %���źŷ��������߹�����
    f = linspace(0,fs-fs/Nfft,Nfft);
    A = fft(sig,Nfft);
    subplot(231);plot(f,pow2db(abs(A).^2));
    xlabel('Ƶ�� hz');ylabel('���� dB');grid on
    title(['��������' num2str(fs/1e6) ' Mhz ���źŷ�Ƶ��Ӧ'])

    subplot(232);plot(pow2db(abs(A).^2));
    xlabel('����');ylabel('���� dB');grid on
    title(['��������' num2str(fs/1e6) ' Mhz �źŷ�Ƶ��Ӧ'])

    subplot(234);plot(f,rad2deg(angle(A)));
    xlabel('Ƶ�� hz');ylabel('��λ ��');ylim([-180 180]);grid on
    title(['��������' num2str(fs/1e6) ' Mhz ʵ�ź���Ƶ��Ӧ'])

    subplot(235);plot(rad2deg(angle(A)));
    xlabel('����');ylabel('��λ ��');ylim([-180 180]);grid on
    title(['��������' num2str(fs/1e6) ' Mhz ʵ�ź���Ƶ��Ӧ'])

    subplot(133);
    plot3(1:length(A),real(A),imag(A));grid on
    xlabel('����');ylabel('ʵ��');zlabel('�鲿');
    axis([0 length(A) -max(abs(A)) max(abs(A)) -max(abs(A)) max(abs(A))])
    %----------------------------------------------------------------------
    if nargin <=3                                                           %��������� �Զ�Ѱ�����ֵ
        select = find(A==max(A));
        ang = rad2deg(angle(A(select)));
    end

    if nargin ==4
        ang = rad2deg(angle(A(select)));
    end
    title(['���ֵ��Ӧ -> �� ' num2str(select) ' ��λΪ ' num2str(ang) ' ��']);
    %----------------------------------------------------------------------

end