%   ��άֱ��ͼ����ط�
%   �㷨�ο�����: ����,����Դ,��ά��. ��ά����ֵ�ָ�Ŀ����㷨. ���ϴ�ѧѧ��,1996,26(4):31-36
function [Th,segImg] = entropy_2D(cX)
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
    
    %��һ��ֱ��ͼ
    p=h_2d/(m*n);    
    
    %�ۼӶ�άֱ��ͼ
    Ps=cumsum(cumsum(p,1),2);
    temp=(p+eps).*(p==0)+p;
    Hs=cumsum(cumsum(-p.*log(temp),1),2);
    
    temp=(Ps+eps).*(Ps==0)+Ps;
    H0=log(temp)+Hs./temp;

    Ps=1-Ps;
    temp=(Ps+eps).*(Ps==0)+Ps;
    H1=log(temp)+(Hs(256,256)-Hs)./temp;

    ResultMatrix=H0+H1;
    
%     H=[H0(:),H1(:)];
%     
%     temp=min(H,[],2);
%     
%     ResultMatrix=reshape(temp,256,256);

    %������ֵ���ڵ��� 
    [MaxRow,RowIndex]=max(ResultMatrix);
    %������ֵ���ڵ���
    [MaxCol,ColIndex]=max(MaxRow);
    T=ColIndex;
    Th=RowIndex(T);

    segImg=(cX>Th);
