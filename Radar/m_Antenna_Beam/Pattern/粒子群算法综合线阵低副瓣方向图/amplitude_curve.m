%-------该函数将馈电幅值进行对称恢复-------
function amplitude=amplitude_curve(a);
N=16;
for i=1:N/2
    b(i)=a(N/2-i+1);
end
amplitude=[a;b'];
