function y = sinc_interp(x,u)   %x �����źţ�u��ֵ��������
m = 0:length(x)-1;

for idx = 1:length(u)
    y(idx) = sum(x.*sinc(m-u(idx))); %sinc�����Գ� ��������ν
end
