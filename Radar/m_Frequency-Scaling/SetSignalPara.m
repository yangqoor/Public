%%
% �ú������������״��źŲ�����
% ��SignalParaFlag=1ʱ���������źŲ����ṹ�壻
% SignalParaFlag=0ʱ���޲���
%%
function SignalPara=SetSignalPara(SignalParaFlag)
if SignalParaFlag
    c=3e8;%����
    fc=1.26e9;%5.3e9;%Ƶ��
    lamda=c/fc;%����
    Br=60e6;%50e6;%�źŴ���
    Tp=80e-6;%2.5e-6;%�ź�������
    gama=Br/Tp;%��Ƶ��
    SignalPara=struct('c',c,'fc',fc,'lamda',lamda,'Br',Br,'Tp',Tp,'gama',gama,'state',SignalParaFlag);
else
    SignalPara=struct('state',SignalParaFlag);
end
end