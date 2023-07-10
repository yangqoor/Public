function Hist_2D = Get2DHist(cX)
    [m,n]=size(cX);
    
    cX=double(cX);
    
    %����ԭͼ���8����Ҷ�ͼ
    myfilt=[1/8,1/8,1/8;1/8,0,1/8;1/8,1/8,1/8];
    g=round(filter2(myfilt,cX));
    
    %������άֱ��ͼ
    h_2d=zeros(256);    %��ʼ��
    for i=1:m
        for j=1:n
            r=cX(i,j)+1;c=g(i,j)+1;
            h_2d(r,c)=h_2d(r,c)+1;
        end
    end

    Hist_2D=h_2d;