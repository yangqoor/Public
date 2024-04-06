function [X,Y]=demoDataN()
X1=normrnd(2,2,1,50);
X2=[normrnd(4,4,1,50),normrnd(5,2,1,50)];
X3=[normrnd(6,2,1,50),normrnd(8,4,1,50)];
X4=[normrnd(12,1,1,50),normrnd(12,4,1,50)];
X5=[normrnd(10,2,1,50),normrnd(10,4,1,50)];
X6=[normrnd(7,2,1,50),normrnd(7,4,1,50)];
X7=[normrnd(4,2,1,50),normrnd(4,4,1,50)];
Data={X1,X2,X3,X4,X5,X6,X7};
Y=zeros(7,500);
for i=1:length(Data)
    tX=Data{i};tX=tX(:)';
    [F,Xi]=ksdensity(tX,linspace(-5,10,500));
    Y(i,:)=F;
end
X=Xi;
end