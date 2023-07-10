function [out,x_out] = sinc_interp(in,x_in,x_new,N,win)
%
% sinc_interp
%
% Sinc-based (band-limited)interpolation.
%
% INPUTS
% in =      ����ֵ������
% x_in =    �������ݵĺ����꣬���һ��
% x_new =   ����������ݵĺ����꣬���һ��
% N = order of interpolating sinc, in units of max(dx_in,dx_out).
% Must be odd.sinc����������ż��
% win = 1 if Hamming window applied to interpolation kernel, otherwise no
% window. (win=1 is recommended.) hamming��ѹ�Ƽ���˹ЧӦ
%
% OUTPUTS
% out = ��ֵ������ݶ�Ӧ�µ�����
% x_out.
% x_out = sample locations of output vector. This will be a subset of the
% locations in x_new; relative span of x_new and x_in, and filter
% end effects, may limit x_out to not include some of the values in
% x_new.
%
% Mark A. Richards
% February 2007
%
%--------------------------------------------------------------------------
%   �ж��Ƿ�Ϊ����
%--------------------------------------------------------------------------
if (mod(N,2) ~= 1)
    disp(' ')
    disp(' ** Error: sinc_interp : �˲�������Ϊ����.')
    disp([' ** Filter order input = ',int2str(N)])
    disp(' ')
    return
end

%--------------------------------------------------------------------------
Nhalf = (N-1)/2;
d_in = x_in(2) - x_in(1);                                                   %���������ļ��
d_out = x_new(2) - x_new(1);                                                %���������ļ��

%--------------------------------------------------------------------------
% Now figure out interpolating filter impulse response in continuous time.
% This will be a sinc function, possibly windowed. 

%--------------------------------------------------------------------------
% Bandwidth of the sinc LPF frequency response is based on the larger 
% sampling interval of the two grids. 
%--------------------------------------------------------------------------

% Specifically, the unwindowed impulse response is h(x) =
% sin(pi*x/del)/(pi*x) and dt = max(dt1,dt2). To add to this, we specify
% how many sample increments we will go out on the tails, where 1 increment
% is dt; and then we also apply a hamming window of the same length. The
% Hamming formula in continuous time is w(t) = 0.54 + 0.46*cos(pi*t/dt).
%--------------------------------------------------------------------------
del = max(d_in,d_out);                                                      %ѡȡ������

% find the values within x_new that can be successfully interpolated from the
% values available in x_in, i.e. where end effects won't kill us.
% x_in
% x_new
% Nhalf
% x_new(1)-Nhalf*del
% x_in(1)
% x_new(end)+Nhalf*del
% x_in(end)
%--------------------------------------------------------------------------
%   �жϲ�ֵ��Ҫ�����䣬ͬʱȥ��������õ��Ĳ�ֵ����
%--------------------------------------------------------------------------
index = find( (x_new-Nhalf*del >= x_in(1) ) & ...
(x_new+Nhalf*del <= x_in(end)) );
if (isempty(index))
    disp(' ')
    disp(' ** Error: sinc_interp : ���䲻�����ֵ����,�޽���')
    disp(' ')
    return
end
%--------------------------------------------------------------------------
%   �����������
%--------------------------------------------------------------------------
x_out = x_new(index);
out = zeros(size(x_out));

%--------------------------------------------------------------------------
%   ÿ��ѭ���������������������ֵ
%--------------------------------------------------------------------------
for k = 1:length(x_out)                                                     %ѭ������� ��1��ʼ
    % first find the span of the interpolating filter on the x axis
    x_current = x_out(k);
    x_low = x_current - Nhalf*del;                                          %��ǰ����ռ�õ�sinc������Χ ���
    x_high = x_current + Nhalf*del;                                         %��ǰ����ռ�õ�sinc������Χ �Ҳ�
    % compute the *relative* position of each input sample within this span
    % compared to the current output sample location; these will be the
    % values at which the interpolating kernel filter response will be
    % needed.
    index_rel = find( (x_in >= x_low ) & ...
    (x_in <= x_high) );
    x_rel = x_in(index_rel) - x_current;
    % Now compute and apply the sinc weights. First fix any spots where
    % x_rel = 0; these will cause the sinc function to be undefined. Then
    % add in the window, if used, and apply to the data to compute the
    % output point.
    trouble = find(x_rel==0);

    if (~isempty(trouble))
        x_rel(trouble) = x_rel(trouble)+eps; % this will prevent division by zero
    end
    h = (sin(pi*x_rel/del)/pi./x_rel);                                      %1/del ���Ǵ���
    w = ones(size(h));

    %----------------------------------------------------------------------
    %   �Ӵ�
    %----------------------------------------------------------------------
    if (win == 1)
        w = 0.54 + 0.46*cos(pi*x_rel/del/(Nhalf+1));
        h = h.*w;
    end
    h = h/sum(h);
    out(k) = sum( in(index_rel).*h);
end


% % Diagnostic figures showing a sample of sinc kernel and Hamming weights,
% % original and interpolated waveforms, and spectra of same.
% figure
% stem(x_rel,[h;w]')
% figure
% plot(x_in,real(in));
% title('Continuous Sinc Interpolation')
% hold on
% plot(x_out,real(out),'r');
% hold off
%
% % plot before-and-after spectra for a quality check. Note that different
% % sampling rates mean I need to use different frequency scales, and they
% % can't be normalized frequency.
% % figure
% Nfft = 2^(ceil(log2(max(length(x_out),length(x_in))))+2);
% X_in = d_in*fft(in,Nfft);
% f_in = (1/d_in)*((0:Nfft-1)/Nfft-0.5);
% X_out = d_out*fft(out,Nfft);
% f_out = (1/d_out)*((0:Nfft-1)/Nfft-0.5);
% % plot(f_in,abs(fftshift(X_in)))
% % title('Continuous Sinc Interpolation')
% % hold on
% % plot(f_out,abs(fftshift(X_out)),'r')
% % grid
% % hold off
% figure
% plot(f_in,db(abs(fftshift(X_in)),'voltage'))
% title('Continuous Sinc Interpolation')
% hold on
% plot(f_out,db(abs(fftshift(X_out)),'voltage'),'r')
% grid
% hold off
% pause