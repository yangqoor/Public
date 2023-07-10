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
%****************************读取文件中的属性数据放入数组iris中*****************
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
disp(X);
save('iris1.mat','X','y','name');
load iris1.mat;  %载入iris文本数据
X=X';
x=[X(1:15,:); X(51:65,:); X(101:115,:)];
y1=[ones(15,1);-ones(30,1)];
y2=[-ones(30,1);ones(15,1)];
%计算二次规划函数中的参数，从而调用二次规划函数
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
for i=1:1:150
    Y1(i)=w1*x1(i,:)'+b1;  %判别准则
    Y2(i)=w2*x1(i,:)'+b2;
end
k1=0;k2=0;k3=0;
result1=Y1';result2=Y2';
for i=1:1:150
    if result1(i,:)>0 && i<=50
        k1=k1+1;  %第一类样本数
        center1(k1,:)=X(i,:);  %第一类样本集
    elseif result2(i,:)>0
        k2=k2+1;  %第二类样本数
        center2(k2,:)=X(i,:);  %第二类样本集
    else
        k3=k3+1;  %第三类样本数
        center3(k3,:)=X(i,:);  %第三类样本集
    end
end
disp(k1);
disp(k2);
disp(k3);
