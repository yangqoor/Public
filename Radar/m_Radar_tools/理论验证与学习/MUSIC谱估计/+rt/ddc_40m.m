%--------------------------------------------------------------------------
%   rt toolbox
%   author:qwe14789cn@gmail.com
%   https://github.com/qwe14789cn/radar_tools
%--------------------------------------------------------------------------
%   rt.ddc(sig,filter_coe,down_N)
%--------------------------------------------------------------------------
%   Description:
%   40Mhz input sig -> iq ->filter -> downsample
%--------------------------------------------------------------------------
%   input:
%           data_name               data name in workplace
%           data_type               string,float,int or something
%           file_name               the output filename
%   output:
%           None
%--------------------------------------------------------------------------
%   Examples:   
%   a = [1 2 3;4 5 6;7 8 9];
%   rt.write_data(a,'%d ','a.txt')
%--------------------------------------------------------------------------
function output = ddc_40m(sig,filter_coe,down_N)
disp("��֤�����źŰ���������")
long = size(sig,1);
N = fix(long/4);
M = rem(long,4);
I(1,:)= ones(1,N+1);
I(2,:)= zeros(1,N+1);
I(3,:)= -1*ones(1,N+1);
I(4,:)= zeros(1,N+1);
Q(1,:)= zeros(1,N+1);
Q(2,:)= ones(1,N+1);
Q(3,:)= zeros(1,N+1);
Q(4,:)= -1*ones(1,N+1);

I = reshape(I,1,4*(N+1));
Q = reshape(Q,1,4*(N+1));
I = I(1:(4*N+M))';
Q = Q(1:(4*N+M))';
disp("IQ����")

sig_IQ = sig.*I+1j.*sig.*Q;
disp('�˲�')
N = length(filter_coe);
output = zeros(size(sig,1)+N-1,size(sig,2));
for idx = 1:size(sig,2)
    output(:,idx) = conv(sig_IQ(:,idx),filter_coe);
end
output = output(N:end,:);
disp("��ȡ")
output = downsample(output,down_N);


