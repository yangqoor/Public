clear
clc
x = linspace(0,10);

y1 = sin(x);

y2 = sin(2*x);

y3= sin(4*x);

y4 = sin(8*x);

[ha, pos] = tight_subplot(2,2,[.05 .03],[.08 .05],[.05 .05])

%[ha, pos] = tight_subplot(行数, 列数, [上下间距 左右间距],[下边距 上边距 ], [左边距 右边距 ])

axes(ha(1));

plot(x,y1)

title('Subplot 1: sin(x)')

axes(ha(2));

plot(x,y2)

title('Subplot 2: sin(2x)')

axes(ha(3));

plot(x,y3)

title('Subplot 3: sin(4x)')

axes(ha(4));

plot(x,y4)

title('Subplot 4: sin(8x)')