function [region_matrix,region_count]=grow_region(I_image,seed,region_th)
%I_image为所输入图像
%seed为种子点坐标
%region_matrix为输出的标记矩阵
%region_count为每个区域对应的象素数：region_count(i)就是第i个区域的象素数


%输入图像处理
% I_image=imread('test2.bmp');
% I_image=rgb2gray(I_image);

[row,col]=size(I_image);%图像的大小

%输出初始化
region_num=0;%标注区域的号码
region_matrix=zeros(row,col);%制造一个标注象素聚合的矩阵

%对所有没有被标记的种子点进行区域生长
[seed_num,~]=size(seed);%种子点的数量
for num=1:seed_num
    yseed=seed(num,1);%提取种子点坐标
    xseed=seed(num,2);
    pixel_seed=I_image(yseed,xseed);%种子的象素值

    if region_matrix(yseed,xseed)==0
        region_num=region_num+1;%设定区域的标记号
        queue=[yseed,xseed];%将种子的坐标存入队列中
        top=1;%设定队列矩阵的顶端位置

        %开始象素聚合
        region_count(region_num)=1;     %制造一个聚合区域的计数器
        while top~=0       %当队列矩阵中没有存放任何坐标时、则停止循环

            %取出队列矩阵中的最底端坐标值
            row_buttom=queue(1,1);
            col_buttom=queue(1,2);
            pixel_buttom=I_image(row_buttom,col_buttom);

            %以此坐标轴为种子，判断周围各象素是否属于相同的区域%
            for i=-1:1
                for j=-1:1
                    if row_buttom+i<=row&row_buttom+i>0&col_buttom+j<=col&col_buttom+j>0
                        if region_matrix(row_buttom+i,col_buttom+j)~=region_num&abs(double(I_image(row_buttom+i,col_buttom+j))-double(pixel_buttom))<=region_th
                            %若象素之间的差值小于区域临界值，则判定为同一区域
                            top=top+1;%队列矩阵顶端top值增加1
                            %将此象素坐标存入队列矩阵的顶端
                            queue(top,:)=[row_buttom+i,col_buttom+j];
                            region_matrix(row_buttom+i,col_buttom+j)=region_num;%标注为1
                            region_count(region_num)=region_count(region_num)+1;
                        end
                    end
                end
            end

            %将已经做完聚合的坐标从队列矩阵中删除
            queue=queue(2:top,:);
            top=top-1;
        end
    end
end
% figure,imshow(region_matrix)

