%�״�Ŀ����Чɢ�����
function rcs=qfmx(rcs_k,rcs0)
%% �������
%rcs0    Ŀ���ƽ�������
%rcs_k        Ŀ����������
%% �������
%rcs       Ŀ���ɢ�����
%% ����
if rcs_k==0 
    rcs=rcs0;  %rcs_k =0ʱ���ò����ģ��
elseif rcs_k==1
    rcs=-rcs0*log(1-rand(1,1));  %rcs_k =1ʱ����˹���֢�,�����ģ��
elseif rcs_k==2
    rcs=-(rcs0/2)*(log(1-rand(1,1))+log(1-rand(1,1))); %rcs_k =2ʱ����˹���֢�,�����ģ��
end