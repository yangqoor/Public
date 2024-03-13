function Ac = GetAirLight(I_rgb, I_dark, percentage)
% get the Ac parameter of Equ(15)
% �ȴӰ�ͨ���л�ȡ�����ĵ㣨��ֹһ���������꣬Ȼ����ÿ����ɫͨ���϶���Щ�����ϵ�ֵ���ֵ

I_brightest = im2bw(I_dark, percentage*max(max(I_dark)));
count = length(find(I_brightest));

Ac = [0,0,0];
for c = 1:3
    sum_brightest = sum(sum(I_rgb(:,:,c).*I_brightest));
    Ac(c) = sum_brightest/count;
end

end