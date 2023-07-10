%   �Լ���ƵĶ�άֱ��ͼ����ط�
%   �㷨�ο�����: ����,����Դ,��ά��. ��ά����ֵ�ָ�Ŀ����㷨. ���ϴ�ѧѧ��,1996,26(4):31-36
%   ����,ʷ�ҿ�. ���������ԭ��Ķ���ֵ�Զ�ѡȡ�·���. �й�ͼ��ͼ��ѧ��, 2002, 7(A):461-465.
%   ���õȸ��ʳ�������ԭ�������ֵ
function [Th, segImg] = My2D_Entropy(cX, N)
    [m, n] = size(cX);

    cX = double(cX);

    %����ԭͼ���8����Ҷ�ͼ
    myfilt = [1/8, 1/8, 1/8; 1/8, 0, 1/8; 1/8, 1/8, 1/8];
    g = round(filter2(myfilt, cX));

    %������άֱ��ͼ
    h_2d = zeros(256); %��ʼ��

    for i = 1:m

        for j = 1:n
            r = cX(i, j) + 1;
            c = g(i, j) + 1;
            h_2d(r, c) = h_2d(r, c) + 1;
        end

    end

    %��һ��ֱ��ͼ
    p = h_2d / (m * n);

    Ps = cumsum(cumsum(p, 1), 2);

    %��ʼ�����
    Th = zeros(N - 1, 1);
    En = Th;

    for i = 1:N - 1
        temp = abs(Ps - i / N);
        %������ֵ���ڵ���
        [MinRow, RowIndex] = min(temp);
        %������ֵ���ڵ���
        [MinCol, ColIndex] = min(MinRow);
        S = ColIndex;
        Th(i) = RowIndex(S);
        En(i) = MinCol;
    end

    %����ֵ��������
    Th = sort(Th);

    segImg = zeros(m, n);

    %     temp=zeros(m,n);

    for i = 1:N - 2
        temp = cX > Th(i) & cX <= Th(i + 1);

        if (~isempty(temp))
            segImg = segImg + i * temp;
        end

    end

    temp = cX > Th(N - 1);

    if (~isempty(temp))
        segImg = segImg + (N - 1) * (cX > Th(N - 1));
    end
