function [I] = get_size_image_i( Gray_image, threshold, ST )
[row, col]=size(Gray_image);
    %devide image to 4 part 
    UL = Gray_image(1:round(row/2), 1:round(col/2));
    UR = Gray_image(1:round(row/2),round(col/2)+1:end);
%     LL = Gray_image(round(row/2)+1:end, 1:round(col/2));
%     LR = Gray_image(round(row/2)+1:end, round(col/2)+1:end);
    %find mean value of each part
    MUL = mean(UL(:));
    MUR = mean(UR(:));
%     MLL = mean(mean(LL));
%     MLR = mean(mean(LR));
    %find max of meaan value
    x = max([MUL MUR]);
        if x == MUL 
            I = UL;
            while ST > threshold
    [I,ST] = ham_chia_tren(I);
            end
        elseif x == MUR 
            I = UR;
while ST > threshold
       [I,ST] = ham_chia_tren(I);
end
%         elseif x == MLL 
%             I = LL;
%             while ST > threshold
%     [I,ST] = ham_chia_tren(I);
%             end
%         elseif x == MLR 
%             I = LR;
%             while ST > threshold
%     [I,ST] = ham_chia_tren(I);
            end
end