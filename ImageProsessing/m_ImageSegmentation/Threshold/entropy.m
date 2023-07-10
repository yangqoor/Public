%   ���������ԭ�����ֵ��
%   �㷨�ο�����: ����,ʷ�ҿ�. ���������ԭ��Ķ���ֵ�Զ�ѡȡ�·���. �й�ͼ��ͼ��ѧ��, 2002, 7(A):461-465.
%   �������:   cX--�Ҷ�ͼ����ƵС����ͼ
%               N--������
%   ���: th--�ָ�������ֵ,Ϊһһά����,��СΪN
%         en--�ָ�ʱ��������
function [Th,segImg] = entropy(cX,N)
%   ���ͼ������������ֵ
    [row,col]=size(cX);
%   ͳ�Ʋ����ظ����Ҷȵȼ����ظ��������й�һ������,��ø��Ҷȵȼ�����
    h=imhist(cX)/row/col;
    
%   ��ʼ������ֵ
    Th=zeros(N-1,1);
    en=Th;

%   ��ֱ��ͼ�����ۼ�
    pA=cumsum(h);
%   ����Ϣ��ԭ�������ֵ
    for i=1:N-1
        [Th(i),en(i)]=min(abs(pA-i/N));
    end
    
    %�Ի�ֵ��������
    Th=sort(Th);
    
    segImg=zeros(row,col);
    
%     temp=zeros(row,col);
    
    for i=1:N-2
        temp=cX>Th(i) & cX<=Th(i+1);
        if(~isempty(temp))
            segImg=segImg+i*temp;
        end
    end
    temp=cX>Th(N-1);
    if(~isempty(temp))
        segImg=segImg+(N-1)*(cX>Th(N-1));
    end
