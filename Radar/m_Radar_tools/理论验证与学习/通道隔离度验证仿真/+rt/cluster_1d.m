function output = cluster_1d(input)
disp('�������ݵ��н���1ά����');
output = zeros(size(input));
flag = 0;                                                                   %cfar״̬���λ 0 �ȴ������� 1�ȴ��½���
max_x = [];
max_y = [];
for idx = 1:size(input,2)
    temp = 0;
    for jdx = 1:size(input,1)
        %------------------------------------------------------------------
        if flag==0 && input(jdx,idx)>0                                      %��״̬0�м�⵽������
            flag = 1;                                                       %�޸�Ϊ״̬1
            temp = input(jdx,idx);                                          %�滻���ֵ��ֵ
            max_x = jdx;                                                    %�õ�x����
            max_y = idx;                                                    %�õ�y����
        end
        %------------------------------------------------------------------
        if flag==1 && input(jdx,idx)>0                                      %��״̬1��ȡ���ֵ
            if input(jdx,idx)>temp                                          %ѡ��洢
                temp = input(jdx,idx);                                      %�滻���ֵ��ֵ
                max_x = jdx;                                                %�õ�x����
                max_y = idx;                                                %�õ�y����
            end
        end
        %------------------------------------------------------------------
        if flag==1 && (input(jdx,idx)==0 || jdx == size(input,1))           %��״̬1�м�⵽�½���
            flag = 0;
            output(max_x,max_y) = temp;                                     %�����ֵ����cfar���
        end
        %------------------------------------------------------------------
    end
end


