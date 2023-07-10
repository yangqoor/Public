%--------------------------------------------------------------------------
%   [detected,th] = pow2cfar(datain,pfa,guard_N,train_N)
%--------------------------------------------------------------------------
%   ���ܣ�
%   ����Ƥ��ѷ�������matlab�Դ��ٷ���
%--------------------------------------------------------------------------
%   ����:
%           datain              ���� �б�ʾ����ά
%           pfa                 �龯����
%           train_N             ѵ����Ԫ����,����
%           guard_N             �ػ���Ԫ����,����
%   ���:
%           detected            �о����
%           th                  �о���ֵ
%--------------------------------------------------------------------------
%   p2cfar��̬
%   �����������������������������
%   ��   ѵ����Ԫ
%   ��   �ػ���Ԫ
%   ��   �о����
%--------------------------------------------------------------------------
%   ���ӣ�
%   [detected,th] = p2cfar(datain,pfa,train_N,guard_N)
%--------------------------------------------------------------------------
function [detected,th] = pow2cfar(datain,pfa,guard_N,train_N)
cfar = phased.CFARDetector('NumTrainingCells',train_N*2,'NumGuardCells',guard_N*2);
cfar.ProbabilityFalseAlarm = pfa;
cfar.ThresholdOutputPort = true;
cfar.ThresholdFactor = 'Auto';
[detected,th] = cfar(datain,1:size(datain,1));
