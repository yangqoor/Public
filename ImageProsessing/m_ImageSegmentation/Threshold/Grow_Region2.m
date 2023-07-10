function OutImage = Grow_Region2(Image, x,y, threshold)
%区域增长程序

%Image ---待分割的图像
%x----种子点的x坐标
%y----种子点的y坐标

%threshold-----阈值

I = double(Image);
[m, n] = size(I);
flag = zeros(m, n);    %标记矩阵,记住哪些点走过，哪些点没有走过
total_num = m * n;
Qx = zeros(1, total_num);
Qy = zeros(1, total_num);
last = 1;     first = 1; %置为空队列
Qx(1, 1) = x;
Qy(1, 1) = y;
flag(x, y) = 1;

while(last >= first)  %队列不为空
    fx = Qx(1, first);
    fy = Qy(1, first);
    %==========fx-1, fy-1==============
    if ( ((fx - 1)>0) & ((fx - 1)<=m) & ((fy - 1)>0) & ((fy - 1)<=n))
        if ( ((I(x,y) - I(fx-1, fy-1))<=threshold) & (flag(fx-1, fy-1) == 0) )
            flag(fx-1, fy-1) = 1;
            last = last + 1;
            Qx(1, last) = fx -1;
            Qy(1, last) = fy -1;
        end
    end
    %==========fx, fy-1==============
    if ( ((fy - 1)>0) )
        if ( ((I(x,y) - I(fx, fy-1))<=threshold) & (flag(fx, fy-1) == 0) )
            flag(fx, fy-1) = 1;
            last = last + 1;
            Qx(1, last) = fx ;
            Qy(1, last) = fy -1;
        end
    end
    %==========fx+1, fy-1==============
    if ( ((fx + 1)<=m) & ((fy - 1)>0) )
        if ( ((I(x,y) - I(fx+1, fy-1))<=threshold) & (flag(fx+1, fy-1) == 0) )
            flag(fx+1, fy-1) = 1;
            last = last + 1;
            Qx(1, last) = fx +1;
            Qy(1, last) = fy -1;
        end
    end
    %==========fx+1, fy==============
    if ( ((fx + 1)<=m) )
        if ( ((I(x,y) - I(fx+1, fy))<=threshold) & (flag(fx+1, fy) == 0) )
            flag(fx+1, fy) = 1;
            last = last + 1;
            Qx(1, last) = fx + 1;
            Qy(1, last) = fy;
        end
    end


    %==========fx-1, fy==============
    if ( ((fx - 1)>0) )
        if ( ((I(x,y) - I(fx-1, fy))<=threshold) & (flag(fx-1, fy) == 0) )
            flag(fx-1, fy) = 1;
            last = last + 1;
            Qx(1, last) = fx - 1;
            Qy(1, last) = fy;
        end
    end
    %==========fx-1, fy+1==============
    if ( ((fx - 1)>0) & ((fy + 1)<=n) )
        if ( ((I(x,y) - I(fx-1, fy+1))<=threshold) & (flag(fx-1, fy+1) == 0) )
            flag(fx-1, fy+1) = 1;
            last = last + 1;
            Qx(1, last) = fx - 1;
            Qy(1, last) = fy + 1;
        end
    end
    %==========fx, fy+1==============
    if ( ((fy + 1)<=n) )
        if ( ((I(x,y) - I(fx, fy+1))<=threshold) & (flag(fx, fy+1) == 0) )
            flag(fx, fy+1) = 1;
            last = last + 1;
            Qx(1, last) = fx;
            Qy(1, last) = fy + 1;
        end
    end
    %==========fx+1, fy+1==============
    if ( ((fx + 1)<=m) & ((fy + 1)<=n) )
        if ( ((I(x,y) - I(fx+1, fy+1))<=threshold) & (flag(fx+1, fy+1) == 0) )
            flag(fx+1, fy+1) = 1;
            last = last + 1;
            Qx(1, last) = fx + 1;
            Qy(1, last) = fy + 1;
        end
    end

    first = first + 1;
end


OutImage = flag;

