pic_num = 1;
for fai = 0:0.05:pi*2
    %----------------------------------------------------------------------
    % 这里你随便写你的代码 出图到f = figure(1);
    %----------------------------------------------------------------------
    plot(sin(1:0.01:10+fai))
    drawnow
    %----------------------------------------------------------------------
    F=getframe(gcf);
    I=frame2im(F);
    [I,map]=rgb2ind(I,256);
    if pic_num == 1
        imwrite(I,map,'test.gif','gif','Loopcount',inf,'DelayTime',0.05);
    else
        imwrite(I,map,'test.gif','gif','WriteMode','append','DelayTime',0.05);
    end
    pic_num = pic_num + 1;
    %----------------------------------------------------------------------
end