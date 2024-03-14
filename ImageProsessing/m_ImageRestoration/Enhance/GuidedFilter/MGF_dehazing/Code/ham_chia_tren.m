function [I,ST] = ham_chia_tren(I)
[row, col]=size(I);
    %[rows, columns, numberOfColorChannels] = size(yourImage);
    %divide image to 4 part 
    UL = I(1:round(row/2), 1:round(col/2));
    UR = I(1:round(row/2),round(col/2)+1:end);
    LL = I(round(row/2)+1:end, 1:round(col/2));
    LR = I(round(row/2)+1:end, round(col/2)+1:end);
    %find mean value of each part
    MUL = mean(UL(:));
    MUR = mean(UR(:));
    MLL = mean(LL(:));
    MLR = mean(LR(:));
    %find max of meaan value
    x = maxk([MUL MUR MLL MLR],2);
        if x(1) == MUL 
            I = UL;
        elseif x(1) == MUR 
            I = UR;
        elseif x(1) == MLL
                    I = LL;
        elseif x(1) == MLR
                I = UR;
        end
    ST = x(1) - x(2);
end