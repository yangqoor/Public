%--------------------------------------------------------------------------
%   nlm������ƹ���
%   qwe14789cn@gmail.com
%   201800514
%--------------------------------------------------------------------------
%   h_output = nlm_wave(T,bw,fs,Window)
%   bw �źŴ���,�ֲ��Ǵ�-bw/2��bw/2
%   T  �źų���
%   fs �������ʣ����ն��������������ź�
%   K  ����ϵ��
%   WindowƵ�ʴ�����ѡ��,���봰����,����@hamming,@taylorwin
%--------------------------------------------------------------------------
%   example
%   nlm_wave(20e-6,100e6,10e6,@hamming)
%   nlm_wave(20e-6,100e6,10e6,@hamming)
%   nlm_wave(20e-6,100e6,10e6,@hamming)
%--------------------------------------------------------------------------
function sig = nlm_wave(T,bw,fs,window)
N  = round(fs * T);
f  = -bw/2:bw/N:bw/2 - bw/N;
t  = 0:1/fs:T - 1/fs;
Wf  = window(N);
Tf  = cumtrapz(f,Wf);

Ft  = interp1(Tf,f,linspace(min(Tf),max(Tf),N));

phi = 2 * pi * cumtrapz(t,Ft);
sig = exp(1j*phi');
end