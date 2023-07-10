%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%实现SVM分类器，数据库为iris数据库%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
%*******************************从iris.data文件中读取数据**********************
[filename,filepath]=uigetfile('*.data','导入iris数据库');
file=[filepath filename];
fid=fopen(file);
if fid ~=-1
    disp('打开数据文件成功！');
end
if fid==-1
    disp('打开数据文件出错！');
end
%****************************读取文件中的属性数据放入数组中*****************
%其中一个数组元是由一个四个数据组成的小数组，即一个样本的四个属性
lineNumber=1;
while 1
    dataLine = fgetl(fid);
    if ~ischar(dataLine)
        break;
    end
    irisData{lineNumber} = sscanf(dataLine,'%f,%f,%f,%f');
    lineNumber=lineNumber+1;
end
%***********************转换数据格式，保存成mat格式*****************************
for i=1:150
    if i<=50
        y(i)=1;
    else if (i<=100)
            y(i)=2;
        else
            y(i)=3;
        end
    end
end
name='Iris Data Set';
for i=1:150
    sample=irisData{i};
    for j=1:4
        X(:,i)=sample;
    end
end
save('iris1.mat','X','y','name');
%************************重新载入数据，进行分类*********************************
load iris1.mat;  
X=X';
x=[X(1:15,:); X(51:65,:); X(101:115,:)];
y1=[ones(15,1);-ones(30,1)];
y2=[-ones(30,1);ones(15,1)];
%******************计算二次规划函数中的参数，从而调用二次规划函数****************
for i=1:1:45
    for j=1:1:45
        H1(i,j)=y1(i)*y1(j)*x(i,:)*x(j,:)';
    end
end
for i=1:1:45
    for j=1:1:45
        H2(i,j)=y2(i)*y2(j)*x(i,:)*x(j,:)';
    end
end
c=100 ;
f=-ones(45,1);Aeq1=y1';Aeq2=y2';beq=0;lb=zeros(45,1);ub=c*ones(45,1);
a1=quadprog(H1,f,[],[],Aeq1,beq,lb,ub);  %调用二次规划函数计算未知参数从而得到权向量 
a2=quadprog(H2,f,[],[],Aeq2,beq,lb,ub);
w1=0;w2=0;
for i=1:1:45
    w1=w1+y1(i)*a1(i)*x(i,:);  %计算权向量
end
for i=1:1:45
    w2=w2+y2(i)*a2(i)*x(i,:);
end
[m1,n1]=max(a1(1:15,:)); %寻找参数最大值及其对应的样本的脚标
[m2,n2]=max(a1(15:25,:));
[m3,n3]=max(a2(1:20,:));
[m4,n4]=max(a2(21:30,:));
b1=-0.5*w1*(x(n1,:)+x(n2+10,:))';
b2=-0.5*w2*(x(n3,:)+x(n4+20,:))';
x1=X;
%*****************************得到判别准则，进行分类****************************
for i=1:1:150
    Y1(i)=w1*x1(i,:)'+b1;  %判别准则
    Y2(i)=w2*x1(i,:)'+b2;
end
result1=Y1';result2=Y2';
for i=1:1:150
    if result1(i,:)>0 && i<=50
        class(i)=1;
    else
        if result2(i,:)>0
            class(i)=2;
        else
            class(i)=3;
        end
    end
end
%disp('第一次分类结果如下：');
%disp('第一类样本分类正确数是：');
%disp(k1);
%disp('第二类样本分类正确数是：');
%disp(k2);
%disp('第三类样本分类正确数是：');
%disp(k3);

%第一次分类之后的效果不是很好，第一类样本基本都分出来了，但是第二类和第三类样本并没有
%下面需要进行分析，对后两类进行SVM分类，方法步骤与上面的步骤类似
x1=[X(51:65,:); X(101:115,:)];
y11=[ones(15,1);-ones(15,1)];
y22=[-ones(15,1);ones(15,1)];
%计算二次规划函数中的参数，从而调用二次规划函数
for i=1:1:30
    for j=1:1:30
        H11(i,j)=y11(i)*y11(j)*x1(i,:)*x1(j,:)';
    end
end
for i=1:1:30
    for j=1:1:30
        H22(i,j)=y22(i)*y22(j)*x1(i,:)*x1(j,:)';
    end
end
c=100 ;
f=-ones(30,1);Aeq1=y11';Aeq2=y22';beq=0;lb=zeros(30,1);ub=c*ones(30,1);
a1=quadprog(H11,f,[],[],Aeq1,beq,lb,ub);  %调用二次规划函数计算未知参数从而得到权向量 
a2=quadprog(H22,f,[],[],Aeq2,beq,lb,ub);
w11=0;w22=0;
for i=1:1:30
    w11=w11+y11(i)*a1(i)*x1(i,:);  %计算权向量
end
for i=1:1:30
    w22=w22+y22(i)*a2(i)*x1(i,:);
end
[m1,n1]=max(a1(1:15,:)); %寻找参数最大值及其对应的样本的脚标
[m2,n2]=max(a1(15:25,:));
[m3,n3]=max(a2(1:20,:));
[m4,n4]=max(a2(21:30,:));
b1=-0.5*w11*(x1(n1,:)+x1(n2+10,:))';
b2=-0.5*w22*(x1(n3,:)+x1(n4+20,:))';
x1=X;
for i=1:1:150
    Y1(i)=w11*x1(i,:)'+b1;  %判别准则
    Y2(i)=w22*x1(i,:)'+b2;
end
result1=Y1';result2=Y2';
for i=51:1:150
    if result1(i,:)>0
        class(i)=2;
    else
        class(i)=3;
    end
end
k1=0;k2=0;k3=0;
for i=1:150
    if class(i)==1 &&i<=50
        k1=k1+1;
    end
    if class(i)==2 && i>50 && i<=100
        k2=k2+1;
    end
    if class(i)==3 && i>100 && i<=150
        k3=k3+1;
    end
end
%*************************显示最后的分类结果及分类准确率************************   
disp('SVM分类器分类结果如下：');    
%disp('第二次分类结果如下：');
disp('   样本   原类  分类'); 
result=[1:150; y; class];
result=result';
disp(result);
disp('SVM分类器第一类样本分类正确率是：');
disp(k1/50);
disp('SVM分类器第二类样本分类正确率是：');
disp(k2/50);
disp('SVM分类器第三类样本分类正确率是：');
disp(k3/50);
disp('SVM分类器总正确率是：');
disp((k1+k2+k3)/150);


