clc;
clear;
N=10;
%下面的数据是我们实际项目中的训练样例（样例中有8个属性）
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
sampleData=[correctData;errorData_ReversePharse;errorData_CountLoss;errorData_X;errorData_Lower;errorData_Local_X;errorData_Z;errorData_High;errorData_CountBefore;errorData_Local_X1];%训练样例

type1=1;%正确的波形的类别，即我们的第一组波形是正确的波形，类别号用 1 表示
type2=-ones(1,N-2);%不正确的波形的类别，即第2~10组波形都是有故障的波形，类别号用-1表示
groups=[type1 ,type2]';%训练所需的类别号
j=1;
%由于没有测试数据，因此我将错误的波形数据轮流从训练样例中取出作为测试样例
for i=2:10
    tempData=sampleData;
    tempData(i,:)=[];
    svmStruct = svmtrain(tempData,groups);
    species(j) = svmclassify(svmStruct,sampleData(i,:));
    j=j+1;
end
species