function [data_out,sinc_interp_matrix] = sinc_in(data_in,x_in,x_new)
%--------------------------------------------------------------------------
%   20181127 ����
%   sinc��ֵ������д��ȥ���˸������߰����������ʵ���ǿ����� ֱ��ץ��ֵ����
%   ����,data_in����������,��ֵ�������Ϊdata_in * sinc_interp_matrix
%--------------------------------------------------------------------------
sinc_interp_matrix = zeros(length(x_in),length(x_new));
% delta1 = x_in(2)-x_in(1);
delta2 = x_new(2)-x_new(1);

delta = delta2;                                                             %���ղ�ֵ�������˲������� B = 1/delta

%--------------------------------------------------------------------------
%   ���ĺ���  sinc((x-x0)/delta) ������1/delta x0��Ҫ�ĵ�����
%--------------------------------------------------------------------------
for idx = 1:length(data_in)
    data_out(idx) = sum(data_in.*sinc((x_in-x_new(idx))./delta));
    sinc_interp_matrix(:,idx) = sinc((x_in-x_new(idx))./delta);
end
