clc;
clear;
N=10;
%���������������ʵ����Ŀ�е�ѵ����������������8�����ԣ�
correctData=[0,0.2,0.8,0,0,0,2,2];
errorData_ReversePharse=[1,0.8,0.2,1,0,0,2,2];
errorData_CountLoss=[0.2,0.4,0.6,0.2,0,0,1,1];
errorData_X=[0.5,0.5,0.5,1,1,0,0,0];
errorData_Lower=[0.2,0,1,0.2,0,0,0,0];
errorData_Local_X=[0.2,0.2,0.8,0.4,0.4,0,0,0];
errorData_Z=[0.53,0.55,0.45,1,0,1,0,0];
errorData_High=[0.8,1,0,0.8,0,0,0,0];
errorData_CountBefore=[0.4,0.2,0.8,0.4,0,0,2,2];
errorData_Local_X1=[0.3,0.3,0.7,0.4,0.2,0,1,0];
sampleData=[correctData;errorData_ReversePharse;errorData_CountLoss;errorData_X;errorData_Lower;errorData_Local_X;errorData_Z;errorData_High;errorData_CountBefore;errorData_Local_X1];%ѵ������

type1=1;%��ȷ�Ĳ��ε���𣬼����ǵĵ�һ�鲨������ȷ�Ĳ��Σ������� 1 ��ʾ
type2=-ones(1,N-2);%����ȷ�Ĳ��ε���𣬼���2~10�鲨�ζ����й��ϵĲ��Σ�������-1��ʾ
groups=[type1 ,type2]';%ѵ�����������
j=1;
%����û�в������ݣ�����ҽ�����Ĳ�������������ѵ��������ȡ����Ϊ��������
for i=2:10
    tempData=sampleData;
    tempData(i,:)=[];
    svmStruct = svmtrain(tempData,groups);
    species(j) = svmclassify(svmStruct,sampleData(i,:));
    j=j+1;
end
species